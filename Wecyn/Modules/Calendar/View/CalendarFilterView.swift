//
//  CalendarFilterView.swift
//  Wecyn
//
//  Created by Derrick on 2023/10/11.
//

import UIKit

class CalendarFilterView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    var assistants:[AssistantInfo] = []
    var rooms:[MeetingRoom] = []
    var tableView:UITableView!
    var selectAssistantRow:Int = 0
    var selectRoomRow:Int? = nil
    var selectAssistantId:Int = 0
    let confirmButton = UIButton()
    let resetButton = UIButton()
    var filterHandler:(((assistant:AssistantInfo,room:MeetingRoom?))->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.register(cellWithClass: CalendarAssistantMenuCell.self)
        tableView.register(cellWithClass: UITableViewCell.self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 60, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        addSubview(tableView)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
       
        confirmButton.backgroundColor = R.color.theamColor()
        confirmButton.titleForNormal = "Confirm"
        confirmButton.titleColorForNormal = .white
        confirmButton.titleLabel?.font = UIFont.sk.pingFangRegular(15)
        confirmButton.cornerRadius = 18
        confirmButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            self.dismiss()
            
        }).disposed(by: rx.disposeBag)
        addSubview(confirmButton)
        
        
        
        getAssistants()
        getRooms()
        
    }
    
    func getAssistants() {
        ScheduleService.recieveAssistantList().subscribe(onNext:{ models in
            let userModel = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
            let selfModel = AssistantInfo()
            selfModel.id = userModel?.id.int ?? 0
            selfModel.name = userModel?.full_name ?? ""
            selfModel.avatar = userModel?.avatar ?? ""
            self.assistants = models
            self.assistants.insert(selfModel, at: 0)
            
            self.selectAssistantRow = UserDefaults.sk.value(for: "selectAssistantRow") as? Int ?? 0
            self.selectRoomRow = UserDefaults.sk.value(for: "selectRoomRow") as? Int
            
            self.selectAssistantId =  self.assistants[self.selectAssistantRow].id
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
    }
    
    func getRooms() {
        ScheduleService.meetingRoomList(id: self.selectAssistantId).subscribe(onNext:{
            self.rooms = $0
            self.tableView.reloadData()
        },onError: { e in
          
        }).disposed(by: rx.disposeBag)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: self) ?? .zero
        if location.x < kScreenWidth * 0.35 {
            self.dismiss()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
      
        confirmButton.snp.makeConstraints { make in
            make.left.right.equalTo(self.tableView).inset(22)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-(kBottomsafeAreaMargin + 16))
        }
        
     
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? assistants.count : rooms.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 52 : 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withClass: CalendarAssistantMenuCell.self)
            cell.nameLabel.text = assistants[indexPath.row].name
            cell.imgView.kf.setImage(with: assistants[indexPath.row].avatar.url,placeholder: R.image.proile_user()!)
            cell.accessoryType = indexPath.row == selectAssistantRow ? .checkmark : .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
            cell.textLabel?.text = rooms[indexPath.row].name
            cell.accessoryType = indexPath.row == selectRoomRow ? .checkmark : .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = R.color.backgroundColor()
        let label = UILabel()
        label.textColor = R.color.textColor33()
        label.text = section == 0 ? "Assistant" : "Room"
        view.addSubview(label)
        label.frame = CGRect(x: 16, y: 0, width: 120, height: 30)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0  {
            selectAssistantRow = indexPath.row
            UserDefaults.sk.set(value: indexPath.row, for: "selectAssistantRow")
        
            let selectAssistant = UserInfoModel()
            selectAssistant.id = assistants[selectAssistantRow].id.string
            selectAssistant.avatar = assistants[selectAssistantRow].avatar
            selectAssistant.full_name = assistants[selectAssistantRow].name
            UserDefaults.sk.set(object: selectAssistant, for: "selectAssistant")
            
            self.selectAssistantId = assistants[selectAssistantRow].id
            unselectRoom()
            getRooms()
            
        } else {
            
            if indexPath.row == selectRoomRow {
                unselectRoom()
                return
            }
            
            selectRoomRow = indexPath.row
            UserDefaults.sk.set(value: indexPath.row, for: "selectRoomRow")
            UserDefaults.sk.set(object: rooms[indexPath.row], for: "selectRoom")
        }
        tableView.reloadData()
    }
    
    func unselectRoom() {
        selectRoomRow = nil
        let temp:MeetingRoom? = nil
        tableView.reloadData()
        UserDefaults.sk.set(value: nil, for: "selectRoomRow")
        UserDefaults.sk.set(object: temp, for: "selectRoom")
    }
    
    func display() {
        self.alpha = 0
        self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        self.tableView.frame = CGRect(x: kScreenWidth, y: 0, width: kScreenWidth * 0.68, height: kScreenHeight)
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 4, initialSpringVelocity: 4) {
            self.alpha = 1
            self.tableView.frame.origin.x = kScreenWidth * 0.32
        }
    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 4, initialSpringVelocity: 4) {
            self.alpha = 0
           
            self.tableView.frame.origin.x = kScreenWidth
        } completion: { _ in
            self.removeFromSuperview()
           
        }
        
        let assistant = self.assistants[self.selectAssistantRow]
        var room:MeetingRoom? = nil
        
        if let roomRow = self.selectRoomRow {
            room = self.rooms[roomRow]
        }
         
        self.filterHandler?((assistant:assistant,room:room))
    }
    
    
    
}
class CalendarAssistantMenuCell: UITableViewCell {
    
    var imgView = UIImageView()
    var nameLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        imgView.sk.cornerRadius = 15
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
            make.width.height.equalTo(30)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
    }
}
