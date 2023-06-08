//
//  FileManagerExtension.swift
//  SwiftExtensionsLibrary
//
//  Created by Derrick on 2023/6/2.
//

import Foundation
import AVKit
// MARK: - 一、沙盒路径的获取
/*
 - 1、Home(应用程序包)目录
 - 整个应用程序各文档所在的目录,包含了所有的资源文件和可执行文件
 - 2、Documents
 - 保存应用运行时生成的需要持久化的数据，iTunes同步设备时会备份该目录
 - 需要保存由"应用程序本身"产生的文件或者数据，例如: 游戏进度，涂鸦软件的绘图
 - 目录中的文件会被自动保存在 iCloud
 - 注意: 不要保存从网络上下载的文件，否则会无法上架!
 - 3、Library
 - 3.1、Library/Cache
 - 保存应用运行时生成的需要持久化的数据，iTunes同步设备时不备份该目录。一般存放体积大、不需要备份的非重要数据
 - 保存临时文件,"后续需要使用"，例如: 缓存的图片，离线数据（地图数据）
 - 系统不会清理 cache 目录中的文件
 - 就要求程序开发时, "必须提供 cache 目录的清理解决方案"
 - 3.2、Library/Preference
 - 保存应用的所有偏好设置，IOS的Settings应用会在该目录中查找应用的设置信息。iTunes
 - 用户偏好，使用 NSUserDefault 直接读写！
 - 如果想要数据及时写入硬盘，还需要调用一个同步方法
 - 4、tmp
 - 保存临时文件，"后续不需要使用"
 - tmp 目录中的文件，系统会自动被清空
 - 重新启动手机, tmp 目录会被清空
 - 系统磁盘空间不足时，系统也会自动清理
 - 保存应用运行时所需要的临时数据，使用完毕后再将相应的文件从该目录删除。应用没有运行，系统也可能会清除该目录下的文件，iTunes不会同步备份该目录
 */

public enum SanboxPath {
    case Directory
    case Documents
    case Library
    case Cache
    case Preferences
    case Tmp
}


public extension ExtensionBase where Base: FileManager {
    /// 获取Home的完整路径名
    static var homeDirectory: String  {
        NSHomeDirectory()
    }
    /// 获取Documnets的完整路径名
    static var documentsDirectory: String {
        return NSHomeDirectory() + "/Documents"
    }
    /// 获取Library的完整路径名
    static var LibraryDirectory: String {
        return NSHomeDirectory() + "/Library"
    }
    /// 获取/Library/Caches的完整路径名
    static var CachesDirectory: String {
        //获取程序的/Library/Caches目录
        return NSHomeDirectory() + "/Library/Caches"
    }
    /// 获取Library/Preferences的完整路径名
    static var PreferencesDirectory: String {
        return NSHomeDirectory() + "/Library/Preferences"
    }
    /// 获取Tmp的完整路径名，用于存放临时文件，保存应用程序再次启动过程中不需要的信息，重启后清空
    static var TmpDirectory: String {
        return  NSHomeDirectory() + "/tmp"
    }
}

public extension ExtensionBase where Base: FileManager {
    /// 文件写入类型
    enum FileriteType {
        case Text
        case Image
        case Array
        case Dictionary
    }
    /// 移动或者拷贝的类型
    enum MoveCopyType {
        case File
        case Direcory
    }
    
    static var fileManager: FileManager {
        return FileManager.default
    }
    
    
}
