//
//  AdminDepartmentController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/15.
//

import UIKit

class AdminDepartmentController: BasePagingTableController {
    
    var datas:[[MMNode<AdminDepartmentModel>]] = []
    var selectIndexPath:IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIButton()
        self.view.addSubview(addButton)
        addButton.backgroundColor = R.color.theamColor()
        addButton.titleForNormal = "+"
        addButton.titleLabel?.font = UIFont.sk.pingFangMedium(30)
        addButton.titleColorForNormal = .white
        addButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-(kTabBarHeight + 16))
            make.width.height.equalTo(60)
        }
        addButton.addShadow(cornerRadius: 30)
        addButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            let vc = AdminDepartmentDetailController(mode: .Add)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
           
        }).disposed(by: rx.disposeBag)
        
    }
    
    
    override func refreshData() {
        self.datas.removeAll()
        AdminService.departmentList(orgId: Admin_Org_ID).subscribe(onNext:{ models in
            var nodes:[MMNode<AdminDepartmentModel>] = []
            models.forEach { [weak self] dict in
                if let model = self?.generateModel(dict) {
                    nodes.append(model)
                }
            }
            
            if let children = nodes.first?.children {
                children.forEach({
                    self.datas.append([$0])
                })
            }
            
            self.endRefresh(self.datas.count,emptyString: "No Department")
            self.updateDataComplete?()
            
        },onError: { e in
            
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
            
            self.updateDataComplete?()
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    func generateModel(_ dict:[String:Any]) -> MMNode<AdminDepartmentModel>? {
        guard let model = AdminDepartmentModel.deserialize(from: dict) else {
            return nil
        }
        let root = MMNode(element: model)
        root.add(nodes:generateSubModel(root))
        return root
    }
    
    func generateSubModel(_ root:MMNode<AdminDepartmentModel>) -> [MMNode<AdminDepartmentModel>]  {
        guard let children = root.element.children,children.count > 0 else {
            return []
        }
        var subNode:[MMNode<AdminDepartmentModel>] = []
        children.forEach { e in
            let node = MMNode(element: e)
            node.add(nodes:generateSubModel(node))
            subNode.append(node)
        }
        return subNode
    }
    
    func unfoldNode() {
        datas.enumerated().forEach { pi,pe in
            pe.enumerated().forEach { ci,ce in
                datas[pi].insert(contentsOf: [], at: ci + 1)
            }
        }
    }
    

    override func createListView() {
        super.createListView()
        
        tableView?.register(cellWithClass: AdminDepartmentCell.self)
        
        addSingleSeparator()
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - PagingSegmentHeight.cgFloat - kTabBarHeight)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        datas.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datas.count > 0 {
            return datas[section].count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AdminDepartmentCell.self)
        if datas.count > 0,datas[indexPath.section].count > 0{
            let node = datas[indexPath.section][indexPath.row]
            cell.node = node
            cell.indexPath = indexPath
        }
        cell.checkDetailHandler = { [weak self] in
            self?.selectIndexPath = $1
            let vc = AdminDepartmentDetailController(node: $0, mode: .Check)
            self?.present(vc, animated: true)
            vc.editHandler = {
                let vc = AdminDepartmentDetailController(node: $0, mode: .Edit)
                let nav = BaseNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self?.present(nav, animated: true)
            }
            vc.deleteHandler = {
                self?.deleteDepartment($0)
            }
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if datas.count > 0,datas[indexPath.section].count > 0{
            let node = datas[indexPath.section][indexPath.row]
            if node.isOpen { return }
            if node.numberOfChildren > 0 {
                node.isOpen = true
                datas[indexPath.section].insert(contentsOf: node.children, at: indexPath.row + 1)
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }
        }
    }
    
    func deleteDepartment(_ node:MMNode<AdminDepartmentModel>) {
        func deleteRow() {
            guard let indexPath = self.selectIndexPath else  { return }
            self.tableView?.deleteRows(at: [indexPath], with: .automatic)
        }
      
        let alert = UIAlertController(title: "Are you sure you want to delete this department?", message: "You can move users to another department.", preferredStyle: .actionSheet)
        alert.addAction(title: "Assigned to another department",style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            
            let vc = AdminDepartmentSelectParentNodeController(selectedNode: node.element)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            vc.selectComplete = {
                AdminService.deleteDepartment(id: node.element.id,toId: $0.id).subscribe(onNext:{
                    
                    if $0.success == 1 {
                        Toast.showSuccess("successfully deleted")
                        self.loadNewData()
                    } else {
                        Toast.showError($0.message)
                    }
                    
                },onError: { e in
                    Toast.showError(e.asAPIError.errorInfo().message)
                }).disposed(by: self.rx.disposeBag)
            }
            
        }
        
        
        alert.addAction(title: "Cancel",style: .cancel) { _ in
            
        }
        
        alert.show()
        
    }
}

class AdminDepartmentCell:UITableViewCell {
    var node:MMNode<AdminDepartmentModel>? {
        didSet  {
            guard let node = node else { return }
            
            nameLabel.text = "·" + node.element.name
            arrowImgView.isHidden = node.numberOfChildren == 0
            if node.isOpen  {
                arrowImgView.image = R.image.chevronDown()
            } else {
                arrowImgView.image = R.image.chevronRight()
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    var indexPath:IndexPath?
    let nameLabel = UILabel().color(R.color.textColor33()!).font(UIFont.systemFont(ofSize: 15, weight: .semibold))
    let arrowImgView = UIImageView()
    let detailButton = UIButton()
    var checkDetailHandler:((MMNode<AdminDepartmentModel>,IndexPath)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(arrowImgView)
        contentView.addSubview(detailButton)
        contentView.addSubview(nameLabel)
        arrowImgView.image = R.image.chevronRight()
        detailButton.imageForNormal = R.image.infoCircle()
        detailButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let node = self?.node,let indexPath = self?.indexPath else { return }
            
            self?.checkDetailHandler?(node,indexPath)
            
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let depth = self.node?.depth ?? 1
        nameLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(16 * depth)
            make.centerY.equalToSuperview()
        }
        arrowImgView.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        detailButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-42)
            make.centerY.equalToSuperview()
        }
       
    }
}




