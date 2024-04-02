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
    
    func getUploadFileUrl() -> Promise<UploadMediaModel> {
        Promise { resolver in
            CommonService.getUploadFileUrl("png").subscribe(onNext:{
                resolver.fulfill($0)
            },onError: { e in
                resolver.reject(e.asAPIError)
            }).disposed(by: rx.disposeBag)
        }
    }
    
    func uploadMedia(_ model:UploadMediaModel,_ data:Data) -> Promise<String> {
        Promise { resolver in
            CommonService.share.uploadMedia(model.upUrl, data) { result in
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
                case .video(let thumbRelativePath, let thumbPath, let mediaRelativePath, let duration):
                    let source = MediaMessageSource(source: MediaMessageSource.Info(relativePath: mediaRelativePath),
                                                    thumb: MediaMessageSource.Info(url: URL(string: thumbPath)!, relativePath: thumbRelativePath),
                                                    duration: duration)
                }
            }
        }
    }
    
    private func sendImage(source: MediaMessageSource) {

        guard let image = UIImage.init(path: source.source.url.absoluteString) else { return }
        let data = image.pngData()!
        self.insertMessage(IMMessage(image: image, user: IMController.shared.currentSender, messageId: UUID().uuidString, date: Date()))
        self.messagesCollectionView.scrollToLastItem(animated: true)
        firstly {
            getUploadFileUrl()
        }
        .then {
            self.uploadMedia($0,data)
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
                self.stopAnimation()
            }
            
        }.catch { e in
            
            self.stopAnimation()
            self.revokeMessage()
            
        }
      
    }
}
