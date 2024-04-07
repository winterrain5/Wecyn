//
//  ChatVC_InputBarDelegate.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/29.
//

import Foundation
import MessageKit
import PromiseKit
import OpenIMSDK
extension ChatViewController {
    
    func getUploadFileUrl(_ type:UploadContentType) -> Promise<UploadMediaModel> {
        Promise { resolver in
            CommonService.getUploadFileUrl(type.ext,type).subscribe(onNext:{
                resolver.fulfill($0)
            },onError: { e in
                resolver.reject(e.asAPIError)
            }).disposed(by: rx.disposeBag)
        }
    }
    
    func uploadMedia(_ model:UploadMediaModel,_ data:Data, _ type:UploadContentType) -> Promise<String> {
        Promise { resolver in
            CommonService.share.uploadMedia(model.upUrl, data, type) { result in
                resolver.fulfill(model.downUrl)
            } failure: { e in
                resolver.reject(e)
            }
            
        }
    }
    
}

extension ChatViewController:CustomInputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [CustomAttachment]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            inputBar.inputTextView.text = String()
            inputBar.invalidatePlugins()
            
            attachments.forEach { attachment in
                switch attachment {
                case .image(let relativePath, let path):
                    let source = MediaMessageSource(source: MediaMessageSource.Info(url: URL(string: path)!, relativePath: relativePath))
                    self.sendImage(source: source)
                case .video(let thumbRelativePath, let thumbPath, let fullPath, let duration):
                    let source = MediaMessageSource(source: MediaMessageSource.Info(relativePath: fullPath),
                                                    thumb: MediaMessageSource.Info(url: URL(string: thumbPath)!, relativePath: thumbRelativePath),
                                                    duration: duration)
                    self.sendVideo(source: source)
                case .audio(let path,let duration):
                    let source = MediaMessageSource(source: MediaMessageSource.Info(relativePath: path),duration: duration)
                    self.sendAudio(source: source)
                }
            }
        }
    }
    
    private func sendImage(source: MediaMessageSource) {

        guard
            let image = UIImage.init(path: source.source.url.absoluteString),
            let data = image.compressedData()
        else { return }
        let message = IMMessage(image: image, user: IMController.shared.currentSender, messageId: UUID().uuidString, date: Date())
        message.sendStatus = .sending
        self.insertMessage(message)
        self.messagesCollectionView.scrollToLastItem(animated: true)
        firstly {
            getUploadFileUrl(.Image)
        }
        .then {
            self.uploadMedia($0,data,.Image)
        }.done { result in
            let sourcePic = OIMPictureInfo()
            sourcePic.url = result
            sourcePic.width = image.size.width
            sourcePic.height = image.size.height
            IMController.shared.sendImageMessage(byURL: result,
                                                 sourcePicture: sourcePic,
                                                 to: self.dataProvider.receiverId,
                                                 conversationType: .c2c) { messageInfo in
                
            } onComplete: { messageinfo in
                message.sendStatus = .sendSuccess
                self.reloadCollectionView()
            }
            
        }.catch { e in
            message.sendStatus = .sendFailure
            self.reloadCollectionView()
            self.revokeMessage()
            
        }
      
    }
    
    private func sendVideo(source: MediaMessageSource) {
        guard 
            
            let thumbnail = UIImage.init(path: source.thumb?.url.absoluteString),
            let path = source.source.relativePath,
            let data = try? Data.init(contentsOf:  NSURL(fileURLWithPath: path) as URL)
                
        else { return }
        let message = IMMessage(thumbnail: thumbnail, user: IMController.shared.currentSender, messageId: UUID().uuidString, date: Date())
        self.insertMessage(message)
        self.messagesCollectionView.scrollToLastItem(animated: true)
        
        firstly {
            self.getUploadFileUrl(.video)
        }
        .then {
            self.uploadMedia($0,data,.video)
        }
        .done { result in
            
            IMController.shared.sendVideoMessage(byURL: result, duration: source.duration ?? 0, size: 0, snapshotPath: "", to: self.dataProvider.receiverId, conversationType: .c2c) { info in
                
            } onComplete: { info in
                message.sendStatus = .sendSuccess
                self.reloadCollectionView()
            }

        }.catch { e in
            
            message.sendStatus = .sendFailure
            self.reloadCollectionView()
            self.revokeMessage()
            
        }
    }
    
    private func sendAudio(source: MediaMessageSource) {
        Logger.debug(source.source.relativePath, label: "Record Path")
        guard
            
            let path = source.source.relativePath,
            let data = try? Data.init(contentsOf: NSURL(fileURLWithPath: path) as URL)
                
        else { return }
        
        let url = NSURL(fileURLWithPath: path) as URL
        let message = IMMessage(audioURL: url, user: IMController.shared.currentSender, messageId: UUID().uuidString, date: Date())
        self.insertMessage(message)
        self.messagesCollectionView.scrollToLastItem(animated: true)
        
        firstly {
            self.getUploadFileUrl(.audio)
        }
        .then {
            self.uploadMedia($0, data, .audio)
        }
        .done { result in
            IMController.shared.sendAudioMessage(byURL: result, duration: source.duration ?? 0, size: 0, to: self.dataProvider.receiverId, conversationType: .c2c) { info in
                
            } onComplete: { info in
                message.sendStatus = .sendSuccess
                self.reloadCollectionView()
            }

        }.catch { e in
            
            message.sendStatus = .sendFailure
            self.reloadCollectionView()
            self.revokeMessage()
            
        }
    }
}
