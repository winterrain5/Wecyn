//
//  BusinessCardShareByEmailView.swift
//  Wecyn
//
//  Created by Derrick on 2024/6/28.
//

import UIKit
import KMPlaceholderTextView
import MMBAlertsPickers
import JXPagingView
import MessageUI
class BusinessCardShareByEmailView: BasePagingView {
    let model = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
    let titleLabel = UILabel().text("通过邮箱发送".innerLocalized()).color(.black).font(UIFont.systemFont(ofSize: 22, weight: .medium))
   
    let sendtoLabel = UILabel().text("发送给".innerLocalized()).color(.black).font(UIFont.systemFont(ofSize: 16, weight: .regular))
    let nameContainer = UIView()
    let nameTf = UITextField().placeholder("姓名".innerLocalized())
    let contactButton = UIButton()
    
    let emailContainer = UIView()
    let emailTf = UITextField().placeholder("name@email.com")
    
    
    let messageContainer = UIView()
    let messageLabel = UILabel().text("备注（可选）".innerLocalized()).color(.black).font(UIFont.systemFont(ofSize: 16, weight: .regular))
    let messageTf = KMPlaceholderTextView()
    
    let sendButton = UIButton()
    
    let scrollView = UIScrollView()
    let container = UIView()
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        addSubview(scrollView)
        scrollView.contentSize = CGSize(width: kScreenWidth, height: kScreenHeight)
        
        scrollView.addSubview(container)
        container.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        
        container.addSubview(titleLabel)
        
        container.addSubview(sendtoLabel)
        container.addSubview(nameContainer)
        nameContainer.backgroundColor = UIColor(hexString: "#eaf0f6")
        nameContainer.cornerRadius = 8
        nameContainer.addSubview(nameTf)
        nameTf.font = UIFont.systemFont(ofSize: 18)
        nameTf.setPlaceHolderTextColor(R.color.textColor77()!)
    
        nameContainer.addSubview(contactButton)
        contactButton.imageForNormal = R.image.personCropSquareFill()!
        contactButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            print("some tap")
            let vc = ContactsPickerViewController { contact in
                guard let contact = contact else { return }
                self.nameTf.text = contact.firstName + " " + contact.lastName
                self.emailTf.text = contact.emails.first(where: { $0.label ==  "_$!<Work>!$_"})?.email ?? ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIViewController.sk.getTopVC()?.dismiss(animated: true)
                }
                
            }
            vc.view.backgroundColor = .white
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
            
        }).disposed(by: rx.disposeBag)
        
        container.addSubview(emailContainer)
        emailContainer.backgroundColor = UIColor(hexString: "#eaf0f6")
        emailContainer.cornerRadius = 8
        emailContainer.addSubview(emailTf)
        emailTf.font = UIFont.systemFont(ofSize: 18)
        emailTf.setPlaceHolderTextColor(R.color.textColor77()!)
        
        container.addSubview(messageLabel)
        container.addSubview(messageContainer)
        messageContainer.backgroundColor = UIColor(hexString: "#eaf0f6")
        messageContainer.cornerRadius = 8
        messageContainer.addSubview(messageTf)
        messageTf.backgroundColor = .clear
        messageTf.placeholder = "备注（可选）".innerLocalized()
        messageTf.placeholderFont = UIFont.systemFont(ofSize: 18)
        messageTf.placeholderColor = R.color.textColor77()!
        messageTf.font = UIFont.systemFont(ofSize: 18)
        
        container.addSubview(sendButton)
        sendButton.titleForNormal = "发送".innerLocalized()
        sendButton.titleColorForNormal = .white
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        sendButton.backgroundColor = R.color.theamColor()
        
        sendButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            let url = APIHost.share.WebpageUrl + "/card/\(self.model?.uuid ?? "")"
            let image = UIImage.sk.QRImage(with: url, size: CGSize(width: 200, height: 200), logoSize: CGSize(width: 40, height: 40),logoImage: R.image.appicon()!,logoRoundCorner: 8)
            guard let email = self.emailTf.text,
                  let data = image?.pngData(),
                  let name =  self.model?.full_name,
                  let sendingEmail = self.model?.email,
                  let remark = self.messageTf.text else { return }
            
            
            let subject = "Sharing for \(name)"
            let body = "<p>Hi, hello!</p><br><p>\(name) sent you the following message:</p><p>\(remark)</p><br><br><p>Here's \(name)'s digital business card. You can send a message to \(name) by replying to this email.</p><br><link href=\(url)>View in Wecyn</link>"
           
            if MFMailComposeViewController.canSendMail() {  //  是否可以发邮件 //  如果不能,去系统设置接收邮箱
                let vc = MFMailComposeViewController()
                vc.mailComposeDelegate = self
                vc.setToRecipients([email])//  接收邮件的邮箱
                vc.setSubject(subject)
                vc.setPreferredSendingEmailAddress(sendingEmail)
                vc.addAttachmentData(data, mimeType: "", fileName: "business card qrcode.png")
                vc.setMessageBody(body, isHTML: true)
                UIViewController.sk.getTopVC()?.present(vc, animated: true)
            } else if let emailUrl = createEmailUrl(to: subject, subject: "", body: body) {
                UIApplication.shared.open(emailUrl)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail,UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        return defaultUrl
    }
    
 
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.snp.makeConstraints { make in
            make.top.bottom.right.left.equalToSuperview()
        }
        
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }
        
        sendtoLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
        }
        
        nameContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(60)
            make.top.equalTo(sendtoLabel.snp.bottom).offset(12)
        }
        
        contactButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        
        nameTf.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview().inset(8)
            make.right.equalTo(contactButton.snp.left).offset(-16)
        }
        
        emailContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(60)
            make.top.equalTo(nameContainer.snp.bottom).offset(8)
        }
        emailTf.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(emailContainer.snp.bottom).offset(30)
            make.right.left.equalToSuperview().inset(16)
        }
        
        messageContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(120)
            make.top.equalTo(messageLabel.snp.bottom).offset(12)
        }
        
        messageTf.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview().inset(16)
        }
        
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(messageContainer.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
            make.height.equalTo(60)
        }
        sendButton.shadow(cornerRadius: 16, color: R.color.theamColor()!.withAlphaComponent(0.4), offset: CGSize(width: 10, height: 10), radius: 20, opacity: 1)
    }

}

extension BusinessCardShareByEmailView:MFMailComposeViewControllerDelegate {
    //MARK:- Mail Delegate
    //用户退出邮件窗口时被调用
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue{
        case MFMailComposeResult.sent.rawValue:
            print("邮件已发送")
            Toast.showSuccess("Email has been sent")
        case MFMailComposeResult.cancelled.rawValue:
            print("邮件已取消")
        case MFMailComposeResult.saved.rawValue:
            print("邮件已保存")
        case MFMailComposeResult.failed.rawValue:
            print("邮件发送失败")
            Toast.showError("Email sending failed")
        default:
            print("邮件没有发送")
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
