//
//  RequestLoadingPlugin.swift
//  VictorOnline
//
//  Created by Derrick on 2020/6/29.
//  Copyright © 2020 Victor. All rights reserved.
//
// 各个方法调用时机图 https://user-gold-cdn.xitu.io/2020/6/30/1730319eb03dbbde?imageView2/0/w/1280/h/960/format/webp/ignore-error/1

import Foundation
import Moya
import Alamofire

final class NetworkActivityPlugin:PluginType {

    private let viewController: UIViewController? = UIViewController.getTopVC()
    private var spinner: UIActivityIndicatorView!
    private var timer:RxSwift.Disposable?
    private var dataStatus:Bool = false
    
    init() {
        
        self.spinner = UIActivityIndicatorView(style: .gray)
        self.spinner.center = self.viewController!.view.center
    }

    
    //开始发起请求
    func willSend(_ request: RequestType, target: TargetType) {
        DispatchQueue.main.async {
            self.viewController?.view.addSubview(self.spinner)
            self.spinner.startAnimating()
        }
    }
    
    //收到请求
    func didReceive(_ result: Swift.Result<Moya.Response, MoyaError>, target: TargetType) {
        
        spinner.removeFromSuperview()
        spinner.stopAnimating()
    
        guard case let Swift.Result.success(_) = result else { return }
        
        
        
    }
    
}

