//
//  PostDraftsController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/19.
//

import UIKit
import IQKeyboardManagerSwift
class PostDraftsController: BaseTableController {

    var drafts:[PostDraftModel] = []
    let editButton = UIButton()
    var isEdit = false
    var selectDraftsCompelet:((PostDraftModel)->())?
    override func viewDidLoad() {
        super.viewDidLoad()

        drafts = UserDefaults.sk.get(for: PostDraftModel.className)
        
        self.endRefresh()
        
        self.navigation.item.title = "Drafts"
        
        editButton.titleForNormal = "Edit"
        editButton.titleColorForNormal = .black
        editButton.titleLabel?.font = UIFont.sk.pingFangRegular(18)
        editButton.size.width = 44
        editButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.isEdit.toggle()
            self.tableView?.setEditing(self.isEdit, animated: true)
            self.editButton.titleForNormal = self.isEdit ? "Done" : "Edit"
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        editButton.isEnabled = drafts.count != 0
        
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func createListView() {
        super.createListView()
        
        tableView?.estimatedRowHeight = 100
        tableView?.register(cellWithClass: PostDraftsItemCell.self)
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        tableView?.allowsMultipleSelection = false
        tableView?.allowsSelectionDuringEditing = false
        tableView?.allowsMultipleSelectionDuringEditing = false
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if drafts.count > 0 {
            let draft = drafts[indexPath.row]
            if draft.images.count > 0 {
                return 70
            } else {
                return UITableView.automaticDimension
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drafts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: PostDraftsItemCell.self)
        if drafts.count > 0 {
            cell.model = drafts[indexPath.row]
            
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectDraftsCompelet?(self.drafts[indexPath.row])
        self.dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.drafts.remove(at: indexPath.row)
            UserDefaults.sk.set(objects: self.drafts, for: PostDraftModel.className)
            self.editButton.isEnabled = drafts.count != 0
            self.tableView?.reloadData()
        }
    }

}


class PostDraftsItemCell: UITableViewCell {
    let contentLabel = UILabel()
    let imgView = UIImageView()
    var model:PostDraftModel = PostDraftModel() {
        didSet {
            if model.content.isEmpty {
                contentLabel.text = "Photo"
                contentLabel.textColor = .gray
            } else {
                contentLabel.text = model.content
                contentLabel.textColor = R.color.textColor22()!
            }
            
            if model.images.count > 0 {
                imgView.image = UIImage(base64String: model.images.first ?? "")
            } else {
                imgView.image = nil
            }
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(contentLabel)
        contentView.addSubview(imgView)
        
        contentLabel.textColor = R.color.textColor22()!
        contentLabel.font = UIFont.sk.pingFangRegular(15)
        contentLabel.numberOfLines = 0
        
        imgView.contentMode = .scaleAspectFill
        imgView.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            if self.model.images.count > 0 {
                make.right.equalToSuperview().offset(-82)
            } else {
                make.right.equalToSuperview().offset(-16)
            }
            
        }
        
        imgView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(54)
            make.centerY.equalToSuperview()
        }
    }
}
