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
    func isHasSpecialSymbol() -> Bool {
      let rule = "#@!~%^&*"
      var result = false
      for c in self.charactersArray {
        if rule.charactersArray.contains(c) {
          result = true
          break
        }
      }
      return result
    }
    
    func valiatePassword() -> (flag:Bool,message:String){
        var errorMessage = ""
        if self.count < 8 {
          /// ・Passwords need to be at least 6 characters ・At least one lowercase character ・At lease one uppercase character ・Must have numerical number
          errorMessage += "Passwords need to be at least 6 characters\n"
        }
        if !self.isHasLowercaseCharacter() {
          errorMessage += "At least one lowercase character \n"
        }
        if !self.isHasUppercaseCharacter() {
          errorMessage += "At lease one uppercase character \n"
        }
        if !self.hasNumbers {
          errorMessage += "Must have numerical number\n"
        }
        if self.isHasSpecialSymbol() {
          errorMessage += "Password cannot contain special characters such as \"#@!~%^&*\"\n"
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
   static func fullName(first: String, last: String) -> String{
        let full = first + " " + last
        return full
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
}
