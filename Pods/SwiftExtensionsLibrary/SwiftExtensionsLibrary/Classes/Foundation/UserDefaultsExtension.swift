//
//  UserDefaultsExtension.swift
//  SwiftExtensionsLibrary
//
//  Created by Derrick on 2023/6/7.
//

import Foundation

public extension ExtensionBase where Base: UserDefaults {
    @discardableResult
    static func set(value: Any?,for key: String) -> Bool {
        guard value != nil else {
            return false
        }
        Base.standard.set(value, forKey: key)
        Base.standard.synchronize()
        return true
    }
    
    static func value(for key: String) -> Any? {
        return Base.standard.value(forKey: key)
    }
    
    // MARK: 1.3、移除单个key存储的值
    /// 移除单个key存储的值
    /// - Parameter key: key名
    static func remove(for key: String) {
        guard let _ = Base.standard.value(forKey: key) else {
            return
        }
        Base.standard.removeObject(forKey: key)
        
    }
    
    // MARK: 1.4、移除所有值
    /// 移除所有值
    static func removeAllKeyValue() {
        if let bundleID = Bundle.main.bundleIdentifier {
            Base.standard.removePersistentDomain(forName: bundleID)
            Base.standard.synchronize()
        }
    }
 }

// MARK: - 二、模型持久化
public extension ExtensionBase where Base: UserDefaults {
    
    // MARK: 2.1、存储模型
    /// 存储模型
    /// - Parameters:
    ///   - object: 模型
    ///   - key: 对应的key
    static func set<T: Decodable & Encodable>(object: T, for key: String) {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(object) else {
            return
        }
        Base.standard.set(encoded, forKey: key)
        Base.standard.synchronize()
    }
    
    // MARK: 2.2、取出模型
    /// 取出模型
    /// - Parameters:
    ///   - type: 当时存储的类型
    ///   - key: 对应的key
    /// - Returns: 对应类型的模型
    static func get<T: Decodable & Encodable>(of type: T.Type, for key: String) -> T? {
        
        guard let data = Base.standard.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        guard let object = try? decoder.decode(type, from: data) else {
            return nil
        }
        return object
    }
    
    //MARK: 2.3、保存模型数组
    /// 保存模型数组
    /// - Returns: 返回保存的结果
    @discardableResult
    static func set<T: Decodable & Encodable>(objects: [T],for key: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(objects)
            Base.standard.set(data, forKey: key)
            Base.standard.synchronize()
            return true
        } catch {
           print(error)
        }
        return false
    }
    
    //MARK: 2.4、读取模型数组
    ///  读取模型数组
    /// - Returns: 返回读取的模型数组
    static func get<T: Decodable & Encodable>(for key : String) -> [T] {
        guard let data = Base.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print(error)
        }
        return []
    }
}

