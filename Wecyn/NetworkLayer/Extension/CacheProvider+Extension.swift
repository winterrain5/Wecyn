//
//  File.swift
//  VictorOnlineParent
//
//  Created by Derrick on 2020/6/23.
//  Copyright © 2020 Victor. All rights reserved.
//

import Foundation
import RxMoyaCache
import RxSwift
extension CacheProvider {
    
    /// 请使用该方法调起网络请求
    /// - Parameter target: 请求实体
    public func request(
        _ target: Provider.Target)
        -> Observable<Response>
    {
        if let response = try? target.cachedResponse(),
        target.allowsStorage(response),!target.isExpired {
            return Observable<Response>.just(response)
        }else {
            let source = Single.create { single -> Disposable in
                let cancellableToken = self.provider.request(
                    target,
                    callbackQueue: nil,
                    progress: nil)
                { result in
                    switch result {
                    case let .success(response):
                        single(.success(response))
                    case let .failure(error):
                        single(.error(error))
                    }
                }
                
                return Disposables.create {
                    cancellableToken.cancel()
                }
            }.storeCachedResponse(for: target).asObservable()
            return source
        }
        
    }
}
