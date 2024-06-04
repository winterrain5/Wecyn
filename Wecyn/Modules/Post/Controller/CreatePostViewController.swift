//
//  CreatePostViewController.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/18.
//

import UIKit
import Foundation
import MobileCoreServices
import PromiseKit
import RxKeyboard
import KMPlaceholderTextView
import IQKeyboardManagerSwift
import WordPressEditor
import Aztec
import RxRelay
import Photos
import AnyImageKit
import SKPhotoBrowser
import AVKit
import FYVideoCompressor

enum PostMediaType {
    case Video
    case Image
    case None
}

enum PostType:Int {
    case Public = 1
    case OnlyFans = 2
    case OnlySelf = 3
    
    var description:String {
        switch self {
        case .Public:
            return "Public"
        case .OnlyFans:
            return "Visible only to followers"
        case .OnlySelf:
            return "Visible only to yourself"
        }
    }
}

class PostMediaModel: BaseModel {
    var image = UIImage()
    var mediaURL:URL?
    var isEdited:Bool = false
    var index = 0
    var asset:Asset?
    var size:CGSize {
        CGSize(width: asset?.phAsset.pixelWidth ?? 0, height: asset?.phAsset.pixelHeight ?? 0)
    }
}
class PostDraftModel:BaseModel, Codable {
   
    var content:String = ""
    var images:[String] = []
    
}
class CreatePostViewController: BaseViewController {
    
