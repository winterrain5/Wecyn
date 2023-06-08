//
//  WebBrowserController.swift
//  OneOnline
//
//  Created by Derrick on 2020/4/3.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit
import WebKit
import MarqueeLabel
class WebBrowserController: BaseViewController,WKUIDelegate, WKNavigationDelegate {
    
    override var shouldAutorotate: Bool {
        return !isNeedLandscape
    }
    var navTitle: String = ""
    private var url: String = ""
    private var localHtmlFileName:String = ""
    
    private var webTopSpace:CGFloat = 0
    internal var isNeedLandscape: Bool = false
    
    internal var webView: WebView?
    
    private var titleLabel = MarqueeLabel().then { label in
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        label.fadeLength = 10
        label.speed = .duration(8)
        label.animationDelay = 3
        label.frame = CGRect(x: 0, y: 0, width: kScreenWidth * 0.5, height: 40)
    }
    private lazy var closeBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 44)
        button.setTitleColor(UIColor.hexStringColor(hexString: "#333333"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("关闭", for: .normal)
        button.addTarget(self, action: #selector(closeItemAction), for: .touchUpInside)
        return button
    }()
    private lazy var backBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 44)
//        button.setImage(R.image.nav_return(), for: .normal)
        button.addTarget(self, action: #selector(leftBarButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressBar = UIProgressView().then { (view) in
        view.progressTintColor = UIColor.blue
        view.trackTintColor = .clear
        view.progress = 0
        view.progressViewStyle = .bar
    }
    
    var webViewDidClickCloseItemHandler: (() -> Void)?
    var webViewDidClickShareItemHandler: (() -> Void)?
    var webViewDidClickMoreItemHandler: (() -> Void)?
    
    init(url:String, webTopSpace:CGFloat = kNavBarHeight, isNeedLandscape: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.webTopSpace = webTopSpace
        self.url = url
        self.isNeedLandscape = isNeedLandscape
    }
    
    init(localHtmlName:String, webTopSpace:CGFloat = kNavBarHeight, isNeedLandscape: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.localHtmlFileName = localHtmlName
        self.webTopSpace = webTopSpace
        self.isNeedLandscape = isNeedLandscape
    }
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addNotification()
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc func didBecomeActive() {
        
    }
    
    
    // MARK: - seutpWebView
    
    private func setupViews() {
        self.view.backgroundColor = .white
        configWebView()
        
        let backItem = UIBarButtonItem(customView: backBtn)
        let closeItem = UIBarButtonItem(customView: closeBtn)
        closeBtn.isHidden = true
        navigation.item.leftBarButtonItems = [backItem, closeItem]
        navigation.item.titleView = titleLabel
        navigation.bar.isHidden = webTopSpace == 0
        interactivePopGestureRecognizerEnable = true
        
    }
    
    private func configWebView(){
        let controller = WKUserContentController()
        let alertCookieScript = WKUserScript(source: "alert(document.cookie)", injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        controller.addUserScript(alertCookieScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.preferences = WKPreferences()
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        configuration.processPool = WKProcessPool()
        configuration.userContentController = WKUserContentController()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        
        let webView = WebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false
        
        webView.delegate = self
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        /// 增加自定义代理
        webView.evaluateJavaScript("navigator.userAgent", completionHandler: { [weak self] result, _ in
            guard let `self` = self else { return }
            if let agent = result as? String {
                self.webView!.customUserAgent = agent + " " + "victor_iPhone" + " " + "\(kBottomsafeAreaMargin)"
            }
        })
        webView.evaluateJavaScript("window.bottomSafeAreaMargin=\(kBottomsafeAreaMargin)", completionHandler: nil)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        
        self.webView = webView
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(webTopSpace)
        }
        if !url.isEmpty {
            loadRequest(with: url)
        }
        if !localHtmlFileName.isEmpty {
            loadLocalHtml(with: localHtmlFileName)
        }
    }
    
    private func loadLocalHtml(with name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "html") {
            let request = URLRequest(url: url)
            webView?.load(request)
        }
    }
    
    private func loadRequest(with url:String) {
        webView?.loadRequest(relativeUrl: url)
    }
    
    private func setProgressbar(_ progress:Float) {
        if isNeedLandscape { return }
        self.view.addSubview(progressBar)
        progressBar.layer.zPosition = 1000
        progressBar.frame = CGRect(x: 0, y: webTopSpace, width: kScreenWidth, height: 1)
        progressBar.setProgress(progress, animated: true)
        progressBar.cornerRadius = progressBar.height * 0.5
        if progress.int == 1 {
            UIView.animate(withDuration: 0.5) {
                self.progressBar.alpha = 0
            } completion: { _ in
                self.progressBar.removeFromSuperview()
            }
        }
    }
    
    public func addMoreItem(_ imageName:String) {
        let rightItem = UIBarButtonItem(image: UIImage(named: imageName),
                                        style: .plain,
                                        target: self,
                                        action: #selector(moreItemAction))
        navigation.item.rightBarButtonItem = rightItem
    }
    
    public func addShareItem(_ imageName:String) {
        let rightItem = UIBarButtonItem(image: UIImage(named: imageName),
                                        style: .plain,
                                        target: self,
                                        action: #selector(shareItemAction))
        navigation.item.rightBarButtonItem = rightItem
    }
    
    public func removeShareItem() {
        navigation.item.rightBarButtonItem = nil
    }
    
    // MARK: - Observe
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let _ = keyPath, object as? WKWebView == webView else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == "estimatedProgress" {
            
            let progress = Float(webView?.estimatedProgress ?? 0.0)
            Logger.debug(progress)
            setProgressbar(progress)
            
        } else if keyPath == "title" {
            if !navTitle.isEmpty {
                titleLabel.text = navTitle
            } else {
                titleLabel.text = webView?.title
            }
            
        } else if keyPath == "canGoBack" {
            if let newValue = change?[NSKeyValueChangeKey.newKey] {
                let newV = newValue as? Bool ?? true
                if isNeedLandscape { return }
                closeBtn.isHidden = !newV
                interactivePopGestureRecognizerEnable = !newV
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func sendResponseMessage(cmd:Int,dataDict:[String:Any] = [:]) {
        let model = ScriptMessage()
        model.action = "JsBridgeResponse"
        model.time = Date().unixTimestamp.int
        model.messageId = Date().unixTimestamp.string
        let data = ScriptData()
        data.data = dataDict
        data.cmd = cmd
        model.data = data
        if let js = model.toJSONString() {
            callJs(js)
            Logger.debug("sendMessage:\(js)")
        }else {
            Logger.debug("model无法转成json,发送response 失败 cmd:\(cmd)")
        }
        
    }
    
    deinit {
        
        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView?.removeObserver(self, forKeyPath: "title")
        self.webView?.removeObserver(self, forKeyPath: "canGoBack")
        self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: "AppModel")
        self.webView?.configuration.userContentController.removeAllUserScripts()
        self.webView?.stopLoading()
        self.webView?.navigationDelegate = nil
        self.webView?.uiDelegate = nil
        self.webView?.delegate = nil
        self.webView?.removeFromSuperview()
        self.webView = nil
    }
    
}
// MARK: - item-action
extension WebBrowserController {
    
    @objc func leftBarButtonAction() {
        
        if webView?.canGoBack ?? false {
            webView?.goBack()
            return
        }
        close()
    }
    
    
    @objc func closeItemAction() {
        close()
    }
    
    @objc func shareItemAction() {
        webViewDidClickShareItemHandler?()
    }
    
    @objc func moreItemAction() {
        webViewDidClickMoreItemHandler?()
    }
    
    func close() {
        if let nav = self.navigationController {
            if nav.viewControllers.count > 1 && nav.viewControllers[nav.viewControllers.count - 1] == self {
                navigationController?.popViewController(animated: true, {
                    self.webViewDidClickCloseItemHandler?()
                })
            } else {
                dismiss(animated: true, completion: { [weak self] in
                    guard let `self` = self else { return }
                    self.webViewDidClickCloseItemHandler?()
                })
            }
        } else {
            dismiss(animated: true, completion: { [weak self] in
                guard let `self` = self else { return }
                self.webViewDidClickCloseItemHandler?()
            })
        }
       
    }
}

extension WebBrowserController {
    
    /// 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Logger.debug("页面开始加载\n\(webView.url?.absoluteString ?? "")")
    }
    
    /// 页面开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Logger.debug("页面开始返回")
    }
    
    /// 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.debug("页面加载完成\(webView.url?.absoluteString ?? "")")
        
    }
    
    /// 加载失败时调用
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    /// 收到服务器跳转请求之后调用
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        Logger.debug("收到服务器跳转请求之后调用" + (webView.url?.absoluteString ?? ""))
    }
    
    /// 在收到响应后，决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let url = navigationResponse.response.url?.absoluteString ?? ""
        Logger.debug("在收到响应后，决定是否跳转" + url)
        decisionHandler(.allow)
    }
    
    /// 在发送请求之前，决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        self.webView?.load((self.webView?.fix(request: navigationAction.request))!)
        return nil
    }
    
    /// 处理js里的alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default) { (_: UIAlertAction) in
            completionHandler()
        }
        alert.addAction(action)
        present(alert, animated: true) {
        }
    }
    
    /// 处理js里的confirm
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { (_: UIAlertAction) in
            completionHandler(false)
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_: UIAlertAction) in
            completionHandler(true)
        }))
        present(alert, animated: true) {
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: "", preferredStyle: .alert)
        alert.addTextField { (tf: UITextField) in
            tf.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "完成", style: .default, handler: { (_: UIAlertAction) in
            completionHandler(alert.textFields![0].text ?? "")
        }))
        
        present(alert, animated: true) {
        }
    }
}

