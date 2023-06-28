//
//  CalendarAddAttendanceController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/26.
//

import UIKit
import RxRelay
class CalendarAddAttendanceController: BaseTableController {

    var friends:[FriendListModel] = []
    var selectUsers: BehaviorRelay<[FriendListModel]> =  BehaviorRelay(value: [])
    init(selecteds:[FriendListModel]) {
        super.init(nibName: nil, bundle: nil)
        selectUsers.accept(selecteds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIButton()
        doneButton.textColor(.blue)
        doneButton.titleForNormal = "Done"
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        doneButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
   
        refreshData()
    }
    
    override func refreshData() {
        getFriendList()
    }
    
  
    
    func getFriendList() {
        
        FriendService.friendList().subscribe(onNext:{ models in
            models.forEach({ item in
                if self.selectUsers.value.contains(where: { $0.id == item.id }) {
                    item.isSelected = true
                }
            })
            self.friends.append(contentsOf: models)
            self.endRefresh()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
        
    }
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        tableView?.showsVerticalScrollIndicator = false
        tableView?.register(cellWithClass: CalendarAddAttendanceCell.self)
        tableView?.scrollToTop()
        
    }
    
  
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: CalendarAddAttendanceCell.self)
        if friends.count > 0 {
            let model = friends[indexPath.row]
            cell.imgView.kf.setImage(with: model.avt.imageUrl,placeholder: R.image.proile_user()!)
            cell.nameLabel.text = String.fullName(first: model.fn, last: model.ln)
            cell.accessoryType = model.isSelected ? .checkmark : .none
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = friends[indexPath.row]
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
        nameLabel.textColor = R.color.textColor52()
        nameLabel.font = UIFont.sk.pingFangRegular(15)
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
