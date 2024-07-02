//
//  BusinessCardShareController.swift
//  Wecyn
//
//  Created by Derrick on 2024/6/28.
//

import UIKit
import JXPagingView
import JXSegmentedView
class BusinessCardShareController: BaseViewController {

    
    let headView = UIView().backgroundColor(UIColor.random)
    let views:[BasePagingView] = [BusinessCardShareByMessageView(),BusinessCardShareByQRCodeView(),BusinessCardShareByEmailView()]
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    var titleDataSource: JXSegmentedTitleImageDataSource = {
        let dataSource = JXSegmentedTitleImageDataSource()
        dataSource.titleImageType = .onlyImage
        dataSource.isImageZoomEnabled = true
        dataSource.imageSelectedZoomScale = 1.5
        dataSource.titles = ["message", "qrcode", "envelope"]
        dataSource.normalImageInfos = ["message", "qrcode", "envelope"]
        
        dataSource.loadImageClosure = {(imageView, normalImageInfo) in
            //如果normalImageInfo传递的是图片的地址，你需要借助SDWebImage等第三方库进行图片加载。
            //加载bundle内的图片，就用下面的方式，内部默认也采用该方法。
            imageView.image = UIImage(systemName: normalImageInfo)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        }
        return dataSource
    }()
    
    var dotIndicator:JXSegmentedIndicatorDotLineView = {
        let indicator = JXSegmentedIndicatorDotLineView()
        indicator.indicatorHeight = 5
        indicator.indicatorWidth = 5
        indicator.indicatorColor = .black
        indicator.verticalOffset = 5
        return indicator
    }()
    
    
    lazy var segmentedView = JXSegmentedView().then { (segment) in
        segment.dataSource = titleDataSource
        segment.delegate = self
        segment.indicators = [dotIndicator]
        segment.backgroundColor = .clear
        segment.defaultSelectedIndex = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        let indictor = UIView().backgroundColor(R.color.backgroundColor()!)
        view.addSubview(indictor)
        indictor.frame = CGRect(x: 0, y: 20, width: 32, height: 4)
        indictor.center.x = self.view.center.x
        indictor.cornerRadius = 2
        
        let shareTitle = UILabel().color(.black).font(.systemFont(ofSize: 12, weight: .light))
        shareTitle.text = "分享名片".innerLocalized()
        view.addSubview(shareTitle)
        shareTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(indictor.snp.bottom).offset(30)
        }
        
        
        let tagTitle = UILabel().color(.black).font(.systemFont(ofSize: 18, weight: .bold))
        tagTitle.text = "工作名片".innerLocalized()
        view.addSubview(tagTitle)
        tagTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(shareTitle.snp.bottom).offset(8)
        }
        
        segmentedView.dataSource = titleDataSource
        segmentedView.delegate = self
        view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
            make.top.equalTo(tagTitle.snp.bottom).offset(20)
        }

        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        listContainerView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(segmentedView.snp.bottom)
            
        }
    }
    

 

}


extension BusinessCardShareController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        Haptico.selection()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
}

extension BusinessCardShareController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
      
        return titleDataSource.dataSource.count
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return views[index]
    }
}
