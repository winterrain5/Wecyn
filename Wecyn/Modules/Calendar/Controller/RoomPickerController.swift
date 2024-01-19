//
//  RoomPickerController.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/9.
//

import UIKit

class RoomPickerController: BaseTableController {

    var models: [UserRoomModel] = []
    var selectRoom:UserRoomOptionModel?
    typealias Action = (UserRoomOptionModel?) -> Void
    var action: Action?
    required init(selectRoom:UserRoomOptionModel? = nil, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        
        self.action = action
        self.selectRoom = selectRoom
        
        self.showSkeleton()
        UserService.userRoomList(currentUserId: CalendarBelongUserId).subscribe(onNext:{
            if let select = self.selectRoom {
                var options:[UserRoomOptionModel] = []
                $0.forEach({
                    options.append(contentsOf: $0.options)
                })
                options.forEach({
                    if $0.value == select.value {
                        $0.isSelected = true
                    }
                })
            }
            self.models = $0
            self.endRefresh(.NoData,emptyString: "No Room")
            self.hideSkeleton()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
        
        
        
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
        tableView?.isSkeletonable = true
        tableView?.backgroundColor = R.color.backgroundColor()!
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()!
        tableView?.register(cellWithClass: UITableViewCell.self)
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 50
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: self.view.height)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if models.count > 0 && section < models.count {
            return models[section].options.count
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        if models.count > 0 && indexPath.section < models.count {
            let model = models[indexPath.section].options[indexPath.row]
            cell.textLabel?.text = model.label
            cell.textLabel?.numberOfLines = 0
            cell.accessoryType = model.isSelected ? .checkmark : .none
        }
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        let label = UILabel().color(R.color.textColor77()!).font(UIFont.systemFont(ofSize: 15))
        label.frame = CGRect(x: 16, y: 0, width: self.view.width - 16, height: 50)
        view.addSubview(label)
        if models.count > 0 && section < models.count {
            label.text = models[section].label
        }
        return view
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var options:[UserRoomOptionModel] = []
        models.forEach({
            options.append(contentsOf: $0.options)
        })
        options.forEach({ $0.isSelected = false })
        
        let model = models[indexPath.section].options[indexPath.row]
        model.isSelected = true
        self.selectRoom = model
        tableView.reloadData()
        
        Haptico.selection()
        
        self.action?(self.selectRoom)
        returnBack()
    }
   

}