internal final class WebViewPrintPageRenderer: UIPrintPageRenderer {
    
    private var formatter: UIPrintFormatter
    
    private var contentSize: CGSize
    
    /// 生成PrintPageRenderer实例
    ///
    /// - Parameters:
    /// - formatter: WebView的viewPrintFormatter
    /// - contentSize: WebView的ContentSize
    required init(formatter: UIPrintFormatter, contentSize: CGSize) {
        self.formatter = formatter
        self.contentSize = contentSize
        super.init()
        self.addPrintFormatter(formatter, startingAtPageAt: 0)
    }
    
    override var paperRect: CGRect {
        return CGRect.init(origin: .zero, size: contentSize)
    }
    
    override var printableRect: CGRect {
        return CGRect.init(origin: .zero, size: contentSize)
    }
    
    private func printContentToPDFPage() -> CGPDFPage? {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, self.paperRect, nil)
        self.prepare(forDrawingPages: NSMakeRange(0, 1))
        let bounds = UIGraphicsGetPDFContextBounds()
        UIGraphicsBeginPDFPage()
        self.drawPage(at: 0, in: bounds)
        UIGraphicsEndPDFContext()
        
        let cfData = data as CFData
        guard let provider = CGDataProvider.init(data: cfData) else {
            return nil
        }
        let pdfDocument = CGPDFDocument.init(provider)
        let pdfPage = pdfDocument?.page(at: 1)
        
