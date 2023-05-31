//
//  ScriptMessage.swift
//  OneOnline
//
//  Created by Derrick on 2020/4/3.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit
import HandyJSON
@objc
protocol WebViewMessageHandlerProtocol {
    @objc optional func didReceiveScriptMessage(webView: WebView, message: ScriptMessage)
}

class ScriptData:NSObject, HandyJSON {
    
    var cmd:Int = 0
    var type:Int = 0
    var data:[String:Any] = [:]
    required override init(){
           
    }
}

class ScriptMessage:NSObject, HandyJSON {
    var action: String = ""
    var time: Int = 0
    var messageId:String = ""
    var data: ScriptData = ScriptData()
    
    required override init(){
           
    }
    
    override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
    override var description: String {
        get {
            return "<{method:\(self.action),data:\(self.data)}>"
        }
    }
}
