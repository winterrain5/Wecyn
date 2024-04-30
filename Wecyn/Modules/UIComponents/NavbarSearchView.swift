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
    var searchTextChanged:((String)->())?
    var beginSearch:(()->())?
    
    var isSearchable = false
    var placeholder:String = ""
    var isBecomeFirstResponder = false
    var loadingView = UIActivityIndicatorView(style: .medium)
    var searchText: String? {
        didSet {
            guard let text = searchText else { return }
            rightTf.text = text
            let work = DispatchWorkItem { [weak self] in
                self?.rightTf.becomeFirstResponder()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: work)
        }
    }
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
        
        rightTf.rx.text.orEmpty.changed.subscribe(onNext:{ [weak self] in
            self?.searchTextChanged?($0)
        }).disposed(by: rx.disposeBag)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = frame.size.height * 0.5

        leftImgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
      
        
        loadingView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(8)
            make.centerY.equalToSuperview()
        }
        
        
        rightTf.snp.makeConstraints { make in
            make.left.equalTo(leftImgView.snp.right).offset(16)
            make.right.equalTo(loadingView.snp.left).inset(16)
            make.height.equalToSuperview()
        }
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let test = self.rightTf.text ?? ""
        if test.isEmpty { return true }
        self.searching?(test)
        self.endEditing(true)
        Logger.debug("search text:\(test)")
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        beginSearch?()
    }
    
    func startLoading() {
        self.loadingView.startAnimating()
        self.loadingView.isHidden = false
    }
    
    
    func stoploading() {
        self.loadingView.stopAnimating()
        self.loadingView.isHidden = true
    }
}
