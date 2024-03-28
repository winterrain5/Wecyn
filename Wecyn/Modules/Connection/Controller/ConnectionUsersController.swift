//
//  ConnectionController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit
import IQKeyboardManagerSwift
class ConnectionUsersController: BaseCollectionController,UICollectionViewDelegateFlowLayout {
    var sectionTitle = ["People in IT services you may know ","People you may know from Company209","People you may know from Nanyang Polytechnic"]
    
    let searchView = NavbarSearchView(placeholder: "Search by name",isSearchable: true,isBecomeFirstResponder: true).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
    
    var searchResults:[FriendUserInfoModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.navigation.item.titleView = searchView
        
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.searchResults = (self.dataArray as? [FriendUserInfoModel])?.filter({  $0.first_name.lowercased().contains(keyword.trimmed.lowercased()) ||
                $0.last_name.lowercased().contains(keyword.trimmed.lowercased()) ||
                $0.full_name.lowercased().contains(keyword.trimmed.lowercased()) }) ?? []
            self.reloadData()
            searchView.endSearching()
        }
        
        searchView.beginSearch = { [weak self] in
            guard let `self` = self else { return }
            self.searchResults = []
            self.reloadData()
        }
        
        loadNewData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
    
    override func refreshData() {
        showSkeleton()
        NetworkService.searchUserList().subscribe(onNext:{ models in
            self.dataArray.append(contentsOf: models)
            self.endRefresh(models.count,emptyString: "No Data")
            self.hideSkeleton()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
        
    }

    
    override func createListView() {
        super.createListView()
        
        collectionView?.isSkeletonable = true
        cellIdentifier = ConnectionItemCell.className
        registRefreshHeader(colorStyle: .gray)
        collectionView?.register(nibWithCellClass: ConnectionItemCell.self)
        
        collectionView?.register(ConnectionSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:ConnectionSectionHeaderView.className)
        collectionView?.register(ConnectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier:ConnectionFooterView.className)
        
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
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
        return self.searchResults.count == 0 ? self.dataArray.count : self.searchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ConnectionItemCell.self, for: indexPath)
        if self.searchResults.count > 0 {
            let model = self.searchResults[indexPath.row]
            cell.model = model
        } else {
            let model = self.dataArray[indexPath.row] as? FriendUserInfoModel
            cell.model = model
        }
        
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
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



class ConnectionSectionHeaderView: UICollectionReusableView {
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    private let titleLabel = UILabel().then {
        $0.font = UIFont.sk.pingFangSemibold(15)
        $0.textColor = R.color.textColor22()!
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
        $0.textColor = R.color.textColor33()!
        $0.text = "View more"
    }
    var viewMoreHandler: (()->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.sk.addBorderBottom(borderWidth: 1, borderColor: R.color.textColor33()!)
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
