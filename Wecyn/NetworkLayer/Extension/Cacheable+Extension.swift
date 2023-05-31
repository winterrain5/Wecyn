//
//  Service+Cache.swift
//  VictorOnlineParent
//
//  Created by Derrick on 2020/6/11.
//  Copyright © 2020 Victor. All rights reserved.
//

import Foundation
import Moya
import RxMoyaCache
import RxSwift
import Cache
public class MoyaCache {
    
    public static let shared = MoyaCache()
    
    public var storagePolicyClosure: (Moya.Response) -> Bool = { _ in true }
    
    private init() {}
}

extension Storable where Self: TargetType {
    
    public var allowsStorage: (Response) -> Bool {
        return MoyaCache.shared.storagePolicyClosure
    }
    
    public func cachedResponse(for key: CachingKey) throws -> Response {

        return try Storage<String,Moya.Response>().object(forKey: key.stringValue)
        
    }
    
    public func storeCachedResponse(_ cachedResponse: Response, for key: CachingKey) throws {
        try Storage<String,Moya.Response>().setObject(cachedResponse, forKey: key.stringValue)
    }
    
    public func removeCachedResponse(for key: CachingKey) throws {
        try Storage<String,Moya.Response>().removeObject(forKey: key.stringValue)
    }
    
    public func removeAllCachedResponses() throws {
        try Storage<String,Moya.Response>().removeAll()
    }
}

extension CachingKey where Self: TargetType {
    public var isExpired:Bool {
        guard let expired = try? Storage<String,Moya.Response>().isExpiredObject(forKey: stringValue) else {
            return true
        }
        return expired
    }
}

extension MoyaCache {
    
    struct DiskStorageName {
        
        static let response = "com.victor.cache.response"
        static let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                       appropriateFor: nil, create: true).appendingPathComponent("HTTPCache")
    }
}

private extension Storage where Value == Moya.Response {
    
    convenience init() throws {
        let diskConfig = DiskConfig(
            name: MoyaCache.DiskStorageName.response,
            expiry: .date(Date().addingTimeInterval(5 * 60)),
            maxSize: 1024 * 1024 * 50,
            directory: MoyaCache.DiskStorageName.directory,
            protectionType: .complete
        )
        let memoryConfig = MemoryConfig(
          expiry: .date(Date().addingTimeInterval(5 * 60)),
          countLimit: 50,
          totalCostLimit: 0
        )
        try self.init(diskConfig: diskConfig,
                      memoryConfig: memoryConfig,
                      transformer: Cache.Transformer<Value>(
                        toData: { $0.data },
                        fromData: { Value(statusCode: 200, data: $0) }))
    }
}

