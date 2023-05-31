//
//  LoaddingButton.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/7/30.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
import UIKit

class LoadingButton: UIButton {

    private lazy var loadingView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView()
        v.style = .white
        return v
    }()
    var animatingColor: UIColor = .white {
        didSet {
            self.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = self.animatingColor
            }
        }
    }
    var animatedColor: UIColor = .white {
        didSet {
            self.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = self.animatedColor
            }
        }
    }
    
    var loadingColor: UIColor = .white {
        didSet {
            self.loadingView.color = loadingColor
        }
    }
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createSubviews()
    }
    
    
    private func createSubviews() {
        self.addSubview(loadingView)
        loadingView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        loadingView.frame = CGRect(x: (self.width - self.height) * 0.5, y: 0, width: self.height, height: self.height)
    }
    
    func startAnimation() {
        loadingView.isHidden = false
        self.setTitle("", for: .normal)
        loadingView.startAnimating()
        self.isUserInteractionEnabled = false
        self.isEnabled = false
    }
    
    func stopAnimation() {
        loadingView.isHidden = true
        loadingView.stopAnimating()
        self.setTitle(self.titleLabel?.text, for: .normal)
        self.isUserInteractionEnabled = true
        self.isEnabled = true
    }
    

}
