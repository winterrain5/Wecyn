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
                                                                  main.relativeFilePath,
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
                                                              main.relativeFilePath,
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
                $0.spacing = .fixed(8)
                $0.image = UIImage(nameInBundle: "inputbar_more_normal_icon")
                $0.setImage(UIImage(nameInBundle: "inputbar_keyboard_btn_icon"), for: .selected)
                $0.setImage(UIImage(nameInBundle: "inputbar_more_disable_icon"), for: .disabled)
                $0.setSize(CGSize(width: 32, height: 32), animated: false)
            }.onTouchUpInside { [weak self] item in
                print("Item Tapped:\(item.isSelected)")
                guard let self else { return }
                item.isSelected = !item.isSelected
                self.showPadView(item.isSelected)
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


        moreButton.tintColor = .black
        moreButton.onTouchUpInside { [weak self] item in
            guard let `self` = self else { return }
            item.isSelected = !item.isSelected
            self.showPadView(item.isSelected)
           
        }
        setLeftStackViewWidthConstant(to: 32, animated: false)
        setStackViewItems([moreButton], forStack: .left, animated: false)
        
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        inputTextView.layer.borderWidth = 0
        inputTextView.layer.cornerRadius = 4
        inputTextView.layer.masksToBounds = true
        inputTextView.backgroundColor = .white
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
       
        setRightStackViewWidthConstant(to: 38, animated: false)
        setStackViewItems([sendButton, InputBarButtonItem.fixedSpace(2)], forStack: .right, animated: false)
       
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        sendButton.image = R.image.paperplaneFill()!
        sendButton.title = nil
        
        middleContentViewPadding.top = 8
        middleContentViewPadding.bottom = 8
        middleContentViewPadding.left = 12
        middleContentViewPadding.right = -38
        separatorLine.isHidden = false
        isTranslucent = true
        
        inputPlugins.append(attachmentManager)
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
    
    private func makeButton(named name: String) -> InputBarButtonItem {
      InputBarButtonItem()
        .configure {
          $0.spacing = .fixed(10)
          $0.image = UIImage(systemName: name)?.withRenderingMode(.alwaysOriginal)
          $0.setSize(CGSize(width: 36, height: 36), animated: false)
        }.onSelected {
          $0.tintColor = .systemBlue
        }.onDeselected {
          $0.tintColor = UIColor.lightGray
        }.onTouchUpInside { _ in
          print("Item Tapped")
        }
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
        default:
            break
        }
    }
}


