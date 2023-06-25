//
//  ConnectionController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit

class ConnectionController: BaseCollectionController,UICollectionViewDelegateFlowLayout {
    var sectionTitle = ["People in IT services you may know ","People you may know from Company209","People you may know from Nanyang Polytechnic"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRightBarItems()
       
        refreshData()
    }
    
    override func refreshData() {
        
        FriendService.searchUserList().subscribe(onNext:{ models in
            self.dataArray.append(contentsOf: models)
            self.endRefresh(models.count,emptyString: "No Data")
        }).disposed(by: rx.disposeBag)
        
    }

    
    override func createListView() {
        super.createListView()
        
//        registRefreshHeader(colorStyle: .gray)
        
        let headerView = ConnectionHeaderView()
        collectionView?.addSubview(headerView)
        headerView.frame = CGRect(x: 0, y: -80, width: kScreenWidth, height: 80)

        collectionView?.register(nibWithCellClass: ConnectionItemCell.self)
        
        collectionView?.register(ConnectionSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:ConnectionSectionHeaderView.className)
        collectionView?.register(ConnectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier:ConnectionFooterView.className)
        
        collectionView?.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: kTabBarHeight + 10, right: 0)
        collectionView?.showsVerticalScrollIndicator = false
        
    }
    
    override func listViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let itemW:CGFloat = (kScreenWidth - 32) / 2
        let itemH:CGFloat = itemW * 1.2
        layout.itemSize = CGSize(width: itemW, height: itemH)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ConnectionItemCell.self, for: indexPath)
        if self.dataArray.count > 0 {
            let model = self.dataArray[indexPath.row] as! FriendUserInfoModel
            cell.model = model
        }
        return cell
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        if kind == UICollectionView.elementKindSectionHeader {
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withClass: ConnectionSectionHeaderView.self, for: indexPath)
//            headerView.title = sectionTitle[indexPath.section]
//            return headerView
//        } else if kind == UICollectionView.elementKindSectionFooter {
//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withClass: ConnectionFooterView.self, for: indexPath)
//            footerView.viewMoreHandler = {
//                let vc = ConnectionRecommendController(title: self.sectionTitle[indexPath.section])
//                self.navigationController?.pushViewController(vc)
//            }
//            return footerView
//        }
//
//        return UICollectionReusableView()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.frame.size.width, height: 40)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.frame.size.width, height: 40)
//    }
    
}

class ConnectionHeaderView:UIView {
    let label1 = UILabel().text("My Connections(52)")
        .color(R.color.textColor162C46()!)
        .font(UIFont.sk.pingFangSemibold(16))
    
    let label2 = UILabel().text("Groups(52)")
        .color(R.color.textColor162C46()!)
        .font(UIFont.sk.pingFangSemibold(16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        label1.sk.setSpecificTextUnderLine("My Connections", color: R.color.textColor162C46()!)
        label1.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(ConnectionOfMyController())
        }).disposed(by: rx.disposeBag)
        addSubview(label1)
       
        
       
        label2.sk.setSpecificTextUnderLine("Groups", color: R.color.textColor162C46()!)
        label2.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            //            self.navigationController?.pushViewController(JobSavedController())
        }).disposed(by: rx.disposeBag)
        addSubview(label2)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(16)
        }
        label2.snp.makeConstraints { make in
            make.left.equalTo(label1.snp.left)
            make.top.equalTo(label1.snp.bottom).offset(8)
        }
    }
    
}


class ConnectionSectionHeaderView: UICollectionReusableView {
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    private let titleLabel = UILabel().then {
        $0.font = UIFont.sk.pingFangSemibold(15)
        $0.textColor = R.color.textColor162C46()!
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(titleLabel)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(21)
        }
        
    }
}

class ConnectionFooterView: UICollectionReusableView {
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 15)
        $0.textColor = R.color.textColor52()!
        $0.text = "View more"
    }
    var viewMoreHandler: (()->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.sk.addBorderBottom(borderWidth: 1, borderColor: R.color.textColor52()!)
        titleLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            self?.viewMoreHandler?()
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(25)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
        
        
    }
}
