//
//  ColorPickerView.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/12.
//

import UIKit
import EntryKit
class ColorPickerModel {
    var img:UIImage
    var title:String
    var color:String
    var isSelect = false
    init(img:UIImage, title:String, color:String) {
        self.img = img
        self.title = title
        self.color = color
    }
}
class ColorPickerView: UIView,UITableViewDataSource,UITableViewDelegate {
  

    typealias Action = (String?) -> Void
    
    var action: Action?
    
    var tableView = UITableView()
    var contentView = UIView()
    var confirmButton = UIButton()
    var titlelabel = UILabel()
    
    var models: [ColorPickerModel] = []
    var selectColor:String?
    
    required init(selectColor:String? = nil, action: Action?) {
        super.init(frame: .zero)
        
        self.action = action
        self.selectColor = selectColor
        
        addSubview(confirmButton)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(.black, for: .normal)
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        confirmButton.cornerRadius = 16
        confirmButton.backgroundColor = .white
        confirmButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.action?(self.selectColor)
            Haptico.selection()
            EntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
        addSubview(contentView)
        contentView.cornerRadius = 20
        contentView.backgroundColor = .white
        
        contentView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = R.color.backgroundColor()!
        tableView.register(cellWithClass: UITableViewCell.self)
       
   
        /*
         #149bd0

         #1463d0

         #21a93c

         #ed8c00

         #d82739
         */
        let c1 = ColorPickerModel(img: R.image.tagFill1()!, title: "light blue", color: EventColor.LightBlue.rawValue)
        let c2 = ColorPickerModel(img: R.image.tagFill2()!, title: "dark blue", color: EventColor.DarkBlue.rawValue)
        let c3 = ColorPickerModel(img: R.image.tagFill3()!, title: "green", color: EventColor.Green.rawValue)
        let c4 = ColorPickerModel(img: R.image.tagFill4()!, title: "yellow", color: EventColor.Yellow.rawValue)
        let c5 = ColorPickerModel(img: R.image.tagFill5()!, title: "red", color: EventColor.Red.rawValue)
        
        models.append(contentsOf: [c1,c2,c3,c4,c5])
        models.forEach({
            $0.isSelect = $0.color == self.selectColor
        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let tableH = models.count * 50
        confirmButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(kBottomsafeAreaMargin + 20)
            make.height.equalTo(60)
        }

        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalTo(confirmButton.snp.top).offset(-16)
            make.height.equalTo(tableH + 32)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(tableH)
        }
    }
    
    func show() {
        let height = (models.count * 50).cgFloat + 32 +  80 + kBottomsafeAreaMargin
        EntryKit.display(view: self, size: CGSize(width: kScreenWidth, height: height), style: .sheet, touchDismiss: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        let model = models[indexPath.row]
        cell.imageView?.image = model.img
        cell.textLabel?.text = model.title
        cell.accessoryType = model.isSelect ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        models.forEach({ $0.isSelect = false })
        
        let model = models[indexPath.row]
        model.isSelect.toggle()
        
        self.selectColor = model.isSelect ? model.color : nil
        tableView.reloadData()
        
        Haptico.selection()
        
    }
 
}

