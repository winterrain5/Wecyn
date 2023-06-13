//
//  NameCardQRCodeView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class NameCardQRCodeView: UIView {

    @IBOutlet weak var useNFCButton: UIButton!
    @IBOutlet weak var QRCodeImgView: UIImageView!

    @IBOutlet weak var closeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        closeLabel.sk.setSpecificTextUnderLine("Close", color: R.color.textColor52()!)
        useNFCButton.addShadow(cornerRadius: 6)
        
        QRCodeImgView.image = UIImage.sk.QRImage(with: "test", size: CGSize(width: 121, height: 121), logoSize: nil)
        
        closeLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            NameCardView.dismissNameCard()
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sk.addCorner(conrners: [.topLeft,.topRight], radius: 20)
    }
}
