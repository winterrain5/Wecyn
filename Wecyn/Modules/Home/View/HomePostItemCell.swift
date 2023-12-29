//
//  HomePostItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/22.
//

import UIKit
import SKPhotoBrowser
import AVFoundation
import AVKit
import Cache
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
        contentLabel.skeletonTextLineHeight = .fixed(18)
        contentLabel.lastLineFillPercent = 75
        contentLabel.skeletonTextNumberOfLines = 4
        
        self.isSkeletonable = true
        contentView.isSkeletonable  = true
        contentView.subviews.forEach({ $0.isSkeletonable = true })
        contentView.clipsToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       
        
        userInfoView.frame = CGRect(x: 0, y: 0, width: self.width, height: 60)
        
        if let contentH = model?.contentH {
            contentLabel.frame = CGRect(x: 16, y: userInfoView.frame.maxY + 8, width: self.width - 32, height: contentH)
        } else {
            contentLabel.frame = CGRect(x: 16, y: userInfoView.frame.maxY + 8, width: self.width - 32, height: 80)
        }
        
        if model?.video.isEmpty ?? false {
            if (model?.images_obj.count ?? 0) > 0 {
                imageClvView.frame = CGRect(x: 0, y: contentLabel.frame.maxY + 8, width: self.width, height: model?.imgH ?? 0)
            } else {
                imageClvView.frame = .zero
            }
        } else {
            imageClvView.frame = CGRect(x: 0, y: contentLabel.frame.maxY + 8, width: self.width, height: model?.imgH ?? 0)
        }
        
       
        
        if model?.source_data != nil {
            postQuoteView.frame = CGRect(x: 16, y: max(imageClvView.frame.maxY, contentLabel.frame.maxY) + 8, width: self.width - 32, height: model?.sourceDataContentH ?? 0)
        } else {
            postQuoteView.frame = .zero
        }
        
        footerView.frame = CGRect(x: 16, y: max(imageClvView.frame.maxY, postQuoteView.frame.maxY, contentLabel.frame.maxY) + 8, width: self.width - 32, height: 30)
        
    }
}
extension HomePostItemCell: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (model?.video.isEmpty ?? false) ? model?.images.count ?? 0 : 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: HomeItemImageCell.self, for: indexPath)
        if let count = model?.images_obj.count, count  > 0,indexPath.item < count {
            cell.setPlayButtonStatus(true)
            cell.imgView.kf.setImage(with: model?.images_obj[indexPath.item].url.url)
        } else if !(model?.video.isEmpty ?? false) {
            cell.setPlayButtonStatus(false)
            cell.imgView.image = nil
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !(model?.video.isEmpty ?? false) {
            let imgCell = cell as! HomeItemImageCell
            getVideoThumbnaiImage(model?.video ?? "") { image in
                imgCell.imgView.image = image
                imgCell.imgView.fadeIn()
                imgCell.setPlayButtonStatus(false)
            }
        }
    }
    func getVideoThumbnaiImage(_ video:String,complete:@escaping (UIImage?)->()) {
        if let image = PostImageCache.shared.getImage(for: model?.id.string ?? "") {
            complete(image)
            return
        }
        var image:UIImage?
        Asyncs.async(task: {
            image = video.url?.thumbnail()
        }, mainTask: {
            
            if let image = image {
                PostImageCache.shared.setImage(image: image, key: self.model?.id.string ?? "")
            }
       
            complete(image)
        })
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
        } else if !(model?.video.isEmpty ?? false) {
            return model?.video_thumbnail_image_size ?? .zero
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
        if model?.images_obj.count ?? 0 > 0 {
            if let datas = model?.images_obj.map({ SKPhoto.photoWithImageURL($0.url) }).compactMap({ $0 }) {
                let cell = collectionView.cellForItem(at: indexPath) as! HomeItemImageCell
                let originImage = cell.imgView.image
                let browser = SKPhotoBrowser(originImage: originImage ?? UIImage(), photos: datas, animatedFromView: cell)
                browser.initializePageIndex(indexPath.row)
                UIViewController.sk.getTopVC()?.present(browser, animated: true, completion: {})
            }
        }
        if !(model?.video.isEmpty ?? false) {
            guard let url = model?.video.url else { return }
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            let controller = AVPlayerViewController()
            let player = AVPlayer(url: url)
            player.playImmediately(atRate: 1)
            controller.player = player
            UIViewController.sk.getTopVC()?.present(controller, animated: true)
        }
    }
    
}


class HomeItemImageCell:UICollectionViewCell {
    let imgView = UIImageView()
    let playButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imgView)
        imgView.contentMode = .scaleAspectFill
        contentView.cornerRadius = 8
        imgView.backgroundColor = R.color.backgroundColor()!
        
        contentView.addSubview(playButton)
        playButton.imageForNormal = R.image.playCircleFill()
        playButton.alpha = 0
        playButton.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.frame = contentView.bounds
        
        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
    }
    
    func setPlayButtonStatus(_ isHidden:Bool) {
        if isHidden  {
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.playButton.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.playButton.alpha = 1
            }
        }
    }
}


class PostImageCache {
    static let shared = PostImageCache()
    var storage:Storage<String,Image>?
    init() {
        let diskConfig = DiskConfig(name: "Post",expiry: .seconds(7 * 24 * 60 * 60))
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 100, totalCostLimit: 100)
        storage = try? Storage<String, Image>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forImage())
    }
    
    func setImage(image:Image,key:String) {
        try? storage?.setObject(image, forKey: key)
    }
    func getImage(for key:String) -> Image?{
        try? storage?.object(forKey: key)
    }
}
