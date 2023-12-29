//
//  AdminDepartmentSelectParentNodeController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/21.
//

import UIKit

class AdminDepartmentSelectParentNodeController: BaseViewController {

    var selectComplete:((AdminDepartmentModel)->())?
    var selectedNode:AdminDepartmentModel?
    let searchBar = UISearchBar()
    lazy var treeView: MMTreeTableView<AdminDepartmentModel> = {
        let expand = Option.expandForever(true)
        let startDepth = Option.startDepth(10)
        let indentation = Option.indentationWidth(30.0)

        let result = MMTreeTableView<AdminDepartmentModel>(options: [ startDepth, indentation,expand ], frame: .zero, style: .plain)
        result.treeDelegate = MMTreeDelegateThunk(base: self)
        result.backgroundColor = .white
        return result
    }()

    required init(selectedNode:AdminDepartmentModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.selectedNode = selectedNode
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLeftBarButtonItem(image: R.image.xmark()!)
        leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        self.navigation.item.title = "Select Department"
        
        
        self.view.addSubview(searchBar)
        searchBar.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: 44)
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search Department"
        searchBar.delegate = self
        
        view.addSubview(treeView)
        treeView.frame = CGRect(x: 0, y: kNavBarHeight + 44, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - 44)
        
        loadData()
    }
    
    
    func loadData() {
        AdminService.departmentList(orgId: Admin_Org_ID,keyword: searchBar.text ?? "").subscribe(onNext:{ dicts in
            var nodes:[MMNode<AdminDepartmentModel>] = []
            dicts.forEach { [weak self] dict in
                if let model = self?.generateModel(dict) {
                    nodes.append(model)
                }
            }
            
            if let root = nodes.first {
                
                let fileTree = MMFileTree<AdminDepartmentModel>(root: root)
                self.treeView.fileTree = fileTree
                
                self.treeView.reloadData()
            }
         
            
        },onError: { e in
            
            
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
            if e.id == self.selectedNode?.id {
                e.isSelected = true
            }
            node.add(nodes:generateSubModel(node))
            subNode.append(node)
        }
        return subNode
    }
   
 

}

extension AdminDepartmentSelectParentNodeController: MMTreeTableViewDelegate {

    typealias T = AdminDepartmentModel
    
    func nodeView(numberOfItems item: Int, model element: AdminDepartmentModel, nodeView view: MMTreeTableView<AdminDepartmentModel>) -> UIView {
        let view = AdminDepartmentSelectCell()
        view.node = element
    
        return view
    }

    func tableView(_ treeTableView: MMTreeTableView<AdminDepartmentModel>, didSelectRowAt indexPath: IndexPath) {
        
        treeTableView.nodes.forEach({
            $0.element.isSelected = false
        })
        
        let node = treeTableView.nodes[indexPath.item].element
        node.isSelected.toggle()
        
        treeTableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectComplete?(node)
            self.returnBack()
        }
        print(treeTableView.nodes[indexPath.item].element.name)
    
    }

}

extension AdminDepartmentSelectParentNodeController:UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = ""
        loadData()
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        loadData()
    }
}

class AdminDepartmentSelectCell:UIView {
    var node:AdminDepartmentModel! {
        didSet  {
            nameLabel.text = "·" + node.name
            if node.isSelected  {
                selectButton.imageForNormal = R.image.checkmarkCircle()
                backgroundColor = UIColor.green.withAlphaComponent(0.2)
            } else {
                selectButton.imageForNormal = R.image.circle()
                backgroundColor = .white
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    let nameLabel = UILabel().color(R.color.textColor33()!).font(UIFont.systemFont(ofSize: 15, weight: .semibold))
    let selectButton = UIButton()
    var selectHandler:((AdminDepartmentModel)->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(selectButton)
        addSubview(nameLabel)
        selectButton.imageForNormal = R.image.circle()
        selectButton.isUserInteractionEnabled = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-56)
            make.centerY.equalToSuperview()
        }
       
        selectButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
       
    }
}

