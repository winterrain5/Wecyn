//
//  CalendarAssistantMenu.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/3.
//

import UIKit

class CalendarAssistantMenu: UIView ,UITableViewDataSource,UITableViewDelegate{
    
    var tableView = UITableView(frame: .zero, style: .plain)
    var coverView = UIView()
    var contentHeight:CGFloat = 0
    var assistants:[AssistantInfo] = []
    var originView:UIView!
    let rowHeight:CGFloat = 52
    var selectRow:Int = 0
    var selectComplete:((Int)->())!
    var dissmissHandler:(()->())!
    init(assistants:[AssistantInfo], originView:UIView, selectRow:Int = 0) {
        super.init(frame: .zero)
        self.originView = originView
        self.assistants = assistants
        self.selectRow = selectRow
        
        contentHeight = assistants.count.cgFloat * rowHeight
        
        addSubview(coverView)
        coverView.frame = CGRect(x: 0,
                                 y: kNavBarHeight + contentHeight,
                                 width: kScreenWidth,
                                 height: kScreenHeight - kNavBarHeight - contentHeight)
        coverView.rx.tapGesture().when(.recognized).subscribe(onNext:{ ges in
            self.hideMenu()
        }).disposed(by: rx.disposeBag)
        
        addSubview(tableView)
        tableView.rowHeight = rowHeight
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellWithClass: CalendarAssistantMenuCell.self)
        tableView.alpha = 0
        tableView.backgroundColor = .white
        tableView.frame = CGRect(x: 0, y: -contentHeight, width: kScreenWidth, height: contentHeight)
        
        
        
        alpha = 0
        backgroundColor = .clear
        
        self.originView.addSubview(self)
        self.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func showMenu() {
        
        self.tableView.alpha = 1
        self.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveEaseOut ,animations: {
            self.tableView.frame.origin.y = 0
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        })
    }
    
    func hideMenu() {
        
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveEaseOut ,animations: {
            self.tableView.frame.origin.y = -self.contentHeight
            self.backgroundColor = .clear
            
        }) { flag in
            self.tableView.alpha = 0
            self.alpha = 0
            self.removeFromSuperview()
            self.dissmissHandler()
        }
        
    }
}

extension CalendarAssistantMenu {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.assistants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CalendarAssistantMenuCell.self)
        cell.nameLabel.text = assistants[indexPath.row].name
        cell.imgView.kf.setImage(with: assistants[indexPath.row].avatar.avatarUrl,placeholder: R.image.proile_user()!)
        cell.accessoryType = indexPath.row == selectRow ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectComplete(indexPath.row)
        hideMenu()
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
        nameLabel.textColor = R.color.textColor52()
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
