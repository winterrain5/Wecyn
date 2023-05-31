//
//  WebView.swift
//  OneOnline
//
//  Created by Derrick on 2020/4/3.
//  Copyright © 2020 OneOnline. All rights reserved.
//
import UIKit
import WebKit
import SwiftyJSON
class WebView: WKWebView {
    
    ///webview加载的url地址是否需要已经转义. 默认，不需要
    var isGenerateURL: Bool = false
    
    ///webview加载的url地址
    var webViewRequestUrl: String = ""
    
    ///webview加载的参数
    var webViewRequestParams: [String: Any] = [:]
    
    weak var delegate: WebViewMessageHandlerProtocol?
    
    var receiveScriptMessageCallback: ((String)->())?
    
    var baseUrl: URL?
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        configuration.userContentController.add(self as WKScriptMessageHandler, name: "AppModel")
        self.baseUrl = URL(string: "")
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - load Url
    func loadRequest(relativeUrl: String?) {
        loadRequest(relativeUrl: relativeUrl, params: nil)
    }
    
    func loadRequest(relativeUrl: String?, params: [String : Any]?) {
        /*默认的缓存策略， 如果缓存不存在，直接从服务端获取。如果缓存存在，会根据response中的Cache-Control字段判断下一步操作，如: Cache-Control字段为must-revalidata, 则询问服务端该数据是否有更新，无更新的话直接返回给用户缓存数据，若已更新，则请求服务端.他是有服务器决定客户端到底是用缓存还是不用缓存，根据Cache-Control来确定，如果过期或者数据被改动就不用缓存，直接加载服务端数据，一般在Get方法中才使用到缓存，Post她变化比较多一般不使用缓存。*/
        if isGenerateURL {
            let url = generateURL(baseURL: relativeUrl, params: params)
            load(URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 8))
        } else {
            let url = URL(string: relativeUrl ?? "")
            var request: URLRequest?
            if let url = url {
                request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 8)
            }
            if let request = request {
                load(request)
            }else{
                Logger.debug("无效的URL\(String(describing: relativeUrl))")
            }
        }
    }
    
    @discardableResult
    func generateURL( baseURL: String?, params: [String : Any]?) -> URL? {
        var baseURL = baseURL
        webViewRequestUrl = baseURL ?? ""
        webViewRequestParams = params ?? ["":""]
        let param = params
        var pairs = [String]()
        
        param?.forEach({ (key, value) in
            let urlStr = value as! String
            let escaped_value = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let item = "\(key)=\(escaped_value ?? "")"
            pairs.append(item)
        })
        
        let query = pairs.joined(separator: "&")
        baseURL = baseURL?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        var url = ""
        if baseURL?.contains("?") ?? false {
            url = "\(baseURL ?? "")&\(query)"
        } else {
            url = "\(baseURL ?? "")?\(query)"
        }
        //绝对地址
        if url.lowercased().hasPrefix("http") {
            return URL(string: url)
        } else {
            return URL(string: url, relativeTo: baseUrl)
        }
    }
    
    
    ///修复打开链接Cookie丢失
    @discardableResult
    func fix(request: URLRequest?) -> URLRequest? {
        var fixedRequest = request
        //取出cookies 重新设置
        var dict: [String : String]?
        if let shared = HTTPCookieStorage.shared.cookies {
            dict = HTTPCookie.requestHeaderFields(with: shared)
        }
        var mDict = request?.allHTTPHeaderFields
        if let dict = dict {
            dict.forEach { (arg0) in
                let (key, value) = arg0
                mDict?[key] = value
            }

        }
        fixedRequest?.allHTTPHeaderFields = mDict
        return fixedRequest! as URLRequest
    }
    
    /// 加载本地HTML页面
    func loadLocalHTML(withFileName htmlName: String) {
        let path = Bundle.main.bundlePath
        let baseURL = URL(fileURLWithPath: path)
        let htmlPath = Bundle.main.path(forResource: htmlName, ofType: "html")
        let htmlCont = try? String(contentsOfFile: htmlPath ?? "", encoding: .utf8)
        
        loadHTMLString(htmlCont ?? "", baseURL: baseURL)
    }
    
    /// 重新加载webview
    func reloadWebView() {
        loadRequest(relativeUrl: webViewRequestUrl, params: webViewRequestParams)
    }
    
    //MARK: - JS
    func callJS(jsMethod: String?) {
        callJS(jsMethod: jsMethod, handler: { _ in })
    }
    
    func callJS(jsMethod: String?, handler: @escaping (Any?) -> Void) {
        evaluateJavaScript(jsMethod ?? "", completionHandler: { response, error in
            if error == nil {
                handler(response)
            }
        })
    }
    
}
extension WebView: WKScriptMessageHandler, WebViewMessageHandlerProtocol {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let dict = JSON(message.body).rawString()
        self.receiveScriptMessageCallback?(dict ?? "")
        Logger.debug("message:\(dict ?? "")")
        if let msg = ScriptMessage.deserialize(from: dict) {
            guard let function = self.delegate?.didReceiveScriptMessage else {
                return
            }
            function(self, msg)
        }
        
    }
    
}
