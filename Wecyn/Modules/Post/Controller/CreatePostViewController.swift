//
//  CreatePostViewController.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/18.
//

import UIKit
import Foundation
import MobileCoreServices
import RxKeyboard
import KMPlaceholderTextView
import IQKeyboardManagerSwift
import ZLPhotoBrowser
import WordPressEditor
import Aztec
enum PostType:Int {
    case Public = 1
    case OnlyFans = 2
    case OnlySelf = 3
    
    var description:String {
        switch self {
        case .Public:
            return "Public"
        case .OnlyFans:
            return "Visible only to yourself"
        case .OnlySelf:
            return "Visible only to followers"
        }
    }
}
class CreatePostViewController: BaseViewController {

    var toolBar = CreatePostToolBar.loadViewFromNib()
//    var richTextView:Aztec.TextView = {
//        let view = TextView.init(defaultFont: UIFont.sk.pingFangRegular(16), defaultMissingImage: EditorDemoController.tintedMissingImage)
//        return view
//    }()
    var richTextView = KMPlaceholderTextView()
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
    let toolBarH = 44.cgFloat  + UIDevice.bottomSafeAreaMargin
    var addedImages:[ZLResultModel] = []
    var isOriginal = true
    var postType:PostType = .Public
    let postTypeButton = UIButton()
    let saveButton = LoadingButton()
    let scrollView = UIScrollView()
    var addCompleteHandler:((PostListModel)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.bar.shadowImage = UIImage(color: R.color.backgroundColor()!, size: CGSize(width: kScreenWidth, height: 1))

        let config = ZLPhotoConfiguration.default()
        config.allowSelectImage = true
        config.allowSelectVideo = false
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
        
        
        saveButton.size = CGSize(width: 50, height: 30)
        saveButton.titleForNormal = "Post"
        saveButton.titleColorForNormal = .white
        saveButton.titleLabel?.font = UIFont.sk.pingFangSemibold(14)
        saveButton.cornerRadius = 15
        saveButton.backgroundColor = R.color.theamColor()
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            self.saveButton.startAnimation()
            self.addPost()
            
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        self.view.addSubview(scrollView)
        scrollView.frame = self.view.bounds
        
        scrollView.addSubview(postTypeButton)
        postTypeButton.titleForNormal = "Public "
        postTypeButton.imageForNormal = R.image.post_type_down()!
        postTypeButton.titleLabel?.font = UIFont.sk.pingFangRegular(12)
        postTypeButton.titleColorForNormal = R.color.theamColor()!
        postTypeButton.borderColor = R.color.theamColor()!
        postTypeButton.cornerRadius = 12
        postTypeButton.borderWidth = 1
        postTypeButton.frame = CGRect(x: 16, y:  16, width: 80, height: 24)
        postTypeButton.sk.setImageTitleLayout(.imgRight)
        postTypeButton.showsMenuAsPrimaryAction = true
        
        func remakeConstraints(type:PostType){
            self.postType = type
            self.postTypeButton.titleForNormal = type.description + " "
            self.postTypeButton.frame.size.width = type == .Public ? 80 : 180
            
        }
        
        var menuData: [(String, [(String, UIImage?)])] {
            return [
                ("PostType", [
                    (title: "Public", image: nil),
                    (title: "Visible only to yourself", image: nil),
                    (title: "Visible only to followers", image: nil),
                    ]
                )
            ]
        }
        
       let menu = UIMenu.map(data: menuData, handler: { [weak self] action in
           guard let `self` = self else { return }
           action.handleStateChange(self.postTypeButton, section: 0, isSingleChoose: true) {
               let index = self.postTypeButton.checkRow(by: 0)
               switch  index {
               case 0:
                   remakeConstraints(type: .Public)
               case 1:
                   remakeConstraints(type: .OnlySelf)
               case 2:
                   remakeConstraints(type: .OnlyFans)
               default:
                   remakeConstraints(type: .Public)
               }
           }
        })
        postTypeButton.menu = menu
        
        
        scrollView.addSubview(richTextView)
        richTextView.placeholder = "What happend today?"
        richTextView.textColor = R.color.textColor52()!
        richTextView.font = UIFont.sk.pingFangRegular(15)
        richTextView.placeholderFont = UIFont.sk.pingFangRegular(15)
        richTextView.frame = CGRect(x: 16, y: postTypeButton.frame.maxY + 8, width: kScreenWidth - 32, height: 40)
        richTextView.rx.didChange.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            var contentH = self.richTextView.text.heightWithConstrainedWidth(width: kScreenWidth - 32, font: UIFont.sk.pingFangRegular(15)) + 20
            contentH = contentH < 40 ? 40 : contentH
            self.richTextView.frame.size.height = contentH
            self.imageClvView.frame.origin.y = self.richTextView.frame.maxY + 16
            self.scrollView.contentSize = CGSize(width: kScreenWidth, height: 300 + contentH)
        }).disposed(by: rx.disposeBag)
        richTextView.becomeFirstResponder()
        
        
        scrollView.addSubview(imageClvView)
        imageClvView.frame = CGRect(x: 0, y: richTextView.frame.maxY + 16, width: kScreenWidth - 32, height: 180)
        
        
        self.view.addSubview(toolBar)
        toolBar.frame = CGRect(x: 0, y: kScreenHeight - toolBarH, width: kScreenWidth, height: toolBarH)
        RxKeyboard.instance.visibleHeight.drive(onNext:{ [weak self] keyboardVisibleHeight in
            guard let `self` = self else { return }
            self.toolBar.frame.origin.y = kScreenHeight - keyboardVisibleHeight - self.toolBarH
        }).disposed(by: rx.disposeBag)
        
        toolBar.imageButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            let ps = ZLPhotoPreviewSheet()
            ps.selectImageBlock = { results, isOriginal in
                self.addedImages.append(contentsOf: results)
                self.isOriginal = isOriginal
                self.imageClvView.reloadData()
            }
            ps.showPhotoLibrary(sender: self)
           
        }).disposed(by: rx.disposeBag)
        
        toolBar.linkButton.rx.tap.subscribe(onNext:{ [weak self] in
            Haptico.selection()
            Toast.showMessage("Function under development")
        }).disposed(by: rx.disposeBag)
        
        toolBar.atButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            Toast.showMessage("Function under development")
            return
            let vc = CalendarAddAttendanceController(selecteds: [])
            let nav = BaseNavigationController(rootViewController: vc)
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
        }).disposed(by: rx.disposeBag)
        
        toolBar.moreButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            Toast.showLoading()
            self.addPost()
        }).disposed(by: rx.disposeBag)
        
        toolBar.hastagButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            Toast.showMessage("Function under development")
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
    
    
    func addPost() {
        
        func compressionImage(_ size:Int,image:UIImage) -> String {
            guard let data = image.pngData() else { return "" }
            guard let result = try? ImageCompress.compressImageData(data, limitDataSize: size * 1024 * 1024) else { return "" }
            let base64 = UIImage(data: result)?.pngBase64String() ?? ""
            print("image.kilobytesSize:\(UIImage(data: data)?.kilobytesSize ?? 0),base64Size:\(base64.lengthOfBytes(using: .utf8))")
            return base64
        }
        var images:[String] = []
        Asyncs.async {
            images = self.addedImages.map { compressionImage(100, image: $0.image) }.filter({ !$0.isEmpty })
        } mainTask: {
            let content = self.richTextView.text ?? ""
            let type = self.postType.rawValue
            PostService.addPost(content: content,images: images,type: type).subscribe(onNext:{ model in
                Toast.showSuccess(withStatus:"Posted successfully", after: 1) {
                    self.returnBack()
                }
                self.saveButton.stopAnimation()
                self.addCompleteHandler?(model)
            },onError: { e in
                self.saveButton.stopAnimation()
                Toast.showError(withStatus: e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
        }

        
    }

 
    
   

}

extension HomeController {
//    @objc func toggleLink() {
//        var linkTitle = ""
//        var linkURL: URL? = nil
//        var linkRange = richTextView.selectedRange
//        // Let's check if the current range already has a link assigned to it.
//        if let expandedRange = richTextView.linkFullRange(forRange: richTextView.selectedRange) {
//            linkRange = expandedRange
//            linkURL = richTextView.linkURL(forRange: expandedRange)
//        }
//        let target = richTextView.linkTarget(forRange: richTextView.selectedRange)
//        linkTitle = richTextView.attributedText.attributedSubstring(from: linkRange).string
//        let allowTextEdit = !richTextView.attributedText.containsAttachments(in: linkRange)
//        showLinkDialog(forURL: linkURL, text: linkTitle, target: target, range: linkRange, allowTextEdit: allowTextEdit)
//    }
    
//    func showLinkDialog(forURL url: URL?, text: String?, target: String?, range: NSRange, allowTextEdit: Bool = true) {
//
//        let isInsertingNewLink = (url == nil)
//        var urlToUse = url
//
//        if isInsertingNewLink {
//            let pasteboard = UIPasteboard.general
//            if let pastedURL = pasteboard.value(forPasteboardType:String(kUTTypeURL)) as? URL {
//                urlToUse = pastedURL
//            }
//        }
//
//        let insertButtonTitle = isInsertingNewLink ? NSLocalizedString("Insert Link", comment:"Label action for inserting a link on the editor") : NSLocalizedString("Update Link", comment:"Label action for updating a link on the editor")
//        let removeButtonTitle = NSLocalizedString("Remove Link", comment:"Label action for removing a link from the editor");
//        let cancelButtonTitle = NSLocalizedString("Cancel", comment:"Cancel button")
//
//        let alertController = UIAlertController(title:insertButtonTitle,
//                                                message:nil,
//                                                preferredStyle:UIAlertController.Style.alert)
//        alertController.view.accessibilityIdentifier = "linkModal"
//
//        alertController.addTextField(configurationHandler: { [weak self]textField in
//            textField.clearButtonMode = UITextField.ViewMode.always;
//            textField.placeholder = NSLocalizedString("URL", comment:"URL text field placeholder");
//            textField.keyboardType = .URL
//            textField.textContentType = .URL
//            textField.text = urlToUse?.absoluteString
//
//            textField.addTarget(self,
//                                action:#selector(CreatePostViewController.alertTextFieldDidChange),
//                                for:UIControl.Event.editingChanged)
//
//            textField.accessibilityIdentifier = "linkModalURL"
//        })
//
//        if allowTextEdit {
//            alertController.addTextField(configurationHandler: { textField in
//                textField.clearButtonMode = UITextField.ViewMode.always
//                textField.placeholder = NSLocalizedString("Link Text", comment:"Link text field placeholder")
//                textField.isSecureTextEntry = false
//                textField.autocapitalizationType = UITextAutocapitalizationType.sentences
//                textField.autocorrectionType = UITextAutocorrectionType.default
//                textField.spellCheckingType = UITextSpellCheckingType.default
//
//                textField.text = text;
//
//                textField.accessibilityIdentifier = "linkModalText"
//
//            })
//        }
//
//        alertController.addTextField(configurationHandler: { textField in
//            textField.clearButtonMode = UITextField.ViewMode.always
//            textField.placeholder = NSLocalizedString("Target", comment:"Link text field placeholder")
//            textField.isSecureTextEntry = false
//            textField.autocapitalizationType = UITextAutocapitalizationType.sentences
//            textField.autocorrectionType = UITextAutocorrectionType.default
//            textField.spellCheckingType = UITextSpellCheckingType.default
//
//            textField.text = target;
//
//            textField.accessibilityIdentifier = "linkModalTarget"
//
//        })
//
//        let insertAction = UIAlertAction(title:insertButtonTitle,
//                                         style:UIAlertAction.Style.default,
//                                         handler:{ [weak self]action in
//
//            self?.richTextView.becomeFirstResponder()
//            guard let textFields = alertController.textFields else {
//                return
//            }
//            let linkURLField = textFields[0]
//            let linkTextField = textFields[1]
//            let linkTargetField = textFields[2]
//            let linkURLString = linkURLField.text
//            var linkTitle = linkTextField.text
//            let target = linkTargetField.text
//
//            if  linkTitle == nil  || linkTitle!.isEmpty {
//                linkTitle = linkURLString
//            }
//
//            guard
//                let urlString = linkURLString,
//                let url = URL(string:urlString)
//            else {
//                return
//            }
//            if allowTextEdit {
//                if let title = linkTitle {
//                    self?.richTextView.setLink(url, title: title, target: target, inRange: range)
//                }
//            } else {
//                self?.richTextView.setLink(url, target: target, inRange: range)
//            }
//        })
//
//        insertAction.accessibilityLabel = "insertLinkButton"
//
//        let removeAction = UIAlertAction(title:removeButtonTitle,
//                                         style:UIAlertAction.Style.destructive,
//                                         handler:{ [weak self] action in
//            self?.richTextView.becomeFirstResponder()
//            self?.richTextView.removeLink(inRange: range)
//        })
//
//        let cancelAction = UIAlertAction(title: cancelButtonTitle,
//                                         style:UIAlertAction.Style.cancel,
//                                         handler:{ [weak self]action in
//            self?.richTextView.becomeFirstResponder()
//        })
//
//        alertController.addAction(insertAction)
//        if !isInsertingNewLink {
//            alertController.addAction(removeAction)
//        }
//        alertController.addAction(cancelAction)
//
//        // Disabled until url is entered into field
//        if let text = alertController.textFields?.first?.text {
//            insertAction.isEnabled = !text.isEmpty
//        }
//
//        present(alertController, animated:true, completion:nil)
//    }
//
//
//    @objc func alertTextFieldDidChange(_ textField: UITextField) {
//        guard
//            let alertController = presentedViewController as? UIAlertController,
//            let urlFieldText = alertController.textFields?.first?.text,
//            let insertAction = alertController.actions.first
//        else {
//            return
//        }
//
//        insertAction.isEnabled = !urlFieldText.isEmpty
//    }
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



