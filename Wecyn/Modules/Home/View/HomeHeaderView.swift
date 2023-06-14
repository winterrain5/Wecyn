//
//  HomeHeaderView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import UIKit

class HomeHeaderView: UIView {
    @IBOutlet weak var createPostButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
     
        createPostButton.addShadow(cornerRadius: 5)
        searchContainer.addShadow(cornerRadius: 9)
        
        collectionView.register(nibWithCellClass: HomeHeaderJobItemCell.self)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 300, height: 96)
        layout.sectionInset = UIEdgeInsets(horizontal: 16, vertical: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}

extension HomeHeaderView: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: HomeHeaderJobItemCell.self, for: indexPath)
        return cell
    }
    
}
