//
//  ConnectAuditController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/7.
//

import UIKit
let ConnectionAuditCellHeight = 90.cgFloat
let ConnectionAuditSectionHeight = 36.cgFloat
class ConnectAuditController: BaseTableController {
    var models:[FriendRecieveModel] = [] {
        didSet {
            self.reloadData()
            hideSkeleton()
        }
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ConnectionAuditDataLoaded, object: nil, queue: OperationQueue.main) { noti in
            let headerHeight = noti.object as? CGFloat ?? 0
            self.tableView?.height = headerHeight
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        showSkeleton()
    }

    override func createListView() {
        super.createListView()
        cellIdentifier = ConnectAuditItemCell.className
        tableView?.isSkeletonable = true
        registRefreshHeader()
        tableView?.showsVerticalScrollIndicator = false
        tableView?.register(nibWithCellClass: ConnectAuditItemCell.self)
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: 0)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ConnectionAuditCellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: ConnectAuditItemCell.self)
        if models.count > 0 {
            let model = models[indexPath.row]
            cell.model = model
        }
        
        cell.auditHandler = { [weak self] in
            NotificationCenter.default.post(name: NSNotification.Name.ConnectionAuditUser, object: nil)
        }
        cell.selectionStyle = .none
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return models.count > 0 ? ConnectionAuditSectionHeight : 0
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView().backgroundColor(.white)
        let label = UILabel().text("New connection request(s) from:").color(R.color.textColor52()!).font(UIFont.sk.pingFangSemibold(15))
        view.addSubview(label)
        label.frame = CGRect(x: 16, y: 0, width: kScreenWidth, height: ConnectionAuditSectionHeight)
        return view
    }
    
}
