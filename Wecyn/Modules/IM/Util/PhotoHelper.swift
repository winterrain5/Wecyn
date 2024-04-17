//
//  PhotoHelper.swift
//  Wecyn
//
//  Created by Derrick on 2024/4/1.
//


import Foundation
import Photos
import UIKit
import ZLPhotoBrowser


open class PhotoHelper {
    public var didPhotoSelected: ((_ images: [UIImage], _ assets: [PHAsset], _ isOriginPhoto: Bool) -> Void)?

    public var didPhotoSelectedCancel: (() -> Void)?

    public var didCameraFinished: ((UIImage?, URL?) -> Void)?

    public init() {
        resetConfigToSendMedia()
    }

    func resetConfigToSendMedia() {
        let editConfig = ZLPhotoConfiguration.default().editImageConfiguration
        editConfig.tools([.draw, .clip, .textSticker, .mosaic])
        ZLPhotoConfiguration.default().editImageConfiguration(editConfig)
            .canSelectAsset { _ in true }
            .navCancelButtonStyle(.text)
            .noAuthorityCallback { (authType: ZLNoAuthorityType) in
                switch authType {
                case .library:
                    debugPrint("No library authority")
                case .camera:
                    debugPrint("No camera authority")
                case .microphone:
                    debugPrint("No microphone authority")
                }
            }
        ZLPhotoConfiguration.default().cameraConfiguration.videoExportType = .mp4
    }

    public func setConfigToPickAvatar() {
        let editConfig = ZLPhotoConfiguration.default().editImageConfiguration
        editConfig.tools([.clip])
            .clipRatios([ZLImageClipRatio.wh1x1])
        ZLPhotoConfiguration.default().maxSelectCount(1)
            .editAfterSelectThumbnailImage(false)
            .allowRecordVideo(false)
            .allowMixSelect(false)
            .allowSelectGif(false)
            .allowSelectVideo(false)
            .allowSelectLivePhoto(false)
            .allowSelectOriginal(false)
            .allowTakePhotoInLibrary(true)
            .editImageConfiguration(editConfig)
            .showClipDirectlyIfOnlyHasClipTool(true)
            .canSelectAsset { _ in false }
            .navCancelButtonStyle(.text)
            .noAuthorityCallback { (authType: ZLNoAuthorityType) in
                switch authType {
                case .library:
                    debugPrint("No library authority")
                case .camera:
                    debugPrint("No camera authority")
                case .microphone:
                    debugPrint("No microphone authority")
                }
            }
    }
    
    public func setConfigToPickBusinessCard() {
        let editConfig = ZLPhotoConfiguration.default().editImageConfiguration
        editConfig.tools([.clip])
            .clipRatios([ZLImageClipRatio.custom])
        ZLPhotoConfiguration.default().maxSelectCount(1)
            .editAfterSelectThumbnailImage(true)
            .saveNewImageAfterEdit(false)
            .allowRecordVideo(false)
            .allowMixSelect(false)
            .allowSelectGif(false)
            .allowSelectVideo(false)
            .allowSelectImage(true)
            .allowSelectLivePhoto(false)
            .allowTakePhotoInLibrary(false)
            .allowSelectOriginal(true)
            .editImageConfiguration(editConfig)
            .showClipDirectlyIfOnlyHasClipTool(true)
            .canSelectAsset { _ in false }
            .navCancelButtonStyle(.text)
            .noAuthorityCallback { (authType: ZLNoAuthorityType) in
                switch authType {
                case .library:
                    debugPrint("No library authority")
                case .camera:
                    debugPrint("No camera authority")
                case .microphone:
                    debugPrint("No microphone authority")
                }
            }
    }
    
    public func setConfigToMultipleSelected(forVideo: Bool = false, maxSelectCount: Int = 9) {
     
        let config = ZLPhotoConfiguration.default()
        config.allowSelectImage = !forVideo
        config.allowSelectVideo = forVideo
        config.allowSelectGif = false
        config.allowSelectLivePhoto = false
        config.allowSelectOriginal = false
        config.cropVideoAfterSelectThumbnail = true
        config.allowEditVideo = true
        config.allowMixSelect = false
        config.maxSelectCount = maxSelectCount
        config.maxEditVideoTime = 15
        
        
        let cameraConfig = ZLCameraConfiguration()
        cameraConfig.sessionPreset = .vga640x480
        config.cameraConfiguration = cameraConfig
    }