    var CommentReplyTextViewStyle : [NSAttributedString.Key : Any] {
        get {
            
            let paraStyle = NSMutableParagraphStyle()
            
            paraStyle.lineBreakMode = .byWordWrapping
            
            return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0),
                NSAttributedString.Key.paragraphStyle: paraStyle
            ]
        }
    }
    
    var richTextViewDelegate = RichTextViewDelegateHandler()
    
    lazy var richTextView: RichTextView = {
        let view = RichTextView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textContainer.lineBreakMode = .byWordWrapping
        
        view.delaysContentTouches = false
        
        //        richTextView.textContainer.lineFragmentPadding = 0
        
        view.font = UIFont.systemFont(ofSize: 15.0)
        
        view.isScrollEnabled = true
        view.textContainerInset = UIEdgeInsets.zero
        view.isEditable = true // true for realtime editing
        
        view.isSelectable = true
         (view.textStorage as! RichTextStorage).defaultTextStyle = CommentReplyTextViewStyle
        return view
    }()
    
    
    var toolBar = CreatePostToolBar.loadViewFromNib()
    
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
    var postMedias:[PostMediaModel] = []
    var isOriginal = true
    
    let postTypeButton = UIButton()
    let saveButton = LoadingButton()
    let draftButton = UIButton()
    let scrollView = UIScrollView()
   
    private var postType:PostType = .Public
    private let postDraft = PostDraftModel()
    private var isEnablePost:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private var editMedia:PostMediaModel?
    private var postModel:PostListModel?
    private var quotepostView:PostQuoteView?
    private let requestModel = AddPostRequestModel()
    private var postMediaType:PostMediaType = .None
    private var task: URLSessionUploadTask?
    
    var addCompleteHandler:((PostListModel)->())?
    
    convenience init(postModel:PostListModel) {
        self.init(nibName: nil, bundle: nil)
        self.postModel = postModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configScrollView()
        configToolbar()
        configNavBar()
        updateScrollViewContentSize()
        
        if let postModel = self.postModel {
            quotepostView = PostQuoteView(frame: CGRect(x: 16, y: imageClvView.frame.maxY + (postMedias.count > 0 ? 16 : 0), width: kScreenWidth - 32, height: 0))
            quotepostView?.postModel = postModel
            scrollView.addSubview(quotepostView!)
            quotepostView?.height = quotepostView?.viewHeight ?? 0
            toolBar.isHidden = true
        }
        
        
    }
    
    func configScrollView() {
        self.view.addSubview(scrollView)
        scrollView.rx.didEndDragging.observeOn(MainScheduler.asyncInstance).subscribe(onNext:{ [weak self] _ in
            self?.view.endEditing(true)
        }).disposed(by: rx.disposeBag)
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
            Haptico.selection()
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
            action.handleStateChange(self.postTypeButton, section: 0, isSingleChoose: true) { [weak self] in
                guard let `self` = self else { return }
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
        richTextView.textColor = R.color.textColor33()!
        richTextView.font = UIFont.sk.pingFangRegular(15)
        richTextView.delegate = richTextViewDelegate
        richTextView.frame = CGRect(x: 16, y: postTypeButton.frame.maxY + 8, width: kScreenWidth - 32, height: 40)
        richTextView.rx.didChange.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.updateScrollViewContentSize()
        }).disposed(by: rx.disposeBag)
        
        
        richTextView.becomeFirstResponder()
        
        scrollView.addSubview(imageClvView)
        imageClvView.frame = CGRect(x: 0, y: richTextView.frame.maxY + 16, width: kScreenWidth, height: 260)
    }
    
    func configToolbar() {
        self.view.addSubview(toolBar)
        toolBar.frame = CGRect(x: 0, y: kScreenHeight - toolBarH, width: kScreenWidth, height: toolBarH)
        RxKeyboard.instance.visibleHeight.drive(onNext:{ [weak self] keyboardVisibleHeight in
            guard let `self` = self else { return }
            self.toolBar.frame.origin.y = kScreenHeight - keyboardVisibleHeight - self.toolBarH
        }).disposed(by: rx.disposeBag)
        
        toolBar.imageButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            
            func presentController() {
                var options = PickerOptionsInfo()
                options.selectOptions = [.photo]
                options.selectLimit  = 9
                options.preselectAssets = self.postMedias.map({ $0.asset?.identifier ?? "" })
                let vc = ImagePickerController(options: options, delegate: self)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
            
            if self.postMediaType == .Video {
                self.showAlert(title: "Only supports uploading 1 video or 9 pictures. If you need to upload pictures, you need to delete the selected video.", message: nil,buttonTitles: ["Cancel","Confirm"],highlightedButtonIndex: 1) { idx in
                    if idx == 1 {
                        self.postMedias.removeAll()
                        
                        self.updateScrollViewContentSize({
                            presentController()
                        })
                        
                    }
                }
               
            } else {
                presentController()
            }
        }).disposed(by: rx.disposeBag)
        
        
        
        toolBar.linkButton.rx.tap.subscribe(onNext:{ [weak self] in
            Haptico.selection()
            Toast.showWarning("Function under development")
        }).disposed(by: rx.disposeBag)
        
        toolBar.videoButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            
            func presentController() {
                var options = PickerOptionsInfo()
                options.selectOptions = [.video]
                options.selectLimit  = 1
                
                let vc = ImagePickerController(options: options, delegate: self)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
            
            
            if self.postMediaType == .Image {
                
                self.showAlert(title: "Only supports uploading 1 video or 9 pictures. If you need to upload video, you need to delete the selected images.", message: nil,buttonTitles: ["Cancel","Confirm"],highlightedButtonIndex: 1) { idx in
                    if idx == 1 {
                        self.postMedias.removeAll()
                        self.updateScrollViewContentSize({
                            presentController()
                        })
                        
                    }
                }
            } else {
                presentController()
            }
            
           
            
        }).disposed(by: rx.disposeBag)
        
        toolBar.moreButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            self.addPost()
        }).disposed(by: rx.disposeBag)
        
        toolBar.atButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            let vc = PostSelectMentionUserController()
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            vc.didSelectContact = {
                self.requestModel.at_list.append($0.id)
                let atString =  "@\($0.first_name)\($0.last_name)"
                self.richTextView.text.append(atString)
                self.richTextView.text.append(" ")
                self.richTextView.becomeFirstResponder()
               
              
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    func configNavBar() {
        self.navigation.bar.shadowImage = UIImage(color: R.color.backgroundColor()!, size: CGSize(width: kScreenWidth, height: 1))
        
        self.addLeftBarButtonItem(image: R.image.xmark())
        self.leftButtonDidClick = { [weak self] in
            guard let `self` = self else { return }
            
            if let task = self.task,task.state == .running {
                self.showAlert(title: "The video is being uploaded. Exiting the current page will terminate the upload.", message: nil,buttonTitles: ["Cancel","Confirm"],highlightedButtonIndex: 1) { idx in
                    if idx == 1 {
                        self.task?.cancel()
                        self.returnBack()
                    }
                }
            } else  {
                self.view.endEditing(true)
                if !self.postDraft.content.isEmpty || !self.postDraft.images.isEmpty {
                    PostReturnBackSheetView.display(deleteAction: {
                        self.returnBack()
                    }, saveAction: {
                        var drafs:[PostDraftModel] = UserDefaults.sk.get(for: PostDraftModel.className)
                        if drafs.count > 0 {
                            drafs.append(self.postDraft)
                            UserDefaults.sk.set(objects: drafs, for: PostDraftModel.className)
                        } else {
                            UserDefaults.sk.set(objects: [self.postDraft], for: PostDraftModel.className)
                        }
                        
                        self.returnBack()
                    })
                    
                    return
                }
                
                self.returnBack()
            }
            
            
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
            if self.postModel != nil {
                self.repost()
            } else {
                self.addPost()
            }
        }).disposed(by: rx.disposeBag)
        
        isEnablePost.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.saveButton.isEnabled = $0
            self.saveButton.backgroundColor = $0 ? R.color.theamColor()! : R.color.theamColor()?.withAlphaComponent(0.6)
            self.toolBar.moreButton.isEnabled = $0
            self.draftButton.isHidden = $0
        }).disposed(by: rx.disposeBag)
        
        let drafts:[PostDraftModel] = UserDefaults.sk.get(for: PostDraftModel.className)
        
        if drafts.count > 0 {
            draftButton.titleForNormal = "Drafts"
            draftButton.titleColorForNormal = R.color.theamColor()
            draftButton.titleLabel?.font = UIFont.sk.pingFangSemibold(14)
            draftButton.rx.tap.subscribe(onNext:{ [weak self] in
                guard let `self` = self else { return }
                let vc = PostDraftsController()
                vc.selectDraftsCompelet = {
                    let images:[PostMediaModel?] = $0.images.enumerated().map({
                        
                        if let image = UIImage(base64String: $1) {
                            let model = PostMediaModel()
                            model.image = image
                            model.index = $0
                            return model
                        }
                        return nil
                    })
                    self.postMedias = images.compactMap({ $0 })
                    self.richTextView.text = $0.content
                    self.updateScrollViewContentSize()
                }
                let nav = BaseNavigationController(rootViewController: vc)
                self.present(nav, animated: true)
            }).disposed(by: rx.disposeBag)
            let draftItem = UIBarButtonItem(customView: draftButton)
            let fixItem = UIBarButtonItem.fixedSpace(width: 22)
            let saveItem = UIBarButtonItem(customView: saveButton)
            self.navigation.item.rightBarButtonItems = [saveItem,fixItem,draftItem]
        } else {
            self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
        
    }
    
    func updateScrollViewContentSize(_  complete: (()->())? = nil) {
        var contentH = self.richTextView.text.heightWithConstrainedWidth(width: kScreenWidth - 32, font: UIFont.sk.pingFangRegular(15)) + 20
        contentH = contentH < 40 ? 40 : contentH
        self.richTextView.frame.size.height = contentH
        self.imageClvView.frame.origin.y = self.richTextView.frame.maxY + 16
        var clvHeight = 0.cgFloat
        if postMedias.count == 1 {
            let size = postMedias.first?.image.scaled(toWidth: kScreenWidth - 32)?.size ?? .zero
            clvHeight = size.height > kScreenHeight * 0.6 ? kScreenHeight * 0.6 : size.height
        }
        if postMedias.count > 1 {
            clvHeight = 260
        }
        self.imageClvView.frame.size.height = clvHeight
        
        if self.postModel !=  nil {
            self.quotepostView?.frame.origin.y = self.imageClvView.frame.maxY + (postMedias.count > 0 ? 16 : 0)
            self.scrollView.contentSize = CGSize(width: kScreenWidth, height: clvHeight + contentH + 80  + (self.quotepostView?.viewHeight ?? 0) + kNavBarHeight)
        } else {
            self.scrollView.contentSize = CGSize(width: kScreenWidth, height: clvHeight + contentH + 64 + kNavBarHeight)
        }
        
        if postMedias.count == 0 {
            self.postMediaType = .None
        }
        
        self.postDraft.images = postMedias.map({  $0.image.pngBase64String() ?? "" })
        self.postDraft.content = self.richTextView.text ?? ""
        
        let isEnablePost = postMedias.count > 0 || !self.richTextView.text.isEmpty || (self.postModel != nil)
        self.isEnablePost.accept(isEnablePost)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0, delay: 0) {
            self.imageClvView.reloadData()
        } completion: { flag in
            complete?()
        }

    }
    
    /// 更新请求模型的值
    ///
    /// 此函数会遍历富文本视图中的提及范围，并将提及内容替换为相应的用户名。
    /// 替换完成后，将更新后的内容赋值给请求模型的 `content` 属性，并调用 `removeDuplicates` 方法去除 `at_list` 中的重复项。
    func updateRequestModelValue() {
        let replacingRange = self.richTextView.richTextStorage.mentionRanges.reversed()
        var content = self.richTextView.text ?? ""
        replacingRange.enumerated().forEach({ idx,rang in
            content = (content as NSString).replacingCharacters(in: rang, with: "[@\(self.requestModel.at_list.reversed()[idx])]")
        })
        print(content)
        self.requestModel.content = content
        self.requestModel.at_list.removeDuplicates()
    }

    func addPost() {
        Toast.showLoading()
        if self.postMediaType == .Video {
            uploadVideoData()
        } else {
            var images:[String] = []
            Asyncs.async {
                self.postMedias.forEach {
                    images.append($0.image.compressionImageToBase64(200))
                }
            } mainTask: {
                
                let type = self.postType.rawValue
               
                self.requestModel.images = images
                self.requestModel.type = type
                self.updateRequestModelValue()
                
                PostService.addPost(model: self.requestModel).subscribe(onNext:{ model in
                    Toast.showSuccess("Posted successfully")
                    self.returnBack()
                    self.saveButton.stopAnimation()
                    self.addCompleteHandler?(model)
                },onError: { e in
                    Toast.dismiss()
                    self.saveButton.stopAnimation()
                    Toast.showError(e.asAPIError.errorInfo().message)
                }).disposed(by: self.rx.disposeBag)
            }
        }
        
    }
    
   
    
    func uploadVideoData() {
        guard let media = self.postMedias.first else {
            return
        }
        
        func compressVideo(_ sourceURL:URL) ->  Promise<URL> {
            return Promise.init { resolver in
                Toast.showLoading(withStatus: "compress video")
                FYVideoCompressor().compressVideo(sourceURL, quality: .highQuality) { result in
                    switch result {
                    case .success(let compressedVideoURL):
                        Logger.debug(compressedVideoURL.sizePerMB(),label:"compressed video size")
                        resolver.fulfill(compressedVideoURL)
                    case .failure(let error):
                        resolver.reject(APIError.requestError(code: -1, message: error.localizedDescription))
                    }
                }
            }
        }
       
        
        func getUploadUrl(_ outputURL:URL) -> Promise<UploadVideoResponse>{
            return Promise.init { resolver in
                Toast.showLoading(withStatus: "upload video")
                PostService.getUploadVideoUrl().subscribe(onNext:{
                    $0.outputURL = outputURL
                    resolver.fulfill($0)
                },onError: { e in
                    resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
                }).disposed(by: rx.disposeBag)
            }
        }
        
        
        func uploadData(_ model:UploadVideoResponse) -> Promise<String>{
        
            return Promise { [weak self] resolver in
                guard let `self` = self else { return }
                var request: URLRequest = URLRequest(url: model.url.urlDecode().url!)
                request.addValue("video/mp4", forHTTPHeaderField: "Content-Type")
                request.method = .put
                request.timeoutInterval = 300
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForResource = 300
                configuration.timeoutIntervalForRequest = 300
                configuration.waitsForConnectivity = true
                
                let session = URLSession(configuration: configuration,delegate: self,delegateQueue: .main)
                print("fileUrl:\(model.outputURL.absoluteString)")
                print("uploadUrl:\(model.url.urlDecode().url?.absoluteString ?? "")")
                self.task = session.uploadTask(with: request, fromFile: model.outputURL) { data, response, error in
                    if error == nil,let data = data {
                        let result = String.init(data: data, encoding: .utf8) ?? ""
                        if result.isEmpty {
                            resolver.fulfill(model.video)
                        } else {
                            resolver.reject(APIError.requestError(code: -1, message: result))
                        }
                        print("result:\(result)")
                        
                    } else {
                        resolver.reject(APIError.requestError(code: -1, message: error?.localizedDescription ?? ""))
                    }
                }
                //5、启动任务
                self.task?.resume()
                
            }
            
        }
        
        func addPost(video:String) ->  Promise<Void> {
            return Promise { resolver in
                
                let type = self.postType.rawValue
                self.updateRequestModelValue()
                self.requestModel.video = video
                self.requestModel.type = type
                
                PostService.addPost(model: self.requestModel).subscribe(onNext:{ model in
                    Toast.showSuccess("Posted successfully")
                    self.returnBack()
                    self.saveButton.stopAnimation()
                    self.addCompleteHandler?(model)
                    resolver.fulfill_()
                },onError: { e in
                    self.saveButton.stopAnimation()
                    Toast.showError(e.asAPIError.errorInfo().message)
                    resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
                }).disposed(by: self.rx.disposeBag)
            }
        }
        
        func upload(_ sourceUrl:URL) {
            firstly {
                compressVideo(sourceUrl)
            }.then({
                getUploadUrl($0)
            }).then {
                uploadData($0)
            }.then {
                addPost(video: $0)
            }.done {
                self.saveButton.stopAnimation()
                Toast.dismiss()
            }.catch { e in
                Toast.dismiss()
                self.saveButton.stopAnimation()
                Toast.showError(e.asAPIError.errorInfo().message)
            }
        }
        
        if media.isEdited {
            guard let url = media.mediaURL else {
                Toast.showError("Get Video Data Failed")
                return
            }
            if url.sizePerMB() > 100 {
                Toast.showError("The video size cannot exceed 100MB.")
                Toast.dismiss()
                return
            }
            upload(url)
        } else {
            
            media.asset?.fetchVideoURL(completion: { result, id in
                switch result {
                case .success(let response):
                    Logger.debug(response.url.sizePerMB(),label:"video size")
                    if response.url.sizePerMB() > 100 {
                        Toast.showError("The video size cannot exceed 100MB.")
                        Toast.dismiss()
                        return
                    }
                    upload(response.url)
                case .failure(let e):
                    Toast.showError(e.localizedDescription)
                }
            })
        }
    
    }
    
    
    func repost() {
        PostService.repost(id: self.postModel?.id ?? 0, content: self.richTextView.text).subscribe(onNext:{ model in
            Toast.showSuccess( "You have reposted")
            
            self.returnBack()
            self.saveButton.stopAnimation()
            self.addCompleteHandler?(model)
            
        },onError: { e in
            self.saveButton.stopAnimation()
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    
}

extension CreatePostViewController: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("bytesSent:\(bytesSent),totalBytesSent:\(totalBytesSent),totalBytesExpectedToSend:\(totalBytesExpectedToSend)")
    }
}


