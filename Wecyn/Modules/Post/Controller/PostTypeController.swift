//
//  PostTypeController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/12.
//

import UIKit

class PostTypeController: BaseTableController {

    var selectedType:PostType = .Public
    var datas:[PostType] = [.Public,.OnlyFans,.OnlySelf]
    typealias Action = (PostType) -> Void
    var action: Action?
    required init(selectedType:PostType, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        self.selectedType = selectedType
        self.action = action
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    override func createListView() {
        configTableview(.insetGrouped)
        cellIdentifier = UITableViewCell.className
        tableView?.backgroundColor = R.color.backgroundColor()!
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()!
        tableView?.register(cellWithClass: UITableViewCell.self)
        
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: self.view.height)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        let model = datas[indexPath.row]
        cell.textLabel?.text = model.description
        cell.accessoryType = self.selectedType == model ? .checkmark : .none
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = datas[indexPath.row]
        
        self.selectedType = model
        tableView.reloadData()
        
        Haptico.selection()
        
        self.action?(self.selectedType)
        
        DispatchQueue.main.schedule(after: .init(.now() + 0.5)) { [weak self] in
            guard let `self` = self else { return }
            self.returnBack()
        }
        
    }
   

}
