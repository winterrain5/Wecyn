//
//  DictionaryExtension.swift
//  SwiftExtensionsLibrary
//
//  Created by Derrick on 2023/6/2.
//

import Foundation

extension Dictionary: ExtensionCompatible {}

public extension Dictionary {
    /// 检查字典里是否有个key
    func has(_ key: Key) -> Bool {
        index(forKey: key) != nil
    }

    /// 字典的key或者value组成的数组
    /// - Parameter map: map
    /// - Returns: 数组
    func toArray<V>(_ transfrom: (Key, Value) -> V) -> [V] {
        self.map(transfrom)
    }
    
    /// 字典转换为JSONString
    func toJSON() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions()) {
            let jsonStr = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            return String(jsonStr ?? "")
        }
        return nil
    }
    // MARK: 1.5、字典里面所有的 key
    /// 字典里面所有的key
    /// - Returns: key 数组
    func allKeys() -> [Key] {
        /*
         shuffled：不会改变原数组，返回一个新的随机化的数组。  可以用于let 数组
         */
        return self.keys.shuffled()
    }
    
    // MARK: 1.6、字典里面所有的 value
    /// 字典里面所有的value
    /// - Returns: value 数组
    func allValues() -> [Value] {
        return self.values.shuffled()
    }
    
}
