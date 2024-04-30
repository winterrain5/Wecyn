//
//  CalendarAddAttendanceController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/26.
//

import UIKit
import RxRelay
import IQKeyboardManagerSwift
class CalendarAddAttendanceController: BaseTableController {

    var friends:[FriendListModel] = []
    var selectUsers: BehaviorRelay<[FriendListModel]> =  BehaviorRelay(value: [])
    var selectComplete: ((FriendListModel)->())?
    var searchResults:[FriendListModel] = []
    var keyword = ""
    let searchView = NavbarSearchView(placeholder: "Search by Name",isSearchable: true,isBecomeFirstResponder: false)
    init(selecteds:[FriendListModel]) {
        super.init(nibName: nil, bundle: nil)
        selectUsers.accept(selecteds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enableAutoToolbar  = false
        
        let doneButton = UIButton()
        doneButton.textColor(.black)
        doneButton.width = 72
        let doneItem = UIBarButtonItem(customView: doneButton)
        
        let fixItem = UIBarButtonItem.fixedSpace(width: 16)
        
        self.navigation.item.rightBarButtonItems = [doneItem,fixItem]
        doneButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.returnBack()
        }).disposed(by: rx.disposeBag)
        
        selectUsers.map({ !$0.isEmpty }).subscribe(onNext:{ $0 ? (doneButton.titleForNormal = "Done") : (doneButton.titleForNormal = "Cancel") }).disposed(by: rx.disposeBag)
        
        
        searchView.size = CGSize(width: kScreenWidth * 0.7, height: 36)
        self.navigation.item.titleView = searchView
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.keyword = keyword.trimmed
            self.searchResults = self.friends.filter({ $0.first_name.contains(keyword.trimmed) || $0.last_name.contains(keyword.trimmed) || $0.full_name.contains(keyword.trimmed)})
            self.reloadData()
        }
        
        searchView.beginSearch = { [weak self] in
            guard let `self` = self else { return }
            self.searchResults = []
            self.reloadData()
        }
        
        self.addLeftBarButtonItem()
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
   
        refreshData()
        
    }
    
    
    override func refreshData() {
        getFriendList()
    }
    
  
    
    func getFriendList() {
        self.friends.removeAll()
        NetworkService.friendList(id: CalendarBelongUserId).subscribe(onNext:{ models in
            models.forEach({ item in
                if self.selectUsers.value.contains(where: { $0.id == item.id }) {
                    item.isSelected = true
                }
            })
            self.friends.append(contentsOf: models)
            self.searchView.stoploading()
            self.endRefresh()
        },onError: { e in
            self.searchView.stoploading()
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
        
    }
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kBottomsafeAreaMargin + 40, right: 0)
        tableView?.showsVerticalScrollIndicator = false
        tableView?.register(cellWithClass: CalendarAddAttendanceCell.self)
 
    }
    
  
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count > 0 ? searchResults.count : friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: CalendarAddAttendanceCell.self)
        var model:FriendListModel?
        if searchResults.count > 0 {
            model = searchResults[indexPath.row]
        }else if friends.count > 0{
            model = friends[indexPath.row]
        }
        guard let model = model else { return cell  }
        cell.imgView.kf.setImage(with: model.avatar_url,placeholder: R.image.proile_user()!)
        cell.nameLabel.text = model.full_name
        cell.accessoryType = model.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = friends[indexPath.row]
        if let selectComplete {
            selectComplete(model)
            self.dismiss(animated: true)
            return
        }
        
        model.isSelected = !model.isSelected
        selectUsers.accept(friends.filter({ $0.isSelected }))
        tableView.reloadData()
        
    }

}


class CalendarAddAttendanceCell: UITableViewCell {
    var imgView = UIImageView()
    var nameLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        imgView.sk.cornerRadius = 20
        imgView.contentMode = .scaleAspectFill
        nameLabel.textColor = R.color.textColor33()
        nameLabel.font = UIFont.sk.pingFangRegular(16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
    }
}
