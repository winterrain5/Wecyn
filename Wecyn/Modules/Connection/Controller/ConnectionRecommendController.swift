//
//  ConnectionRecommendController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/16.
//

import UIKit


class ConnectionRecommendController: BaseCollectionController,UICollectionViewDelegateFlowLayout {
    var sectionTitle:String = ""
    init(title:String) {
        super.init(nibName: nil, bundle: nil)
        self.sectionTitle = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.bar.prefersLargeTitles = true
        self.navigation.item.largeTitleDisplayMode = .automatic
        self.navigation.item.title = "Recommendations"
    }

    override func createListView() {
        super.createListView()
        
        collectionView?.register(nibWithCellClass: ConnectionItemCell.self)
        
        collectionView?.register(ConnectionSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:ConnectionSectionHeaderView.className)
        
        collectionView?.contentInset = UIEdgeInsets(top: 62, left: 0, bottom: kBottomsafeAreaMargin, right: 0)
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


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ConnectionItemCell.self, for: indexPath)
        return cell
    }
    
    
      func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

          if kind == UICollectionView.elementKindSectionHeader {
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withClass: ConnectionSectionHeaderView.self, for: indexPath)
              headerView.title = sectionTitle
              return headerView
          }
          return UICollectionReusableView()
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
          return CGSize(width: collectionView.frame.size.width, height: 40)
      }

}
