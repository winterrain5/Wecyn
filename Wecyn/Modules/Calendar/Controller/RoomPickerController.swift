//
//  RoomPickerController.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/9.
//

import UIKit

class RoomPickerController: BaseTableController {

    var models: [MeetingRoom] = []
    var selectRoom:MeetingRoom?
    typealias Action = (MeetingRoom?) -> Void
    var action: Action?
    required init(selectRoom:MeetingRoom? = nil, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        
        self.action = action
        self.selectRoom = selectRoom
        
        self.showSkeleton()
        ScheduleService.meetingRoomList(id: CalendarBelongUserId).subscribe(onNext:{
            if let select = self.selectRoom {
                $0.forEach({ e in
                    e.isSelect = (e.id == select.id)
                })
            }
            self.models = $0
            self.reloadData()
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
        tableView?.backgroundColor = R.color.backgroundColor()!
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()!
        tableView?.register(cellWithClass: UITableViewCell.self)
        
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: self.view.height)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        let model = models[indexPath.row]
        cell.textLabel?.text = model.name
        cell.accessoryType = model.isSelect ? .checkmark : .none
        return cell
    }
    
    func tintImage(_ colorHex: String) -> UIImage? {
        R.image.tagFill()?.withTintColor(UIColor(hexString: colorHex) ?? .red).withRenderingMode(.alwaysOriginal)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        models.forEach({ $0.isSelect = false })
        
        let model = models[indexPath.row]
        model.isSelect.toggle()
        
        self.selectRoom = model.isSelect ? model : nil
        tableView.reloadData()
        
        Haptico.selection()
        
        self.action?(self.selectRoom)
        returnBack()
    }
   

}
