//
//  JobController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit

class JobController: BaseTableController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
        addRightBarItems()
    }
    
    func setupNavigationBar() {
        let label = UILabel().text("My Saved Jobs").color(R.color.textColor22()!).font(UIFont.sk.pingFangSemibold(20))
        label.sk.setSpecificTextUnderLine("My Saved Jobs", color: R.color.textColor22()!)
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: label)
        label.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            self.navigationController?.pushViewController(JobSavedController())
        }).disposed(by: rx.disposeBag)
    }

    override func createListView() {
        super.createListView()
        
        tableView?.register(nibWithCellClass: JobItemCell.self)
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        tableView?.rowHeight = 200
        
        let headView = TitleHeaderView(fontSize: 14,title:"Jobs Recommended for you")
        headView.size = CGSize(width: kScreenWidth, height: 60)
        tableView?.tableHeaderView = headView
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: JobItemCell.self)
        return cell
    }

}

class TitleHeaderView: UIView {
    private let label = UILabel().then { label in
        label.textColor = R.color.textColor22()
        label.numberOfLines = 0
    }
    
    private var fontSize:CGFloat = 14
    private var title = ""
    
    convenience init(fontSize:CGFloat,title: String) {
        self.init(frame: .zero)
        self.fontSize = fontSize
        self.title = title
        label.font = UIFont.sk.pingFangSemibold(fontSize)
        label.text =  title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.bottom.equalToSuperview().inset(12)
        }
    }
}
