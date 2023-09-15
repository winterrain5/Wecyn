//
//  HomeItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import UIKit
import ZLPhotoBrowser
class HomeItemCell: UITableViewCell {

    @IBOutlet weak var clvHConst: NSLayoutConstraint!
    @IBOutlet weak var imgContentView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
//    @IBOutlet weak var orgNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var repostButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
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
    
    var model:PostListModel? {
        didSet {
            guard let model = model else { return }
            avatarImgView.kf.setImage(with: model.user.avatar.url,placeholder: R.image.proile_user()!)
            userNameLabel.text = model.user.full_name
            contentLabel.text = model.content
            postTimeLabel.text = "Posted \(model.post_time) ago"
            headLineLabel.text = model.user.headline
//            likeLabel.text = model.like_count.string + " Likes"
//            repostedLabel.text = model.repost_count.string + " Reposted"
            
            var imgH:CGFloat = 0
            if model.images_obj.count == 0 {
                imgH = 0
            }
            if model.images_obj.count == 1 {
                imgH = model.images_obj.first?.heightForOneImage ?? 0
            }
            if model.images_obj.count > 1 {
                imgH = 160
            }
            clvHConst.constant = imgH
            self.setNeedsUpdateConstraints()
            self.layoutIfNeeded()
            
            followButton.isHidden = model.is_need_follow
            if let user = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className) {
                if user.id.int == model.user.id || !model.is_need_follow{
                    followButton.isHidden = true
                } else {
                    followButton.isHidden = false
                }
            }
            
            let action1 = UIAction(title:"Follow @\(model.user.full_name)",image: UIImage.person_fill_checkmark) { _ in
                Toast.showMessage("Function under development")
            }
            let action2 = UIAction(title:"Mute @\(model.user.full_name)",image: UIImage.speaker_slash) { _ in
                Toast.showMessage("Function under development")
            }
            let action3 = UIAction(title:"Block @\(model.user.full_name)",image: UIImage.slash_circle) { _ in
                Toast.showMessage("Function under development")
            }
            let action4 = UIAction(title:"Report post",image: UIImage.flag) { _ in
                Toast.showMessage("Function under development")
            }
            followButton.menu = UIMenu(children: [action1,action2,action3,action4])
            
            imageClvView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgContentView.addSubview(imageClvView)
        avatarImgView.isUserInteractionEnabled = true
        avatarImgView.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            let vc = PostUserInfoController(userId: model.user.id)
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        followButton.imageForNormal = UIImage.ellipsis?.withTintColor(.lightGray,renderingMode: .alwaysOriginal)
        followButton.showsMenuAsPrimaryAction  = true
        
        self.isSkeletonable = true
        self.contentView.isSkeletonable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageClvView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @IBAction func likeAction(_ sender: UIButton) {
        Haptico.selection()
        sender.isSelected.toggle()
        Toast.showMessage("Function under development")
    }
    
    @IBAction func commentAction(_ sender: Any) {
        Haptico.selection()
        Toast.showMessage("Function under development")
    }
    
    @IBAction func repostAction(_ sender: Any) {
        Haptico.selection()
        Toast.showMessage("Function under development")
    }
    
    
    @IBAction func sendAction(_ sender: Any) {
        Haptico.selection()
        Toast.showMessage("Function under development")
    }
    
    
    
    
    
}
extension HomeItemCell: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
                return CGSize(width: kScreenWidth - 32, height: height)
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
        0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let datas = model?.images.map({ $0.url }).compactMap({ $0 }) {
            let vc = ZLImagePreviewController(datas: datas,index: indexPath.item,showSelectBtn: false,showBottomView: false) { url -> ZLURLType in
                return .image
            } urlImageLoader: { url, imageView, progress, loadFinish in
                imageView.kf.setImage(with: url) { receivedSize, totalSize in
                    let percentage = (CGFloat(receivedSize) / CGFloat(totalSize))
                    debugPrint("\(percentage)")
                    progress(percentage)
                } completionHandler: { _ in
                    loadFinish()
                }
            }
            vc.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.frame = contentView.bounds
    }
}