    func presentPhotoLibraryOnlyEdit(byController: UIViewController) {
        let sheet = ZLPhotoPreviewSheet(selectedAssets: nil)
        sheet.selectImageBlock = didPhotoSelected
        sheet.cancelBlock = didPhotoSelectedCancel
        sheet.showPhotoLibrary(sender: byController)
    }

    public func presentPhotoLibrary(byController: UIViewController) {
        let sheet = ZLPhotoPreviewSheet(selectedAssets: nil)
        sheet.selectImageBlock = didPhotoSelected
        sheet.cancelBlock = didPhotoSelectedCancel
        sheet.showPhotoLibrary(sender: byController)
    }

    public func presentCamera(byController: UIViewController) {
        let camera = ZLCustomCamera()
        camera.takeDoneBlock = didCameraFinished
        byController.showDetailViewController(camera, sender: nil)
    }

    public static func getVideoAt(url: URL, handler: @escaping (_ main: FileHelper.FileWriteResult, _ thumb: FileHelper.FileWriteResult, _ duration: Int) -> Void) {
        let asset = AVURLAsset(url: url)
        let assetGen = AVAssetImageGenerator(asset: asset)
        assetGen.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: .zero, preferredTimescale: 600)
        var actualTime: CMTime = .zero
        DispatchQueue.global().async {
            do {
                let cgImage = try assetGen.copyCGImage(at: time, actualTime: &actualTime)
                let thumbnail = UIImage(cgImage: cgImage)
                let result = FileHelper.shared.saveImage(image: thumbnail)
                let p = FileHelper.shared.saveVideo(from: url.path)
                handler(p, result, Int(asset.duration.seconds))
            } catch {
                #if DEBUG
                    print("获取视频帧错误:", error)
                #endif
            }
        }
    }
    
    public static func getFirstRate(fromVideo: URL, completionHandler: @escaping (_ path: String, _ duration: Int) -> Void) {
        
        let asset = AVURLAsset(url: fromVideo)
        let assetGen = AVAssetImageGenerator(asset: asset)
        assetGen.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: .zero, preferredTimescale: 600)
        var actualTime: CMTime = .zero
        DispatchQueue.global().async {
            do {
                let cgImage = try assetGen.copyCGImage(at: time, actualTime: &actualTime)
                let thumbnail = UIImage(cgImage: cgImage)
                let result = FileHelper.shared.saveImage(image: thumbnail)
                let thumbnailPath = result.fullPath
                completionHandler(thumbnailPath, Int(asset.duration.seconds))
            } catch {
                #if DEBUG
                    print("获取视频帧错误:", error)
                #endif
                completionHandler("", 0)
            }
        }
    }
    
  
    public static func compressVideoToMp4(asset: PHAsset, thumbnail: UIImage?, handler: @escaping (_ main: FileHelper.FileWriteResult, _ thumb: FileHelper.FileWriteResult, _ duration: Int) -> Void) {
        let fileHelper = FileHelper.shared
        let thumbnail = fileHelper.saveImage(image: thumbnail!)

        ZLVideoManager.exportVideo(for: asset, exportType: .mp4) { (url: URL?, _: Error?) in
            guard let url = url else { return }
            let p = fileHelper.saveVideo(from: url.path)
            handler(p, thumbnail, Int(asset.duration))
        }
    }
    
    public static func saveImage(image: UIImage) -> String {
        let result = FileHelper.shared.saveImage(image: image)
        
        return result.fullPath
    }

    public struct MediaTuple {
        let thumbnail: UIImage
        let asset: PHAsset
        public init(thumbnail: UIImage, asset: PHAsset) {
            self.thumbnail = thumbnail
            self.asset = asset
        }
    }

    deinit {
        #if DEBUG
            print("dealloc \(type(of: self))")
        #endif
    }
}

