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
                case  .file(let fileName,let url,let ext,let data,let size):
                    let source = MediaMessageSource(source: MediaMessageSource.Info(url: url),size: size,ext: ext,fileName: fileName)
                    self.sendFile(source: source, data: data)
                }
            }
        }
    }
    
    private func sendFile(source: MediaMessageSource,data:Data) {
        let ext = source.ext ?? ""
        let size = source.size ?? 0
        let fileName = source.fileName ?? ""
        
        var message:IMMessage?
        firstly {
            self.getUploadFileUrl(.file(ext: ext))
        }
        .then {
            let item = FileItem(title:fileName,url: $0.downUrl.url,image: UIImage(nameInBundle: "msg_file"),size: size)
            message = IMMessage(fileItem: item, user: IMController.shared.currentSender, messageId: UUID().uuidString, date: Date())
            message?.sendStatus = .sending
            self.insertMessage(message!)
            return self.uploadMedia($0, data, .file(ext: ext))
        }
        .done { result in
            IMController.shared.sendFileMessage(byURL: result, fileName: fileName, size: size, to: self.dataProvider.receiverId, conversationType: .c2c) { info in
                
            } onComplete: { info in
                message?.sendStatus = info.status
                self.reloadCollectionView()
            }

        }.catch { e in
            
            message?.sendStatus = .sendFailure
            self.reloadCollectionView()
            Toast.showError(e.asAPIError.errorInfo().message)
            
        }
        
    }
    
    
    private func sendImage(source: MediaMessageSource) {

        guard
            let image = UIImage.init(path: source.source.url.absoluteString),
            let data = image.compressedData()
        else { return }
     
        var message:IMMessage?
        firstly {
            getUploadFileUrl(.Image)
        }
        .then {
            if let url = $0.downUrl.url {
                message = IMMessage(imageURL: url, imageSize: image.size, user: IMController.shared.currentSender, messageId: UUID().uuidString, date: Date())
                message?.sendStatus = .sending
                self.insertMessage(message!)
            }
          
            return self.uploadMedia($0,data,.Image)
        }.done { result in
            let sourcePic = OIMPictureInfo()
            sourcePic.url = result
            sourcePic.width = image.size.width
            sourcePic.height = image.size.height
            IMController.shared.sendImageMessage(byURL: result,
                                                 sourcePicture: sourcePic,
                                                 to: self.dataProvider.receiverId,
                                                 conversationType: .c2c) { messageInfo in
                
            } onComplete: { info in
                message?.sendStatus = info.status
                self.reloadCollectionView()
            }
            
        }.catch { e in
            message?.sendStatus = .sendFailure
            self.reloadCollectionView()
            Toast.showError(e.asAPIError.errorInfo().message)
            
        }
      
    }
    
    private func sendVideo(source: MediaMessageSource) {
        guard 
            
            let thumbnail = UIImage.init(path: source.thumb?.url.absoluteString),
            let path = source.source.relativePath,
            let data = try? Data.init(contentsOf:  NSURL(fileURLWithPath: path) as URL)
                
        else { return }
        
        var message:IMMessage?
        firstly {
            self.getUploadFileUrl(.video)
        }
        .then {
           
            if let url = $0.downUrl.url {
                message = IMMessage(videoThumbnail: thumbnail,videoUrl: url, user: IMController.shared.currentSender, messageId: UUID().uuidString, date: Date())
                message?.sendStatus = .sending
                self.insertMessage(message!)
            }
         
            return self.uploadMedia($0,data,.video)
        }
        .done { result in
            
            IMController.shared.sendVideoMessage(byURL: result, duration: source.duration ?? 0, size: 0, snapshotPath: "", to: self.dataProvider.receiverId, conversationType: .c2c) { info in
                
            } onComplete: { info in
                message?.sendStatus = info.status
                self.reloadCollectionView()
            }

        }.catch { e in
            
            message?.sendStatus = .sendFailure
            self.reloadCollectionView()
            Toast.showError(e.asAPIError.errorInfo().message)
            
        }
    }
    
    private func sendAudio(source: MediaMessageSource) {
        Logger.debug(source.source.relativePath, label: "Record Path")
        guard
            
            let path = source.source.relativePath,
            let data = try? Data.init(contentsOf: NSURL(fileURLWithPath: path) as URL)
                
        else { return }
        
        var message:IMMessage?
        firstly {
            self.getUploadFileUrl(.audio)
        }
        .then {
            if let url = $0.downUrl.url {
                message = IMMessage(audioURL: url, user: IMController.shared.currentSender, messageId: UUID().uuidString, date: Date())
                message?.sendStatus = .sending
                self.insertMessage(message!)
            }
           
            return self.uploadMedia($0, data, .audio)
        }
        .done { result in
            IMController.shared.sendAudioMessage(byURL: result, duration: source.duration ?? 0, size: 0, to: self.dataProvider.receiverId, conversationType: .c2c) { info in
                
            } onComplete: { info in
                message?.sendStatus = info.status
                self.reloadCollectionView()
            }

        }.catch { e in
            
            message?.sendStatus = .sendFailure
            self.reloadCollectionView()
            Toast.showError(e.asAPIError.errorInfo().message)
            
        }
    }
}



