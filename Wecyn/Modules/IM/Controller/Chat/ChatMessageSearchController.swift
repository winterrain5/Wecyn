//
//  ChatMessageSearchController.swift
//  Wecyn
//
//  Created by Derrick on 2024/5/16.
//

import UIKit

class ChatMessageSearchController: BaseTableController {

    var conversation:ConversationInfo
    var keyword:String = ""
    var results:[MessageInfo] = []
    init(conversation:ConversationInfo) {
        
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTitleView()
    }
    
    func addTitleView() {
        let searchView = NavbarSearchView(placeholder: "search",isSearchable: true,isBecomeFirstResponder: true).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
        
        self.navigation.item.titleView = searchView
        
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            searchView.startLoading()
            if keyword.isEmpty {
                return
            }
            self.keyword = keyword
            let params = SearchParam()
            params.keywordList = [keyword]
            params.pageIndex = self.page
            params.count = self.pageSize
            params.conversationID = conversation.conversationID
            IMController.shared.searchRecord(param: params) { info in
                searchView.stoploading()
                self.results = info?.searchResultItems.map({ $0.messageList }).flatMap({ $0 }) ?? []
                self.reloadData()
            }
            
            
        }
        
        searchView.beginSearch = { [weak self] in
            guard let `self` = self else { return }
            
            self.reloadData()
        }
    }
    
    override func createListView() {
        super.createListView()
        
        tableView?.register(ChatMessageSearchCell.self, forCellReuseIdentifier: "ChatMessageSearchCell")
        tableView?.estimatedRowHeight = 200
        tableView?.rowHeight = UITableView.automaticDimension
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageSearchCell", for: indexPath) as! ChatMessageSearchCell
        if results.count > 0 {
            cell.bindData(results[indexPath.row],keyword: self.keyword)
        }
        return cell
    }
    
    public func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = results[indexPath.row]
        
        let markReadTitle = "定位到聊天位置".innerLocalized()
        let markReadAction = UIContextualAction(style: .normal, title: markReadTitle) { [weak self] _, _, completion in
            guard let `self` = self else { return }
            let vc = ChatViewControllerBuilder().build(conversation, anchorID: item.clientMsgID)
            self.navigationController?.pushViewController(vc)
        }
        markReadAction.backgroundColor = UIColor.c8E9AB0
        
        let deleteAction = UIContextualAction(style: .destructive, title: "删除".innerLocalized()) { [weak self] _, _, completion in
            guard let `self` = self else { return }
            IMController.shared.imManager.deleteConversationAndDeleteAllMsg(self.conversation.conversationID) { text in
                self.results.remove(at: indexPath.row)
                self.tableView?.deleteRows(at: [indexPath], with: .none)
                completion(true)
            } onFailure: { code, msg in
                Toast.showError("Delete Conversation Failed")
                print("清除指定会话失败:\(code) - \(msg ?? "")")
            }
        }
        
        deleteAction.backgroundColor = UIColor.cFF381F
        let configure = UISwipeActionsConfiguration(actions: [deleteAction, markReadAction])
        return configure
    }

}

class ChatMessageSearchCell: UITableViewCell {
    var message:MessageInfo? {
        didSet {
            guard let message = message else { return }
            self.avatarView.kf.setImage(with: message.senderFaceUrl?.url)
            
            self.contentLabel.text = message.textElem?.content
            
            self.nameLabel.text = message.senderNickname
            let date = Date.init(unixTimestamp: message.sendTime / 1000)
            self.timeLabel.text = date.toString(format:"dd/MM/yyyy")
        }
    }
    var avatarView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = R.color.backgroundColor()
        view.cornerRadius = 24
        return view
    }()
    var contentLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    var timeLabel:UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    var nameLabel:UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(_ message:MessageInfo,keyword:String? = nil) {
        self.message = message
        if let keyword = keyword {
            self.contentLabel.sk.setSpecificTextColor(keyword, color: .blue)
        }
            
        setNeedsUpdateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       
        
    }
    
    override func updateConstraints() {
        
        avatarView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.height.width.equalTo(48)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(16)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(20)
            make.top.equalTo(avatarView)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        super.updateConstraints()
    }
}
