//
//  ColorPickerController.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/8.
//

import UIKit
import IQKeyboardManagerSwift
import RxLocalizer
class ColorPickerModel {
    var color: String
    var remark: String
    var isSelect: Bool = false
    var isAllowEdit = false
    init(color: String, remark: String = "" ,isSelect: Bool = false,isAllowEdit: Bool = false) {
        self.color = color
        self.isSelect = isSelect
        self.remark = remark
        self.isAllowEdit = isAllowEdit
    }
}
class ColorPickerController: BaseTableController {
    var models: [ColorPickerModel] = []
    var selectColor:String?
    typealias Action = (String?,String?) -> Void
    var action: Action?
    var isAllowEdit = false
    required init(selectColor:String? = nil, isAllowEdit:Bool = false, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        
        self.action = action
        self.isAllowEdit = isAllowEdit
        self.selectColor = selectColor
        
        configData()
    }
    
    func configData() {
        
        var colorRemark:[String] = []
        
        if isAllowEdit {
            colorRemark = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.color_remark ?? []
        } else {
            if let assistantColorRemark = UserDefaults.sk.value(for: "AssistantColorRemark") as?  [String],!assistantColorRemark.isEmpty{
                colorRemark = assistantColorRemark
            } else  {
                colorRemark = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.color_remark ?? []
            }
        }
        
        self.models.append(contentsOf:  EventColor.allColor.map({
            return ColorPickerModel(color: $0,isAllowEdit: self.isAllowEdit)
        }))
        self.models.forEach({
            $0.isSelect = $0.color == self.selectColor
        })
        
        if colorRemark.isEmpty {
            colorRemark = Array(repeating: "", count: 12)
        }
        
        self.models.enumerated().forEach { i,e in
            e.remark = colorRemark[i]
        }
        
        self.tableView?.reloadData()
    }
    
    func updateRemark() {
        let request = UpdateUserInfoRequestModel()
        guard let user = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className) else {
            return
        }
        
        Mirror(reflecting: UpdateUserInfoRequestModel()).children.forEach { child in
            guard let key = child.label else { return }
            request.setValue(user.value(forKey: key), forKey: key)
        }
        
        request.color_remark = models.map({ $0.remark })
        
        UserService.updateUserInfo(model: request).subscribe(onNext:{
            if $0.success == 1 {
                user.color_remark = request.color_remark
                UserDefaults.sk.set(object: user, for: UserInfoModel.className)
            } else {
                Toast.showError($0.message)
            }
        },onError: { e in
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: self.rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enableAutoToolbar = true
        if isAllowEdit {
            self.navigation.item.title =  Localizer.shared.localized("Color Remark")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func createListView() {
        configTableview(.insetGrouped)
        
        tableView?.backgroundColor = R.color.backgroundColor()!
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()!
        tableView?.register(cellWithClass: ColorPickerCell.self)
        
        
    }
    
    override func listViewFrame() -> CGRect {
        if self.isAllowEdit {
            return CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        } else {
            return  CGRect(x: 0, y: 0, width: kScreenWidth, height: self.view.height)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ColorPickerCell.self)
        let model = models[indexPath.row]
        
        cell.model = model
        cell.accessoryType = model.isSelect ? .checkmark : .none
        cell.editDone = { [weak self] in
            self?.tableView?.reloadData()
            
            self?.updateRemark()
        }
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
        
        self.selectColor = model.isSelect ? model.color : nil
        tableView.reloadData()
        
        Haptico.selection()
        
        self.action?(self.selectColor,model.remark)
        returnBack()
    }
}

class ColorPickerCell:  UITableViewCell,UITextFieldDelegate  {
    let imgView = UIImageView()
    var input = UITextField()
    var editDone: (()->())?
    var model: ColorPickerModel! {
        didSet {
            imgView.image = R.image.tagFill()?.tintImage(UIColor(hexString: model.color)  ?? .red)
            input.text = model.remark
            input.isUserInteractionEnabled = model.isAllowEdit
            input.placeholder = model.isAllowEdit ? "remark" : ""
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(imgView)
        imgView.contentMode = .scaleAspectFit
        
        contentView.addSubview(input)
        input.returnKeyType = .done
        input.delegate = self
       
        input.textColor = R.color.textColor33()
        input.font = UIFont.systemFont(ofSize: 15)
        input.rx.controlEvent(.editingChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
           
            self.model.remark = self.input.text ?? ""
        }).disposed(by: rx.disposeBag)
        
        input.rx.controlEvent(.editingDidEnd).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if self.input.text?.count ?? 0  > 20 {
                Toast.showWarning("Maximum word limit reached")
            } else {
                self.editDone?()
                self.input.isEnabled = true
            }
            
        }).disposed(by: rx.disposeBag)
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
        
        input.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(150)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        editDone?()
        return true
        
    }
}
