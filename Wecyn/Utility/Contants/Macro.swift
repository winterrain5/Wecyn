//
//  Macro.swift
//  VictorOnlineParent
//
//  Created by Derrick on 2020/6/10.
//  Copyright © 2020 Victor. All rights reserved.
//

import SwiftExtensionsLibrary
import Foundation
import RxLocalizer

// 文档目录
let DocumentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as String
// 缓存目录
let CachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as String
// 临时目录
let TempPath = NSTemporaryDirectory() as String
let LocaIdentifier = Localizer.shared.currentLanguageCodeValue ?? ""