extension CreatePostViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postMedias.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: CreatePostImageCell.self, for: indexPath)
        if postMedias.count > 0 {
            cell.result = postMedias[indexPath.item]
            cell.deleteItemHandler = { [weak self] result in
                self?.postMedias.removeAll(where: { $0 == result })
                self?.updateScrollViewContentSize()
            }
            cell.editItemHandler = { [weak self] result in
                guard let `self` = self else { return }
                self.editMedia = result
                if result.asset?.mediaType == .video,let video = result.asset?.phAsset {
                    let vc = ImageEditorController(video: video, placeholderImage: result.image, options: EditorVideoOptionsInfo(), delegate: self)
                    self.present(vc, animated: true)
                } else {
                    let vc = ImageEditorController(photo: result.image, options: EditorPhotoOptionsInfo(), delegate: self)
                    self.present(vc, animated: true)
                   
                }
                
            }
            cell.playItemHandler =  { [weak self] result in
                guard let `self` = self else { return }
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                if result.isEdited {
                    
                    let controller = AVPlayerViewController()
                    guard let url = result.mediaURL else { return }
                    let player = AVPlayer(url: url)
                    player.playImmediately(atRate: 1)
                    controller.player = player
                    self.present(controller, animated: true)
                    
                } else {
                    result.asset?.fetchVideo { result, id in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                    
                                let controller = AVPlayerViewController()
                                let player = AVPlayer(playerItem: response.playerItem)
                                player.playImmediately(atRate: 1)
                                controller.player = player
                                self.present(controller, animated: true)
                                
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if postMedias.count == 1 {
            let size = postMedias[indexPath.item].image.scaled(toWidth: kScreenWidth - 32)?.size ?? .zero
            let height = size.height > kScreenHeight * 0.6 ? kScreenHeight * 0.6 : size.height
            return CGSize(width: size.width, height: height)
        }
        if postMedias.count > 1 {
            let size = postMedias[indexPath.item].image.scaled(toHeight: 260)?.size ?? .zero
            return size
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CreatePostImageCell
        let originImage = cell.imageView.image
        if self.postMedias[indexPath.item].asset?.mediaType == .photo {
            let images = self.postMedias.filter({  $0.asset?.mediaType == .photo  }).map({ SKPhoto.photoWithImage($0.image) })
            let browser = SKPhotoBrowser(originImage: originImage ?? UIImage(), photos: images, animatedFromView: cell)
            browser.initializePageIndex(indexPath.row)
            present(browser, animated: true, completion: {})
        }
       
    }
    
}

extension CreatePostViewController: ImagePickerControllerDelegate {
    
    func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
        self.postMediaType = result.assets.first?.mediaType == .video ? .Video : .Image
        
        if self.postMediaType == .Image {
            
            self.postMedias.append(contentsOf: result.assets.enumerated().map{
                let media = PostMediaModel()
                media.asset = $1
                media.index = $0
                media.image = $1.image
                return media
            })
            self.postMedias.removeDuplicates(keyPath: \.asset)
            
        } else {
            
            self.postMedias = result.assets.enumerated().map{
                let media = PostMediaModel()
                media.asset = $1
                media.index = $0
                media.image = $1.image
                return media
            }
            
        }
        
        self.updateScrollViewContentSize({
            picker.dismiss(animated: true, completion: nil)
        })
        
    }
}

extension CreatePostViewController: ImageEditorControllerDelegate {
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
        if result.type == .photo {
            guard let photoData = try? Data(contentsOf: result.mediaURL) else { return }
            guard let photo = UIImage(data: photoData) else { return }
            self.editMedia?.image = photo
        }  else {
            self.editMedia?.isEdited = result.isEdited
            self.editMedia?.mediaURL = result.mediaURL
            if let image = self.editMedia?.mediaURL?.thumbnail() {
                self.editMedia?.image = image
            }
        }
        self.updateScrollViewContentSize()
        editor.dismiss(animated: true, completion: nil)
    }
}


class CreatePostImageCell: UICollectionViewCell {
    var imageView = UIImageView()
    
    var deleteButton = UIButton()
    var editButton = UIButton()
    var playButton = UIButton()
    var durationLabel = UILabel()
    var durationW:CGFloat = 0
    var result:PostMediaModel? {
        didSet {
            guard let result = result else { return }
            imageView.image = result.image
            playButton.isHidden = result.asset?.mediaType != .video
            durationLabel.isHidden = result.asset?.mediaType != .video
            if result.isEdited {
                guard let url = result.mediaURL else { return }
                let asset = AVAsset(url: url)
                let duration = CMTimeGetSeconds(asset.duration)
                durationLabel.text = "\(duration.int.string)s"
            } else {
                durationLabel.text = "\(result.asset?.phAsset.duration.int.string ?? "")s"
            }
           
            durationW = durationLabel.text?.getWidthWithLabel(font: UIFont.sk.pingFangRegular(12)) ?? 0
            self.setNeedsUpdateConstraints()
            self.layoutIfNeeded()
        }
    }
    
    
    var deleteItemHandler:((PostMediaModel)->())?
    var editItemHandler:((PostMediaModel)->())?
    var playItemHandler:((PostMediaModel)->())?
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
        
        playButton.isHidden = true
        durationLabel.isHidden = true
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



