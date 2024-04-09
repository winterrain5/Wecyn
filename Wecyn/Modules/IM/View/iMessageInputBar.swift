//
//  iMessageInputBar.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/22.
//

import Foundation
import InputBarAccessoryView
import ImagePickerSwift
import AnyImageKit
import Photos
import MobileCoreServices

enum CustomAttachment {
    case image(String, String)
    case video(String, String, String, Int)
    case audio(String,Int)
    case file(String,URL,String,Data,Int)
}

// MARK: - CameraInputBarAccessoryViewDelegate
protocol CustomInputBarAccessoryViewDelegate: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [CustomAttachment])
    func inputBar(_ inputBar: InputBarAccessoryView, didPressPadItemWith type: PadItemType)
}

extension CustomInputBarAccessoryViewDelegate {
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: [CustomAttachment]) { }
    func inputBar(_: InputBarAccessoryView, didPressPadItemWith _: PadItemType) {}
}


final class iMessageInputBar: InputBarAccessoryView {
    let keyWindow = UIApplication.shared.keyWindow
    /// 录音框
    private var chatHUD: MCRecordHUD!
    
    /// 录音器
    private var recorder: AVAudioRecorder?
    /// 录音器设置
    private let recorderSetting = [AVSampleRateKey : NSNumber(value: Float(44100.0)),//声音采样率
                                     AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),//编码格式
                             AVNumberOfChannelsKey : NSNumber(value: 1),//采集音轨
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]//声音质量
    /// 录音计时器
    private var timer: Timer?
    /// 波形更新间隔
    private let updateFequency = 0.05
    /// 声音数据数组
    private var soundMeters: [Float]!
    /// 声音数据数组容量
    private let soundMeterCount = 10
    /// 录音时间
    private var recordTime = 0.00
    
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.didPhotoSelected = { [weak self, weak v] (images: [UIImage], assets: [PHAsset], _: Bool) in
            guard let self else { return }
            sendButton.startAnimating()
            
            for (index, asset) in assets.enumerated() {
                switch asset.mediaType {
                case .video:
                    PhotoHelper.compressVideoToMp4(asset: asset, thumbnail: images[index]) { main, thumb, duration in
                        self.sendAttachments(attachments: [.video(thumb.relativeFilePath,
                                                                  thumb.fullPath,
                                                                  main.fullPath,
                                                                  duration)])
                    }
                case .image:
                    let r = FileHelper.shared.saveImage(image: images[index])
                    self.sendAttachments(attachments: [.image(r.relativeFilePath,
                                                              r.fullPath)])
                default:
                    break
                }
            }
        }

        v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
            guard let self else { return }
            sendButton.startAnimating()
            
            if let photo {
                let r = FileHelper.shared.saveImage(image: photo)
                self.sendAttachments(attachments: [.image(r.relativeFilePath,
                                                          r.fullPath)])
            }

            if let videoPath {
                PhotoHelper.getVideoAt(url: videoPath) { main, thumb, duration in
                    self.sendAttachments(attachments: [.video(thumb.relativeFilePath,
                                                              thumb.fullPath,
                                                              main.fullPath,
                                                              duration)])
                }
            }
        }
        return v
    }()
    
 
    lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    lazy var moreButton: InputBarButtonItem = {
        let v = InputBarButtonItem()
            .configure {
                $0.tintColor = .black
                $0.spacing = .fixed(8)
                $0.image = UIImage(systemName: "plus.circle")?.scaled(toWidth: 28)
                $0.setImage(UIImage(systemName: "keyboard")?.scaled(toWidth: 28), for: .selected)
                $0.setSize(CGSize(width: 32, height: 32), animated: false)
            }.onTouchUpInside { [weak self] item in
                guard let self else { return }
                item.isSelected = !item.isSelected
                self.showPadView(item.isSelected)
            }
        
        return v
    }()
        
    lazy var micButton: InputBarButtonItem = {
        let v = InputBarButtonItem()
            .configure {
                $0.tintColor = .black
                $0.spacing = .fixed(8)
                $0.image = UIImage(systemName: "mic.fill")?.scaled(toWidth: 24)
                $0.setImage(UIImage(systemName: "keyboard")?.scaled(toWidth: 28), for: .selected)
                $0.setSize(CGSize(width: 32, height: 32), animated: false)
            }.onTouchUpInside { [weak self] item in
               
                guard let self else { return }
                item.isSelected = !item.isSelected
                self.showRecordView(item.isSelected)
            }
        
        return v
    }()
    
    lazy var recordAudioButton: InputBarButtonItem = {
        let v = InputBarButtonItem()
            .configure {
                $0.setTitleColor(.black, for: .normal)
                $0.setTitle("按住说话".innerLocalized(), for: .normal)
                $0.layer.borderWidth = 0
                $0.layer.cornerRadius = 4
                $0.layer.masksToBounds = true
                $0.backgroundColor = .white
                $0.titleColorForNormal = .black
                $0.heightAnchor.constraint(equalToConstant: 40).isActive = true

            }.onTouchUpInside { [weak self] item in
               
                guard let self else { return }
                item.isSelected = !item.isSelected
                
            }
        
        return v
    }()
        
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func configure() {
        backgroundColor = R.color.backgroundColor()


        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 16)
        inputTextView.layer.borderWidth = 0
        inputTextView.layer.cornerRadius = 4
        inputTextView.layer.masksToBounds = true
        inputTextView.backgroundColor = .white
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.returnKeyType = .send
        inputTextView.enablesReturnKeyAutomatically = true
        inputTextView.delegate = self
        inputTextView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
        setLeftStackViewWidthConstant(to: 32, animated: false)
        setStackViewItems([micButton], forStack: .left, animated: false)
        leftStackView.alignment = .center
        
        setRightStackViewWidthConstant(to: 32, animated: false)
        setStackViewItems([moreButton], forStack: .right, animated: false)
        rightStackView.alignment = .center
        
        middleContentViewPadding.top = 6
        middleContentViewPadding.bottom = 6
        middleContentViewPadding.left = 12
        separatorLine.isHidden = false
        isTranslucent = true
        maxTextViewHeight = 44
        
        
        inputPlugins.append(attachmentManager)
        
        chatHUD = MCRecordHUD(type: .bar)
        
        setupButtonEvent()
    }
    
    private func configBottomButtons(_ show: Bool) {
        if show {
            let pad = InputPadView()
            pad.delegate = self
            setStackViewItems([pad], forStack: .bottom, animated: true)
        } else {
            setStackViewItems([], forStack: .bottom, animated: true)
        }
    }
        
    private func showPadView(_ show: Bool) {
        if show {
            inputTextView.resignFirstResponder()
        } else {
            inputTextView.becomeFirstResponder()
            moreButton.isSelected = false
        }
        configBottomButtons(show)
    }
    
    private func showRecordView(_ show: Bool) {
        if show {
            inputTextView.resignFirstResponder()
            setMiddleContentView(recordAudioButton, animated: false)
        } else {
            inputTextView.becomeFirstResponder()
            setMiddleContentView(inputTextView, animated: false)
        }
    }
    
        
    private func sendAttachments(attachments: [CustomAttachment]) {
        DispatchQueue.main.async { [self] in
            if attachments.count > 0 {
                (self.delegate as? CustomInputBarAccessoryViewDelegate)?
                    .inputBar(self, didPressSendButtonWith: attachments)
            }
        }
    }
    
    private func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        if case .camera = sourceType {
            _photoHelper.presentCamera(byController: UIViewController.sk.getTopVC()!)
        } else {
            _photoHelper.presentPhotoLibrary(byController: UIViewController.sk.getTopVC()!)
        }
    }
    
    
        
    override func inputTextViewDidBeginEditing() {
        moreButton.isSelected = false
        configBottomButtons(false)
    }
    
    private func setupButtonEvent() {
        recordAudioButton.addTarget(self, action: #selector(beginRecordVoice), for: .touchDown)
        recordAudioButton.addTarget(self, action: #selector(endRecordVoice), for: .touchUpInside)
        recordAudioButton.addTarget(self, action: #selector(cancelRecordVoice), for: .touchUpOutside)
        recordAudioButton.addTarget(self, action: #selector(cancelRecordVoice), for: .touchCancel)
        recordAudioButton.addTarget(self, action: #selector(remindDragExit), for: .touchDragExit)
        recordAudioButton.addTarget(self, action: #selector(remindDragEnter), for: .touchDragEnter)
    }
    
    
    private func configAVAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do { try session.setCategory(AVAudioSession.Category.record, options: .defaultToSpeaker) }
        catch { print("session config failed") }
    }
    
    private func configRecord() {
        AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
            if !allowed {
                return
            }
        }
        let session = AVAudioSession.sharedInstance()
        do { try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker) }
        catch { print("session config failed") }
        
        do {
            self.recorder = try AVAudioRecorder(url: directoryUrl(), settings: self.recorderSetting)
            self.recorder?.delegate = self
            self.recorder?.prepareToRecord()
            self.recorder?.isMeteringEnabled = true
        } catch {
            print(error.localizedDescription)
        }
        do { try AVAudioSession.sharedInstance().setActive(true) }
        catch { print("session active failed") }
    }
    
    private func directoryURLPath() -> String {
        let audioDirectory = "OpenIM/audio/"
        let fileName = FileHelper.shared.getAudioName()
        print(fileName)
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/"
        let path = documents + audioDirectory + fileName
        
        Logger.debug(path, label: "Record Path")
        return path
    }
    
    func directoryUrl() -> URL {
        return URL(fileURLWithPath: directoryURLPath())
    }
}
extension iMessageInputBar:AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if recordTime > 1.0 {
            if flag {
                do {
                    let exists = try recorder.url.checkResourceIsReachable()
                    if exists {
                        print("finish record")
                        self.sendAttachments(attachments: [.audio(recorder.url.absoluteString.removingPrefix("file://"), Int(self.recordTime))])
                        self.recorder = nil
                    }
                }
                catch { print("fail to load record")}
            } else {
                print("record failed")
            }
        }
        recordTime = 0
    }
    
    /// 开始录音
    @objc private func beginRecordVoice() {
        configRecord()
        keyWindow?.addSubview(chatHUD)
        keyWindow?.isUserInteractionEnabled = false  //录音时候禁止点击其他地方
        chatHUD.startCounting()
        soundMeters = [Float]()
        recorder?.record()
        timer = Timer.scheduledTimer(timeInterval: updateFequency, target: self, selector: #selector(updateMeters), userInfo: nil, repeats: true)
    }
    
    /// 停止录音
    @objc private func endRecordVoice() {
        recorder?.stop()
        timer?.invalidate()
        chatHUD.removeFromSuperview()
        keyWindow?.isUserInteractionEnabled = true  //录音完了才能点击其他地方
        chatHUD.stopCounting()
        soundMeters.removeAll()
    }
    
    /// 取消录音
    @objc private func cancelRecordVoice() {
        endRecordVoice()
        recorder?.deleteRecording()
    }
    
    /// 上划取消录音
    @objc private func remindDragExit() {
        chatHUD.titleLabel.text = "Release to cancel"
    }
    
    /// 下滑继续录音
    @objc private func remindDragEnter() {
        chatHUD.titleLabel.text = "Slide up to cancel"
    }
    
    @objc private func updateMeters() {
        recorder?.updateMeters()
        recordTime += updateFequency
        addSoundMeter(item: recorder?.averagePower(forChannel: 0) ?? 0)
        if recordTime >= 60.0 {
            endRecordVoice()
        }
    }
    
    private func addSoundMeter(item: Float) {
        if soundMeters.count < soundMeterCount {
            soundMeters.append(item)
        } else {
            for (index, _) in soundMeters.enumerated() {
                if index < soundMeterCount - 1 {
                    soundMeters[index] = soundMeters[index + 1]
                }
            }
            // 插入新数据
            soundMeters[soundMeterCount - 1] = item
            NotificationCenter.default.post(name: NSNotification.Name.init("updateMeters"), object: soundMeters)
        }
    }
    
    func selectUploadFileFromICouldDrive()  {
        let documentTypes = ["public.content",
                             "public.text",
                             "public.source-code",
                             "public.image",
                             "public.audiovisual-content",
                             "com.adobe.pdf",
                             "com.apple.keynote.key",
                             "com.microsoft.word.doc",
                             "com.microsoft.excel.xls",
                             "com.microsoft.powerpoint.ppt"]
        

        let document = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        
         document.delegate = self  //UIDocumentPickerDelegate
        UIViewController.sk.getTopVC()?.present(document, animated:true, completion:nil)
    }
    
}
extension iMessageInputBar:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text.contains("\n") {
            
            self.delegate?.inputBar(self, didPressSendButtonWith: textView.text)
            
            return false
            
        }
        return true
        
    }
}

