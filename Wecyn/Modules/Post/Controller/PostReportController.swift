//
//  PostReportController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/25.
//

import UIKit
import RxRelay
class PostReportModel:BaseModel {
    var title:String = ""
    var isSelect:Bool = false
}

class PostReportController: BaseTableController {
    var datas:[PostReportModel] = []
    var selected:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var type:Int = 1
    required init(type:Int) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == 1 {
            self.navigation.item.title = "Report title or image"
            let titles = ["Sexual content","Violent or repulsivecontent","Hateful or abusivecontent","Harmful or dangerousacts","Spam or misleading"]
            datas = titles.map({
                let model = PostReportModel()
                model.title = $0
                return model
            })
        } else {
            self.navigation.item.title = "Report comment"
            let titles = ["Unwanted commerciacontent or spam","Pornography or sexuallyexplicit material","Child abuse","Hate speech or graphicviolence","Promotes terrorism","Harassment or bullying","Suicide or self injury","Misinformation"]
            datas = titles.map({
                let model = PostReportModel()
                model.title = $0
                return model
            })
        }
        
        
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        let button = UIButton()
        button.titleForNormal = "Report"
        button.titleColorForNormal = R.color.theamColor()!
        button.titleLabel?.font = UIFont.sk.pingFangSemibold(15)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        selected.bind(to: button.rx.isEnabled).disposed(by: rx.disposeBag)
        button.rx.tap.subscribe(onNext:{ [weak self] in
            Toast.showMessage("Your report has been submitted")
            self?.returnBack()
        }).disposed(by: rx.disposeBag)
        
        self.tableView?.reloadData()
    }
    
    override func createListView() {
        configTableview(.insetGrouped)
        
        tableView?.rowHeight = 52
        tableView?.register(cellWithClass: UITableViewCell.self)
        
        tableView?.backgroundColor = R.color.backgroundColor()
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorStyle = .singleLine
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kBottomsafeAreaMargin + 40, right: 0)
        
    }
    
    override func listViewFrame() -> CGRect {
        return CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: self.view.height - kNavBarHeight)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        let model = datas[indexPath.row]
        cell.textLabel?.text = model.title
        cell.textLabel?.font = UIFont.sk.pingFangRegular(16)
        cell.textLabel?.textColor = R.color.textColor33()!
        
        cell.accessoryType = model.isSelect ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Haptico.selection()
        datas.forEach({ $0.isSelect = false })
        datas[indexPath.row].isSelect.toggle()
        selected.accept(true)
        tableView.reloadData()
        
     
    }
}
