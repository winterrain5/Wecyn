//
//  DataLoadable.swift
//  VictorOnlineParent
//
//  Created by Derrick on 2020/6/12.
//  Copyright © 2020 Victor. All rights reserved.
//

import UIKit

protocol DataLoadable {

    var dataArray:[Any] { get set }
    var refreshWhenLoad:Bool { get set }
    var isFirstLoad:Bool { get set }
    //
    var page:Int { get set }
    var pageSize:Int { get set }
    
    var shouldDisplayEmptyDataView:Bool { get set }
    var emptyDataType:EmptyDataType { get set }
    var emptyNoDataString:String { get set }
    var emptyNoDataImage:String { get set }
    
    var cellIdentifier:String { get set }
    
    func createListView()
    func listViewFrame() -> CGRect
    
    func listViewLayout() -> UICollectionViewLayout
    
    func registRefreshHeader(colorStyle:RefreshColorStyle)
    func registRefreshFooter()
    
    func reloadData()
    func loadNewData()
    func refreshData()
    func loadNextPage()
    
    func endRefresh()
    func endRefresh(_ count:Int,emptyString:String,emptyImage:String)
    func endRefresh(_ type:EmptyDataType, emptyString:String)
    
    
    func endHeaderRefresh()
    func endFooterRefresh(_ count:Int)
    func endHeaderFooterRefresh(_ count:Int)

}


extension DataLoadable {
    func listViewLayout() -> UICollectionViewLayout {
        UICollectionViewFlowLayout()
    }
}
