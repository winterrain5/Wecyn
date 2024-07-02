//
//  BusinessCardController.swift
//  Wecyn
//
//  Created by Derrick on 2024/6/27.
//

import UIKit
import NFCReaderWriter
import SafariServices
import MessageUI
import ImagePickerSwift
import Photos
import AnimatedCollectionViewLayout
class BusinessCardController: BaseCollectionController,UICollectionViewDelegateFlowLayout {
    var data:UserInfoModel?
    
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToPickBusinessCard()
        v.didPhotoSelected = { [weak self, weak v] (images: [UIImage], assets: [PHAsset], _: Bool) in
            guard let self else { return }
            
            for (index, asset) in assets.enumerated() {
                switch asset.mediaType {
                case .image:
                    
                    let vc = AddNewBusinessCardController(image: images[index])
                    self.navigationController?.pushViewController(vc)
                    
                default:
                    break
                }
            }
        }

        v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
            guard let self else { return }
            
            if let photo {
                let vc = AddNewBusinessCardController(image: photo)
                self.navigationController?.pushViewController(vc)
                
            }
        }
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        configNavigation()
    
    }
    
    func configNavigation() {
        self.navigation.item.title = "名片".innerLocalized()
        
        let scan = UIButton()
        scan.imageForNormal = UIImage(systemName: "person.crop.square.badge.camera")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        scan.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            
            let alert = UIAlertController.init(title: "Scan BusinessCard", message: "Select photo from camera or photolibrary", preferredStyle: .actionSheet)
            
            alert.addAction(title: "Camera",style: .destructive) { _ in
                self.showImagePickerController(sourceType: .camera)
            }
            alert.addAction(title: "PhotoLibrary",style: .destructive) { _ in
                self.showImagePickerController(sourceType: .photoLibrary)
            }
            
            
            alert.addAction(title: "Cancel",style: .cancel)
            
            alert.show()
           
            
        
        }).disposed(by: rx.disposeBag)
        let scanItem = UIBarButtonItem(customView: scan)
        self.navigation.item.leftBarButtonItem = scanItem
        
        let addButton = UIButton()
        let addItem = UIBarButtonItem(customView: addButton)
        addButton.rx.tap.subscribe(onNext:{ [weak self] in
            
            let vc = NFCNameCardEditController()
            self?.navigationController?.pushViewController(vc)
            
        }).disposed(by: rx.disposeBag)
        addButton.imageForNormal = UIImage(systemName: "plus")
        
        self.navigation.item.rightBarButtonItem = addItem
        
      
    }
    
    override func createListView() {
        super.createListView()
        
        collectionView?.register(nibWithCellClass: BusinessCardCell.self)
        collectionView?.isPagingEnabled = true
    }
    
    override func refreshData() {
        UserService.getUserInfo().subscribe(onNext:{
            UserDefaults.sk.set(object: $0, for: UserInfoModel.className)
            self.data = $0
            self.endRefresh()
            
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype, emptyString: e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - kTabBarHeight)
    }
    
    
    override func listViewLayout() -> UICollectionViewLayout {
        let layout = AnimatedCollectionViewLayout()
        layout.scrollDirection = .horizontal
        
        layout.animator = LinearCardAttributesAnimator(itemSpacing: 0.3, scaleRate: 0.8)
        layout.collectionView?.showsHorizontalScrollIndicator = false
        
        return layout
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: BusinessCardCell.self, for: indexPath)
        cell.data = self.data
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = NFCNameCardController()
        self.navigationController?.pushViewController(vc)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: view.bounds.height * 0.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
}

extension BusinessCardController {
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        if case .camera = sourceType {
            _photoHelper.presentCamera(byController: UIViewController.sk.getTopVC()!)
        } else {
            _photoHelper.presentPhotoLibrary(byController: UIViewController.sk.getTopVC()!)
        }
    }
    
}
