//
//  RegistConfirmView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit
import CodeTextField
class RegistConfirmView: UIView {
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var codeContainer: UIView!
    
    @IBOutlet weak var resendLabel: UILabel!
    
    @IBOutlet weak var messageContainer: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    var registModel = RegistRequestModel()
    
    private lazy var codeTf: CodeTextField = {
        let spacing = (kScreenWidth - 48 - 48 * 6) / 5
        let temTextField = CodeTextField(codeLength: 6,
                                         characterSpacing: spacing.ceil,
                                         validCharacterSet: CharacterSet(charactersIn: "0123456789"),
                                         characterLabelGenerator: { (_) -> LableRenderable in
            let label = StyleLabel(size: CGSize(width: 48, height: 52))
            label.style = Style.border(nomal: UIColor(hexString: "#c3c1c1")!, selected: R.color.theamColor()!)
            return label
        })
        temTextField.keyboardType = .numberPad
        return temTextField
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        emailLabel.sk.setSpecificTextColor("Edit Email", color: R.color.theamColor()!)
        emailLabel.sk.setSpecificTextUnderLine("Edit Email", color: R.color.theamColor()!)
        
        resendLabel.sk.setSpecificTextColor("Send again", color: R.color.theamColor()!)
        resendLabel.sk.setSpecificTextUnderLine("Send again", color: R.color.theamColor()!)
        
        messageLabel.sk.setSpecificTextColor("preferences", color: .black)
        messageContainer.addShadow(cornerRadius: 11)
        
        confirmButton.addShadow(cornerRadius: 20)
        
        codeContainer.addSubview(codeTf)
        
        
        emailLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            
        }).disposed(by: rx.disposeBag)
        
        resendLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            
        }).disposed(by: rx.disposeBag)
        
        confirmButton.rx.tap.subscribe(onNext:{
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(RegistAddAvatarController())
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        codeTf.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(22)
        }
    }
    
}

/// 风格
///
/// - line: 下划线
/// - border: 边框
public enum Style {
    
    case line(nomal: UIColor, selected: UIColor)
    case border(nomal: UIColor, selected: UIColor)
    
    public var nomal: UIColor {
        switch self {
        case let .line(nomal, _):
            return nomal
        case let .border(nomal, _):
            return nomal
        }
    }
    
    public var selected: UIColor {
        switch self {
        case let .line(_, selected):
            return selected
        case let .border(_, selected):
            return selected
        }
    }
}

/// MARK - 标签
public class StyleLabel: UILabel, CodeLable {
    
    /// 大小
    public var itemSize: CGSize
    
    /// 风格
    public var style: Style = Style.line(nomal: UIColor.gray, selected: UIColor.red) {
        didSet {
            switch style {
            case .line:
                layer.addSublayer(lineLayer)
                lineLayer.backgroundColor = style.nomal.cgColor
                layer.borderWidth = 0
                layer.borderColor = UIColor.clear.cgColor
            default:
                lineLayer.removeFromSuperlayer()
                layer.borderWidth = 1
                layer.borderColor = style.nomal.cgColor
                layer.cornerRadius = 11
                layer.masksToBounds = true
            }
        }
    }
    
    /// 是否编辑
    private var isEditing = false
    
    /// 是否焦点
    private var isFocusingCharacter = false
    
    /// 线
    private lazy var lineLayer: CALayer = {
        let temLayer = CALayer()
        let lineHeight: CGFloat = 1
        temLayer.frame = CGRect(x: 0, y: itemSize.height - lineHeight, width: itemSize.width, height: lineHeight)
        temLayer.backgroundColor = self.style.nomal.cgColor
        return temLayer
    }()
    
    init(size: CGSize) {
        self.itemSize = size
        super.init(frame: CGRect.zero)
        layer.addSublayer(lineLayer)
    }
    
    
    /// 刷新文本
    ///
    /// - Parameters:
    ///   - character: character
    ///   - isFocusingCharacter: isFocusingCharacter
    ///   - isEditing: isEditing
    public func update(character: Character?, isFocusingCharacter: Bool, isEditing: Bool) {
        
        text = character.map { String($0) }
        self.isEditing = isEditing
        self.isFocusingCharacter = isFocusingCharacter
        if (text?.isEmpty ?? true) == false || (isEditing && isFocusingCharacter) {
            switch style {
            case .line:
                lineLayer.backgroundColor = style.selected.cgColor
            default:
                layer.borderColor = style.selected.cgColor
            }
        } else {
            switch style {
            case .line:
                lineLayer.backgroundColor = style.nomal.cgColor
            default:
                layer.borderColor = style.nomal.cgColor
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
