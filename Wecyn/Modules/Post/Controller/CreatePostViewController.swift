//
//  CreatePostViewController.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/18.
//

import UIKit
import RxKeyboard
import KMPlaceholderTextView
import IQKeyboardManagerSwift
import ZLPhotoBrowser
class CreatePostViewController: BaseViewController {

    var toolBar = CreatePostToolBar.loadViewFromNib()
    var textView = KMPlaceholderTextView()
    lazy var imageClvView:UICollectionView  = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(cellWithClass: CreatePostImageCell.self)
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        return view
    }()
    let toolBarH = 44.cgFloat
    var addedImages:[ZLResultModel] = []
    var isOriginal = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.bar.shadowImage = UIImage(color: R.color.backgroundColor()!, size: CGSize(width: kScreenWidth, height: 1))

        let config = ZLPhotoConfiguration.default()
        config.allowSelectImage = true
        config.allowSelectVideo = true
        config.allowSelectGif = false
        config.allowSelectLivePhoto = false
        config.allowSelectOriginal = false
        config.cropVideoAfterSelectThumbnail = true
        config.allowEditVideo = true
        config.allowMixSelect = true
        config.maxSelectCount = 9 - self.addedImages.count
        config.maxSelectVideoDuration = 30
        
        ZLPhotoUIConfiguration.default().themeColor = R.color.theamColor()!
        
        self.addLeftBarButtonItem(image: R.image.xmark())
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        let saveButton = UIButton()
        saveButton.size = CGSize(width: 50, height: 30)
        saveButton.titleForNormal = "Post"
        saveButton.titleColorForNormal = .white
        saveButton.titleLabel?.font = UIFont.sk.pingFangSemibold(14)
        saveButton.cornerRadius = 15
        saveButton.backgroundColor = R.color.theamColor()
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
           
            
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        
        
        RxKeyboard.instance.visibleHeight.drive(onNext:{ [weak self] keyboardVisibleHeight in
            guard let `self` = self else { return }
            self.toolBar.frame.origin.y = kScreenHeight - keyboardVisibleHeight - self.toolBarH
        }).disposed(by: rx.disposeBag)
        
        self.view.addSubview(textView)
        textView.placeholder = "Input something"
        textView.font = UIFont.sk.pingFangRegular(16)
        textView.frame = CGRect(x: 16, y: kNavBarHeight, width: kScreenWidth - 32, height: 120)
        textView.becomeFirstResponder()
        
        self.view.addSubview(imageClvView)
        imageClvView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.textView.snp.bottom).offset(16)
            make.height.equalTo(180)
        }
        
        self.view.addSubview(toolBar)
        toolBar.frame = CGRect(x: 0, y: kScreenHeight - toolBarH, width: kScreenWidth, height: toolBarH)
        toolBar.imageButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            
           
            let ps = ZLPhotoPreviewSheet()
            ps.selectImageBlock = { results, isOriginal in
                self.addedImages.append(contentsOf: results)
                self.isOriginal = isOriginal
                self.imageClvView.reloadData()
            }
            ps.showPhotoLibrary(sender: self)
           
        }).disposed(by: rx.disposeBag)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
    



}

