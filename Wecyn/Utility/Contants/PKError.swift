//
//  PKError.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/7/15.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation

enum PKError:Error {
    case reject(_ message:String = "")
    
    var message:String {
        switch self {
        case .reject(let message):
            return message
        }
    }
}
