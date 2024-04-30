//
//  OrganizationSearchController.swift
//  Wecyn
//
//  Created by Derrick on 2023/10/23.
//

import UIKit

class OrganizationSearchController: BaseTableController {

    var searchView:NavbarSearchView!
    var datas:[OriganizationModel] = []
    var keyword:String = ""
    var selectComplete:((OriganizationModel)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView = NavbarSearchView(placeholder: "Search by name",isSearchable: true,isBecomeFirstResponder: true).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
        self.navigation.item.titleView = searchView
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.searchView.startLoading()
            self.keyword = keyword
            self.loadNewData()
            
        }
        
        
        self.addLeftBarButtonItem()
        self.leftButtonDidClick = {
            self.dismiss(animated: true)
        }
        
    }
    override func refreshData() {
    
        UserService.origanizationList(keyword: self.keyword).subscribe(onNext:{
            self.datas = $0
            let input = OriganizationModel()
            input.name = self.keyword
            input.id = -1
            self.datas.insert(input, at: 0)
            self.endRefresh()
            self.searchView.stoploading()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.searchView.stoploading()
        }).disposed(by: rx.disposeBag)
     
    }
    override func createListView() {
        super.createListView()
        registRefreshHeader()
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()!
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 84, bottom: 0, right: 0)
        tableView?.register(cellWithClass: OrganizationCell.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: OrganizationCell.self)
      
        if self.datas.count > 0 {
            let model = datas[indexPath.row]
            if indexPath.row == 0 {
                cell.imgView.image = R.image.org_placeholder()
                cell.imgView.contentMode = .center
            } else {
                cell.imgView.kf.setImage(with: model.avatar.url)
                cell.imgView.contentMode = .scaleAspectFit
            }
            
            cell.label.text = model.name
        }
        
        return cell
    }
    
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.returnBack()
        self.selectComplete?(datas[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }


}

class  OrganizationCell:UITableViewCell {
    let imgView = UIImageView()
    let label = UILabel().color(R.color.textColor33()!).font(UIFont.systemFont(ofSize: 16))
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(label)
        imgView.cornerRadius = 6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
    }
}
