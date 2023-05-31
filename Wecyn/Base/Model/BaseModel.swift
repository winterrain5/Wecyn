//
//  BaseModel.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/6/28.
//

import Foundation
class BaseModel: NSObject, HandyJSON {    
    required override init() {
        super.init()
    }
    func mapping(mapper: HelpingMapper) {}
    
}