extension CreatePostViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addedImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: CreatePostImageCell.self, for: indexPath)
        if addedImages.count > 0 {
            cell.result = addedImages[indexPath.item]
            cell.deleteItemHandler = { [weak self] result in
                self?.addedImages.removeAll(where: { $0 == result })
                self?.imageClvView.reloadItems(at: [IndexPath(item: self?.addedImages.firstIndex(of: result) ?? 0, section: 0)])
            }
            cell.editItemHandler = { [weak self] result in
                
                if result.asset.mediaType == .video {
                    let _ = ZLPhotoManager.fetchAVAsset(forVideo: result.asset) { avAsset, _ in
                        guard let avAsset = avAsset else {
                            return
                        }
                        let vc = ZLEditVideoViewController(avAsset: avAsset)
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true)
                        vc.editFinishBlock = { url in
                            if let url = url {
                                ZLPhotoManager.saveVideoToAlbum(url: url) { suc, asset in
                                    if suc, asset != nil {
                                        let temp = ZLResultModel(asset: asset!, image: result.image, isEdited: true, editModel: result.editModel, index: result.index)
                                        self?.addedImages.replaceSubrange(temp.index..<temp.index+1, with: [temp])
                                        self?.imageClvView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                   
                } else {
                    ZLEditImageViewController.showEditImageVC(parentVC: self,animate: true, image: result.image,editModel: result.editModel) { image, editModel in
                        let temp = ZLResultModel(asset: result.asset, image: image, isEdited: true, editModel: editModel, index: result.index)
                        self?.addedImages.replaceSubrange(temp.index..<temp.index+1, with: [temp])
                        self?.imageClvView.reloadData()
                    }
                   
                }
            }
            
        
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addedImages.count > 0 {
            return addedImages[indexPath.item].image.scaled(toHeight: 180)?.size ?? .zero
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ZLPhotoPreviewSheet()
        
        vc.selectImageBlock = { [weak self] results, isOriginal in
            guard let `self` = self else { return }
            self.addedImages = results
            self.isOriginal = isOriginal
            self.imageClvView.reloadData()
        }
        
        vc.previewAssets(sender: self, assets: addedImages.map({ $0.asset }), index: indexPath.row, isOriginal: isOriginal, showBottomViewAndSelectBtn: true)
    }
    
}

class CreatePostImageCell: UICollectionViewCell {
    var imageView = UIImageView()
    
    var deleteButton = UIButton()
    var editButton = UIButton()
    var playButton = UIButton()
    var durationLabel = UILabel()
    var durationW:CGFloat = 0
    var result:ZLResultModel? {
        didSet {
            imageView.image = result?.image
            playButton.isHidden = result?.asset.mediaType != .video
            durationLabel.isHidden = result?.asset.mediaType != .video
            durationLabel.text = "\(result?.asset.duration.int.string ?? "")s"
            durationW = durationLabel.text?.getWidthWithLabel(font: UIFont.sk.pingFangRegular(12)) ?? 0
            self.setNeedsUpdateConstraints()
            self.layoutIfNeeded()
        }
    }
    
    
    var deleteItemHandler:((ZLResultModel)->())?
    var editItemHandler:((ZLResultModel)->())?
    var playItemHandler:((ZLResultModel)->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(deleteButton)
        deleteButton.imageForNormal = R.image.post_picture_delete()
        contentView.cornerRadius = 8
        
        contentView.addSubview(playButton)
        playButton.imageForNormal = R.image.playCircleFill()
        playButton.isHidden = true
        playButton.isUserInteractionEnabled = false
        
        contentView.addSubview(durationLabel)
        durationLabel.textColor = .white
        durationLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        durationLabel.cornerRadius = 4
        durationLabel.font = UIFont.sk.pingFangRegular(12)
        durationLabel.textAlignment = .center
        
        contentView.addSubview(editButton)
        editButton.imageForNormal = R.image.paintbrushPointed()?.scaled(toHeight: 12)
        editButton.cornerRadius = 12
        editButton.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        
        deleteButton.rx.tap.subscribe(onNext:{ [weak self] in
            
            guard let result = self?.result else { return }
            self?.deleteItemHandler?(result)
            
        }).disposed(by: rx.disposeBag)
        
        editButton.rx.tap.subscribe(onNext:{ [weak self] in
            
            guard let result = self?.result else { return }
            self?.editItemHandler?(result)
            
        }).disposed(by: rx.disposeBag)
        
        playButton.rx.tap.subscribe(onNext:{ [weak self] in
            
            guard let result = self?.result else { return }
            self?.playItemHandler?(result)
            
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        deleteButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(6)
            make.width.height.equalTo(24)
        }
        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
     
        editButton.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().inset(6)
            make.width.height.equalTo(24)
        }
        
        durationLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().inset(6)
            make.centerY.equalTo(editButton.snp.centerY)
            make.width.equalTo(durationW + 6)
        }
    }
}
