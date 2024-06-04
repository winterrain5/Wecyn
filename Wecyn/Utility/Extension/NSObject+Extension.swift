//
//  NSObject+Rx.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/6/28.
//

import Foundation
fileprivate var disposeBagContext: UInt8 = 0

extension Reactive where Base: AnyObject {
    func synchronizedBag<T>( _ action: () -> T) -> T {
        objc_sync_enter(self.base)
        let result = action()
        objc_sync_exit(self.base)
        return result
    }
}

public extension Reactive where Base: AnyObject {
    
    /// a unique DisposeBag that is related to the Reactive.Base instance only for Reference type
    var disposeBag: DisposeBag {
        get {
            return synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(base, &disposeBagContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(base, &disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        
        set {
            synchronizedBag {
                objc_setAssociatedObject(base, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}


extension String {
    func isPasswordRuler() -> Bool {
        let passwordRule = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{6,}$"
        let regexPassword = NSPredicate(format: "SELF MATCHES %@",passwordRule)
        if regexPassword.evaluate(with: self) == true {
            return true
        }else
        {
            return false
        }
    }
    
    func isHasLowercaseCharacter() -> Bool {
        let rule = "(?s)[^a-z]*[a-z].*"
        let regex = NSPredicate(format: "SELF MATCHES %@",rule)
        if regex.evaluate(with: self) {
            return true
        }else
        {
            return false
        }
    }
    func isHasUppercaseCharacter() -> Bool {
        let rule = "(?s)[^A-Z]*[A-Z].*"
        let regex = NSPredicate(format: "SELF MATCHES %@",rule)
        if regex.evaluate(with: self) {
            return true
        }else
        {
            return false
        }
    }

    
    func valiatePassword() -> (flag:Bool,message:String){
        var errorMessage = ""
        if self.count < 8 {
            errorMessage += "·Passwords need to be at least 8 characters\n"
        }
        if !self.isHasLowercaseCharacter() {
            errorMessage += "·At least one lowercase character \n"
        }
        if !self.isHasUppercaseCharacter() {
            errorMessage += "·At lease one uppercase character \n"
        }
        if !self.hasNumbers {
            errorMessage += "·Must have numerical number\n"
        }
        let result = errorMessage.isEmpty ? (flag: false,message: "") : (flag:true,message: errorMessage)
        return result
    }
}

extension String {
    var avatarUrl: URL? {
        let host = APIHost.share.ImageUrl
        return URL(string: host.appending("/media/avatar/" + self))
    }
    var coverUrl: URL? {
        let host = APIHost.share.ImageUrl
        return URL(string: host.appending("/media/cover/" + self))
    }
    
    
    static func fullName(first: String, last: String) -> String{
        let full = first + " " + last
        return full.replacingOccurrences(of: "\n", with: "")
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func filterHTML() -> String {
        
        let scanner = Scanner(string: self)
        var text:NSString?
        var result:String = self
        
        while scanner.isAtEnd == false {
            scanner.scanUpTo("<", into: nil)
            scanner.scanUpTo(">", into: &text)
            result = result.replacingOccurrences(of: "\(text ?? "")>", with: "")
        }
        return result
    }
    
    func toDate(format: String,
                locaIdentifier:String = Locale.current.identifier,
                isZero:Bool = false) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: locaIdentifier)
        dateFormatter.dateFormat = format
        
        if isZero {
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        }
        
        return dateFormatter.date(from: self)
    }

}


extension String {
    
    func getWidthWithLabel(font: UIFont) -> CGFloat {
        let temlabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 0))
        temlabel.text = self
        temlabel.font = font
        temlabel.sizeToFit()
        let temwidth = temlabel.frame.size.width
        return ceil(temwidth)
    }
    func getHeightWithLabel(font: UIFont) -> CGFloat {
        let temlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.greatestFiniteMagnitude))
        temlabel.text = self
        temlabel.font = font
        temlabel.sizeToFit()
        let temwidth = temlabel.frame.size.height
        return ceil(temwidth)
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    static var className: String {
        return String(describing: self)
    }
}

extension Date {
    func startOfCurrentMonth() -> Date {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents(
            Set<Calendar.Component>([.year, .month]), from: self)
        let startOfMonth = calendar.date(from: components)!
        return startOfMonth
    }
    
    //本月结束日期
    func endOfCurrentMonth() -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        let endOfMonth =  calendar.date(byAdding: components, to: startOfCurrentMonth())!
        return endOfMonth
    }
    
    func toString(format: String = DateFormat.ddMMyyyyHHmm.rawValue,
                  locaIdentifier:String = Locale.current.identifier,
                  isZero: Bool = false) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: locaIdentifier)
        
        if isZero {
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        }
     
        return dateFormatter.string(from: self)
    }
    
    

}


extension UIImage {
    func tintImage(_ color:UIColor) -> UIImage {
        self.withTintColor(color).withRenderingMode(.alwaysOriginal)
    }
    func compressionImageToBase64(_ size:Int) -> String {
        guard let data = self.jpegData(compressionQuality: 1) else { return "" }
        guard let result = try? ImageCompress.compressImageData(data, limitDataSize: size * 1024) else { return "" }
        let base64 = result.base64EncodedString()
        
        print("image.kilobytesSize:\(UIImage.init(base64String: base64)?.kilobytesSize ?? 0),base64kilobytesSize:\(base64.lengthOfBytes(using: .utf8) / 1024)")
        return base64
    }
    
    func rotateImageByOrientation() -> UIImage {
        // No-op if the orientation is already correct
        guard self.imageOrientation != .up else {
            return self
        }

        let transform = calculateAffineTransform()

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
            bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
            space: self.cgImage!.colorSpace!,
            bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx!.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            
        default:
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        if let cgImage = ctx!.makeImage() {
            return UIImage(cgImage: cgImage)
        } else {
            return self
        }
    }

    fileprivate func calculateAffineTransform() -> CGAffineTransform {
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)

        default:
            break
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        default:
            break
        }

        return transform
    }
}



extension UIApplication {
    // 查找keyWindow
    var keyWindow: UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .filter({ $0.isKeyWindow })
            .last
    }
}


extension UIDevice {
    static let window = UIApplication.shared.keyWindow
    
    static var topSafeAreaMargin:CGFloat {
        return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    }
    static var bottomSafeAreaMargin:CGFloat {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }
    static var navigationBarHeight:CGFloat {
        return 44.0
    }
    static var tabbarHeight:CGFloat {
        return 49.0
    }
    static var statusBarHeight:CGFloat {
         let statusBarManager = UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.statusBarManager }
            .last
        return statusBarManager?.statusBarFrame.size.height ?? 0
    }
    
    static var isiPhoneX:Bool {
        topSafeAreaMargin > 0
    }
}


/// 导航栏总高度
var kNavBarHeight: CGFloat {
    return UIDevice.navigationBarHeight + UIDevice.statusBarHeight
}
/// tab栏高度总高度
var kTabBarHeight: CGFloat {
    return UIDevice.tabbarHeight + UIDevice.bottomSafeAreaMargin
}
/// 底部安全区域
let kBottomsafeAreaMargin: CGFloat = UIDevice.bottomSafeAreaMargin
/// 顶部安全区域
let kTopsafeAreaMargin: CGFloat = UIDevice.topSafeAreaMargin
/// 状态栏高度
let kStatusBarHeight: CGFloat = UIDevice.statusBarHeight
/// 屏幕高度
let kScreenHeight:CGFloat = UIScreen.main.bounds.size.height
/// 屏幕宽度
let kScreenWidth:CGFloat = UIScreen.main.bounds.size.width