// MARK: AttachmentManagerDelegate

extension iMessageInputBar: AttachmentManagerDelegate {
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        
    }
}

// MARK: UIAdaptivePresentationControllerDelegate

extension iMessageInputBar: UIAdaptivePresentationControllerDelegate {
    // Swipe to dismiss image modal
    public func presentationControllerWillDismiss(_: UIPresentationController) {
        isHidden = false
    }
}

extension iMessageInputBar: InputPadViewDelegate {
    func didSelect(type: PadItemType) {
        print("chat plugin did select: \(type)")
        (self.delegate as? CustomInputBarAccessoryViewDelegate)?
            .inputBar(self, didPressPadItemWith: type)
        switch type {
        case .album:
            showImagePickerController(sourceType: .photoLibrary)
        case .camera:
            showImagePickerController(sourceType: .camera)
        case .file:
            selectUploadFileFromICouldDrive()
        }
    }
    
}

extension iMessageInputBar: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        guard let url = urls.last else { return }
        let fileName = url.lastPathComponent
        let ext = String(fileName.split(separator: ".").last ?? "")
        guard url.startAccessingSecurityScopedResource() else {
            print("startAccessingSecurityScopedResource failed")
            return
        }
        
        let coordinator = NSFileCoordinator()
        func read(url: URL) throws -> Data {
            var coordinationError: NSError?
            var readData: Data?
            var readError: Error?
            
            coordinator.coordinate(readingItemAt: url, options: [], error: &coordinationError) { url in
                do {
                    readData = try Data(contentsOf: url)
                } catch {
                    readError = error
                }
            }
            
            // 检查读取过程中是否发生了错误
            if let error = readError {
                throw error
            }
            
            // 检查协调过程中是否发生了错误
            if let coordinationError = coordinationError {
                throw coordinationError
            }
            
            // 确保读取到的数据不为空
            guard let data = readData else {
                throw NSError(domain: "CloudDocumentsHandlerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data was read from the file."])
            }
            
            return data
        }
        guard let data = try? read(url: url) else {
            Logger.debug("read data failed")
            return
        }
        var sizeInByte:Double = 0
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                sizeInByte = size.doubleValue
            }
        } catch {
            print("Error: \(error)")
        }
        self.sendAttachments(attachments: [.file(fileName,url,ext,data,sizeInByte.int)])
        url.stopAccessingSecurityScopedResource()
        
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}
