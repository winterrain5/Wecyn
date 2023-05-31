//
//  Device.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/7/6.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
struct Device {
    static let isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    /// 获取设备名称 例如：梓辰的手机
    static let deviceName = UIDevice.current.name
    /// 获取系统名称 例如：iPhone OS
    static let sysName = UIDevice.current.systemName
    /// 获取系统版本 例如：9.2
    static let sysVersion = UIDevice.current.systemVersion
    /// 获取设备唯一标识符 例如：FBF2306E-A0D8-4F4B-BDED-9333B627D3E6
    static let deviceUUID = UIDevice.current.identifierForVendor?.uuidString
    /// 获取设备的型号 例如：iPhone
    static let deviceModel = UIDevice.current.model
    /// 获取App的版本
    static let appVersion:String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    /// 获取App的build版本
    static let appBuildVersion:String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    /// 获取App的名称
    static let appName:String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
    /// 获取具体的设备型号
    static let modelName:String = UIDevice.current.modelName

    /* 分辨率 */
    static var ratio:String {
        get {
            let scale = UIScreen.main.scale
            return "\(kScreenWidth*scale)*\(kScreenHeight*scale)"
        }
    }
    
    /// ip
   static var ipAddress: String {
       var addresses = [String]()
       var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
       if getifaddrs(&ifaddr) == 0 {
           var ptr = ifaddr
           while (ptr != nil) {
               let flags = Int32(ptr!.pointee.ifa_flags)
               var addr = ptr!.pointee.ifa_addr.pointee
               if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                   if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                       var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                       if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                           if let address = String(validatingUTF8:hostname) {
                               addresses.append(address)
                           }
                       }
                   }
               }
               ptr = ptr!.pointee.ifa_next
           }
           freeifaddrs(ifaddr)
       }
       return addresses.first ?? "0.0.0.0"
   }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
}