        return pdfPage
    }
    
    private func covertPDFPageToImage(_ pdfPage: CGPDFPage) -> UIImage? {
        let pageRect = pdfPage.getBoxRect(.trimBox)
        let contentSize = CGSize.init(width: floor(pageRect.size.width), height: floor(pageRect.size.height))
        
        // usually you want UIGraphicsBeginImageContextWithOptions last parameter to be 0.0 as this will us the device's scale
        UIGraphicsBeginImageContextWithOptions(contentSize, true, 2.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.fill(pageRect)
        
        context.saveGState()
        context.translateBy(x: 0, y: contentSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.interpolationQuality = .low
        context.setRenderingIntent(.defaultIntent)
        context.drawPDFPage(pdfPage)
        context.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// print the full content of webview into one image
    ///
    /// - Important: if the size of content is very large, then the size of image will be also very large
    /// - Returns: UIImage?
    internal func printContentToImage() -> UIImage? {
        guard let pdfPage = self.printContentToPDFPage() else {
            return nil
        }
        
        let image = self.covertPDFPageToImage(pdfPage)
        return image
    }
}

extension WKWebView {
    public func takeScreenshotOfFullContent(_ completion: @escaping ((UIImage?) -> Void)) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            let renderer = WebViewPrintPageRenderer.init(formatter: self.viewPrintFormatter(), contentSize: self.scrollView.contentSize)
            let image = renderer.printContentToImage()
            completion(image)
        }
    }
}
