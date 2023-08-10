//
//  ColorPickerController.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/8.
//

import UIKit

class ColorPickerModel {
    var color: String
    var isSelect: Bool = false
    init(color: String, isSelect: Bool = false) {
        self.color = color
        self.isSelect = isSelect
    }
}
class ColorPickerController: BaseTableController {
    var models: [ColorPickerModel] = []
    var selectColor:String?
    typealias Action = (String?) -> Void
    var action: Action?
    required init(selectColor:String? = nil, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        
        self.action = action
        self.selectColor = selectColor
        
        
        models.append(contentsOf:  EventColor.allColor.map({
            return ColorPickerModel(color: $0)
        }))
        models.forEach({
            $0.isSelect = $0.color == self.selectColor
        })
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func createListView() {
        configTableview(.insetGrouped)
        
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
        cell.imageView?.image = tintImage(model.color)
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
        
        self.selectColor = model.isSelect ? model.color : nil
        tableView.reloadData()
        
        Haptico.selection()
        
        self.action?(self.selectColor)
        returnBack()
    }
}
