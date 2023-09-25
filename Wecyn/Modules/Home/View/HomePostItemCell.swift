//
//  HomePostItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/22.
//

import UIKit
import SKPhotoBrowser
class HomePostItemCell: UITableViewCell {
    var userInfoView = HomePostUserInfoView()
    var footerView = HomePostFootToolView()
    var postQuoteView = PostQuoteView()
    var model:PostListModel?  {
        didSet {
            userInfoView.postModel = model
            footerView.postModel = model
            postQuoteView.postModel = model?.source_data
            contentLabel.text = model?.content 
            imageClvView.reloadData()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    lazy var imageClvView:UICollectionView  = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(cellWithClass: HomeItemImageCell.self)
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        return view
    }()
    var contentLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userInfoView)
        contentView.addSubview(footerView)
        contentView.addSubview(imageClvView)
        contentView.addSubview(postQuoteView)
        contentView.addSubview(contentLabel)
        
        contentLabel.font = UIFont.sk.pingFangRegular(15)
        contentLabel.textColor = R.color.textColor33()!
        contentLabel.numberOfLines = 0
        
        self.isSkeletonable = true
        contentView.isSkeletonable  = true
        contentView.subviews.forEach({ $0.isSkeletonable = true })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let model = model else { return }
        
        userInfoView.frame = CGRect(x: 0, y: 0, width: self.width, height: 60)
        
        contentLabel.frame = CGRect(x: 16, y: userInfoView.frame.maxY + 8, width: self.width - 32, height: model.contentH)
        
        if model.images_obj.count > 0 {
            imageClvView.isHidden = false
            imageClvView.frame = CGRect(x: 0, y: contentLabel.frame.maxY + 8, width: self.width, height: model.imgH)
        } else {
            imageClvView.isHidden = true
            imageClvView.frame = .zero
        }
        
        if model.source_data != nil {
            postQuoteView.isHidden = false
            postQuoteView.frame = CGRect(x: 16, y: max(imageClvView.frame.maxY, contentLabel.frame.maxY) + 8, width: self.width - 32, height: model.sourceDataH)
        } else {
            postQuoteView.isHidden = true
            postQuoteView.frame = .zero
        }
        
        footerView.frame = CGRect(x: 16, y: max(imageClvView.frame.maxY, postQuoteView.frame.maxY, contentLabel.frame.maxY) + 8, width: self.width - 32, height: 30)
        
    }
}
extension HomePostItemCell: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.images.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: HomeItemImageCell.self, for: indexPath)
        if let count = model?.images_obj.count, count  > 0,indexPath.item < count {
            cell.imgView.kf.setImage(with: model?.images_obj[indexPath.item].url.url)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let imageObjects = model?.images_obj, imageObjects.count > 0,indexPath.item < imageObjects.count {
            let image = imageObjects[indexPath.item]
            if imageObjects.count  == 1 {
                let height = image.heightForOneImage
                return CGSize(width: kScreenWidth - 32, height: height.floor)
            }
            if imageObjects.count > 1 {
                let width = image.widhtForMoreThanOneImage
                return CGSize(width: width , height: 160)
            }
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let datas = model?.images_obj.map({ SKPhoto.photoWithImageURL($0.url) }).compactMap({ $0 }) {
            let cell = collectionView.cellForItem(at: indexPath) as! HomeItemImageCell
            let originImage = cell.imgView.image
            let browser = SKPhotoBrowser(originImage: originImage ?? UIImage(), photos: datas, animatedFromView: cell)
            browser.initializePageIndex(indexPath.row)
            UIViewController.sk.getTopVC()?.present(browser, animated: true, completion: {})
        }
       
    }
    
}


class HomeItemImageCell:UICollectionViewCell {
    let imgView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imgView)
        imgView.contentMode = .scaleAspectFill
        contentView.cornerRadius = 8
        imgView.backgroundColor = R.color.backgroundColor()!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.frame = contentView.bounds
    }
}
