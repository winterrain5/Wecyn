//
//  WebBrowserMessageHandlerController.swift
//  OneOnline
//
//  Created by Derrick on 2020/4/13.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit

extension WebBrowserController: WebViewMessageHandlerProtocol {
    
    func didReceiveScriptMessage(webView: WebView, message: ScriptMessage) {
        
       
    }

    func callJs(_ js:String) {
        self.webView?.callJS(jsMethod: "Message.receiveMsg" + "('\(js)')")
    }
}
