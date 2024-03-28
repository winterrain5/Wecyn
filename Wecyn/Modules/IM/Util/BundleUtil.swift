//
//  BundleUtil.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/27.
//

import Foundation

struct BundleUtil  {
    public static func getResourceBundle() -> Bundle? {
        guard let path = Bundle(for: IMController.self).resourcePath else { return nil }
        var finalPath: String = path
        finalPath.append("/OIMUIResource.bundle")
        let bundle = Bundle(path: finalPath)
        return bundle
    }
    public static func getEmojiBundle() -> Bundle? {
        guard let path = Bundle(for: IMController.self).resourcePath else { return nil }
        var finalPath: String = path
        finalPath.append("/OIMUIEmoji.bundle")
        let bundle = Bundle(path: finalPath)
        return bundle
    }
}
