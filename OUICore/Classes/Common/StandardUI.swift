
import UIKit

public let kScreenWidth: CGFloat = UIScreen.main.bounds.size.width
public let kScreenHeight: CGFloat = UIScreen.main.bounds.size.height
public let kStatusBarHeight: CGFloat = {
    if #available(iOS 13.0, *) {
        guard let statusBarHeight = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height, statusBarHeight != 0 else { return 0 }
        return statusBarHeight
    } else {
        return UIApplication.shared.statusBarFrame.size.height
    }
}()

public let kSafeAreaBottomHeight: CGFloat = {
    guard let bottomHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom else { return 0 }
    return bottomHeight
}()

public let isIPhoneXSeries: Bool = {
    guard let bottomHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom, bottomHeight > 0 else { return false }
    return true
}()

extension UIFont {
    public static let f20 = UIFont.preferredFont(forTextStyle: .title3)
    public static let f17 = UIFont.preferredFont(forTextStyle: .body)
    public static let f14 = UIFont.preferredFont(forTextStyle: .footnote)
    public static let f12 = UIFont.preferredFont(forTextStyle: .caption1)
}

extension UIColor {
    public static let c0089FF = #colorLiteral(red: 0, green: 0.537254902, blue: 1, alpha: 1)
    public static let c0C1C33 = #colorLiteral(red: 0.04705882353, green: 0.1098039216, blue: 0.2, alpha: 1)
    public static let c8E9AB0 = #colorLiteral(red: 0.5568627451, green: 0.6039215686, blue: 0.6901960784, alpha: 1)
    public static let cE8EAEF = #colorLiteral(red: 0.9098039216, green: 0.9176470588, blue: 0.937254902, alpha: 1)
    public static let cFF381F = #colorLiteral(red: 1, green: 0.2196078431, blue: 0.1215686275, alpha: 1)
    public static let c6085B1 = #colorLiteral(red: 0.3764705882, green: 0.5215686275, blue: 0.6941176471, alpha: 1)
    public static let cCCE7FE = #colorLiteral(red: 0.8, green: 0.9058823529, blue: 0.9960784314, alpha: 1)
    public static let cF4F5F7 = #colorLiteral(red: 0.9589777589, green: 0.9590675235, blue: 0.9702622294, alpha: 1)
    public static let cF8F9FA = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 0.9803921569, alpha: 1)
    public static let cF0F2F6 = #colorLiteral(red: 0.9411764706, green: 0.9490196078, blue: 0.9647058824, alpha: 1)
    public static let cB3D7FF = #colorLiteral(red: 0.7019607843, green: 0.8431372549, blue: 1, alpha: 1)
    public static let cF0F0F0 = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    public static let cF1F1F1 = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
    public static let viewBackgroundColor = UIColor.systemGroupedBackground
    public static let cellBackgroundColor = UIColor.tertiarySystemBackground
    public static let sepratorColor = UIColor.separator
}

extension CGFloat {
    public static let margin8 = 8.0
    public static let margin16 = 16.0
    public static let margin24 = 24.0
}

extension Int {
    public static let margin8 = 8
    public static let margin16 = 16
    public static let margin24 = 24
}

public struct StandardUI {
    public static let color_0089FF = #colorLiteral(red: 0, green: 0.537254902, blue: 1, alpha: 1)
    public static let color_0C1C33 = #colorLiteral(red: 0.04705882353, green: 0.1098039216, blue: 0.2, alpha: 1)
    public static let color_8E9AB0 = #colorLiteral(red: 0.5568627451, green: 0.6039215686, blue: 0.6901960784, alpha: 1)
    public static let color_E8EAEF = #colorLiteral(red: 0.9098039216, green: 0.9176470588, blue: 0.937254902, alpha: 1)
    public static let color_FF381F = #colorLiteral(red: 1, green: 0.2196078431, blue: 0.1215686275, alpha: 1)
    public static let color_6085B1 = #colorLiteral(red: 0.3764705882, green: 0.5215686275, blue: 0.6941176471, alpha: 1)
    public static let color_CCE7FE = #colorLiteral(red: 0.8, green: 0.9058823529, blue: 0.9960784314, alpha: 1)
    public static let color_F4F5F7 = #colorLiteral(red: 0.2705882353, green: 0.9607843137, blue: 0.968627451, alpha: 1)
    public static let color_F8F9FA = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 0.9803921569, alpha: 1)
    public static let color_F0F2F6 = #colorLiteral(red: 0.9411764706, green: 0.9490196078, blue: 0.9647058824, alpha: 1)
    
    
    public static let bigFont = UIFont.preferredFont(forTextStyle: .title1) // 48
    public static let normalFont = UIFont.preferredFont(forTextStyle: .body) // 42
    public static let Font17 = UIFont.preferredFont(forTextStyle: .body) // 42
    public static let Font12 = UIFont.preferredFont(forTextStyle: .footnote) // 14
    
    public static let tailSize: CGFloat = 5

    public static let maxWidth: CGFloat = 0.65

    public static let cornerRadius = 5.0
    /// 文本黑色
    public static let color_333333 = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    /// 文本灰色
    public static let color_999999 = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    public static let color_666666 = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    /// 主题蓝色
    public static let color_1B72EC = #colorLiteral(red: 0.1058823529, green: 0.4470588235, blue: 0.9254901961, alpha: 1)
    /// badge红色
    public static let color_F44038 = #colorLiteral(red: 0.9568627451, green: 0.2509803922, blue: 0.2196078431, alpha: 1)
    /// 分割线白色
    public static let color_F1F1F1 = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
    /// 分割线浅灰色
    public static let color_E9E9E9 = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)
    /// 主题文本蓝色
    public static let color_418AE5 = #colorLiteral(red: 0.2549019608, green: 0.5411764706, blue: 0.8980392157, alpha: 1)
    /// 按钮文本灰色
    public static let color_898989 = #colorLiteral(red: 0.537254902, green: 0.537254902, blue: 0.537254902, alpha: 1)
    /// 提示文本浅灰色
    public static let color_BEBEBE = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1)
    /// 状态绿色
    public static let color_10CC64 = #colorLiteral(red: 0.06274509804, green: 0.8, blue: 0.3921568627, alpha: 1)
    
    
    public static let margin_22: CGFloat = 22
    public static let avatar_42: CGFloat = 42
    /// 默认头像
    public static let avatar_placeholder = "contact_my_friend_icon"
    
    public static let avatarWidth: CGFloat = 44.0
}
