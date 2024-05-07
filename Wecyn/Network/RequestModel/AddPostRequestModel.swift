//
//  AddPostRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2024/5/7.
//

import UIKit

class AddPostRequestModel: BaseModel {
    var content:String?
    var video:String?
    var images:[String]?
    var type:Int = 1
    var at_list:[Int] = []
}
