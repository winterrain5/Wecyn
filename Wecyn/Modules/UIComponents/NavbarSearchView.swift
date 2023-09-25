//
//  NavbarSearchView.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/28.
//

import UIKit

class NavbarSearchView: UIView,UITextFieldDelegate {
    var leftImgView = UIImageView()
    var rightTf = UITextField()
    var searching:((String)->())?
    var beginSearch:(()->())?
    var isSearchable = false
    var placeholder:String = ""
    var isBecomeFirstResponder = false
    var loadingView = UIActivityIndicatorView(style: .medium)
    init(placeholder:String,isSearchable:Bool = false,isBecomeFirstResponder:Bool = false) {
       
        super.init(frame: .zero)
        
        self.placeholder = placeholder
        self.isSearchable = isSearchable
        
        backgroundColor = R.color.backgroundColor()
        
        addSubview(leftImgView)
        leftImgView.image = R.image.magnifyingglass()
        leftImgView.contentMode = .scaleAspectFit
        
        addSubview(rightTf)
        rightTf.returnKeyType = .search
        rightTf.enablesReturnKeyAutomatically = true
        rightTf.placeholder = self.placeholder
        rightTf.font = UIFont.sk.pingFangRegular(12)
        rightTf.textColor = R.color.textColor33()
        rightTf.delegate = self
        rightTf.clearButtonMode = .whileEditing
        
        rightTf.isUserInteractionEnabled = isSearchable
        if isBecomeFirstResponder && isSearchable {
            let work = DispatchWorkItem { [weak self] in
                self?.rightTf.becomeFirstResponder()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: work)
            
        }
        
        addSubview(loadingView)
        loadingView.hidesWhenStopped = true
        loadingView.isHidden = true
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
     
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = frame.size.height * 0.5

        leftImgView.frame = CGRect(x: 20, y: 0, width: 15, height: 15)
        leftImgView.center.y = frame.center.y
        rightTf.frame = CGRect(x: 43, y: 0, width: frame.width - 51, height: frame.height)
        rightTf.center.y = frame.center.y
        
        loadingView.frame = CGRect(x: self.width - 24, y: 0, width: 8, height: 8)
        loadingView.center.y = frame.center.y
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let test = self.rightTf.text ?? ""
        if test.isEmpty { return true }
        self.searching?(test)
        self.loadingView.startAnimating()
        self.loadingView.isHidden = false
        self.endEditing(true)
        Logger.debug("search text:\(test)")
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        beginSearch?()
    }
    
    func endSearching() {
        self.loadingView.stopAnimating()
        self.loadingView.isHidden = true
    }
}
