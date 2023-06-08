//
//  BundleExtension.swift
//  SwiftExtensionsLibrary_Example
//
//  Created by Derrick on 2023/6/2.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

public enum BundleType {
    // 自己module下的bundle文件
    case current
    // 其它module下的bundle文件
    case other
}

public extension ExtensionBase where Base: Bundle {
    // MARK: 1.1、通过 通过字符串地址 从 Bundle 里面获取资源文件（支持当前的 Moudle下的Bundle和其他Moudle下的 Bundle）
    /// 从 Bundle 里面获取资源文件（支持当前的 Moudle下的Bundle和其他Moudle下的 Bundle）
    /// - Parameters:
    ///   - bundleName: bundle 的名字
    ///   - resourceName: 资源的名字，比如图片的名字
    ///   - bundleType: 类型：默认 currentBundle是在自己 module 下的 bundle 文件
    /// - Returns: 资源路径
    static func pathForResource(bundleName: String, resourceName: String, bundleType: BundleType = .current) -> String {
        if bundleType == .other {
            return "Frameworks/\(bundleName).framework/\(bundleName).bundle/\(resourceName)"
        }
        return "\(bundleName).bundle/" + "\(resourceName)"
    }
    
    
    /// 通过 Bundle 里面获取资源文件（支持当前的 Moudle下的Bundle和其他Moudle下的
    /// - Parameters:
    ///   - bundleName: bundle 的名字
    ///   - resourceName: 资源的名字，比如图片的名字(需要写出完整的名字，如图片：icon@2x)
    ///   - ext: 资源类型 eg: png
    ///   - bundleType: 类型：默认 currentBundle是在自己 module 下的 bundle 文件
    /// - Returns: 资源路径
    static func resource(bundleName: String, resourceName: String, ofTyle ext: String? = nil, bundleType:  BundleType = .current) -> String? {
        let resourcePath = bundleType == .other ? "Frameworks/\(bundleName).framework/\(bundleName)" : "\(bundleName)"
        guard let bundlePath = Bundle.main.path(forResource: resourcePath, ofType: "bundle"),let bundle = Bundle(path: bundlePath) else {
            return nil
        }
        let path = bundle.path(forResource: resourceName, ofType: ext)
        return path
    }
}

extension ExtensionBase where Base: Bundle {
    
    // MARK: 2.1、App命名空间
    /// App命名空间
    static var namespace: String {
        guard let namespace =  Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else { return "" }
        return  namespace
    }
    
    // MARK: 2.2、项目/app 的名字
    /// 项目/app 的名字
    static var bundleName: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
    }
    
    // MARK: 2.3、获取app的版本号
    /// 获取app的版本号
    static var appVersion: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    }
    
    // MARK: 2.4、获取app的 Build ID
    /// 获取app的 Build ID
    static var appBuild: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""
    }
    
    // MARK: 2.5、获取app的 Bundle Identifier
    /// 获取app的 Bundle Identifier
    static var appBundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    // MARK: 2.6、Info.plist
    /// Info.plist
    static var infoDictionary: [String : Any]? {
        return Bundle.main.infoDictionary
    }
    
    // MARK: 2.7、App 名称
    /// App 名称
    static var appDisplayName: String {
        return (Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String) ?? ""
    }
}
