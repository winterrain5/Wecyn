//
//  BusinessCardShareByMessageView.swift
//  Wecyn
//
//  Created by Derrick on 2024/6/28.
//

import UIKit
import KMPlaceholderTextView
import MMBAlertsPickers
import JXPagingView
import MessageUI
class BusinessCardShareByMessageView: BasePagingView {
    let model = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
    let titleLabel = UILabel().text("通过短信发送".innerLocalized()).color(.black).font(UIFont.systemFont(ofSize: 22, weight: .medium))
   
    let sendtoLabel = UILabel().text("发送给".innerLocalized()).color(.black).font(UIFont.systemFont(ofSize: 16, weight: .regular))
    let nameContainer = UIView()
    let nameTf = UITextField().placeholder("姓名".innerLocalized())
    let contactButton = UIButton()
    
    let phoneContainer = UIView()
    let phoneCodeButton = UIButton()
    let phoneCodeImageView = UIImageView()
    let lineView = UIView().backgroundColor(UIColor(hexString: "#c8d2de")!)
    let phoneTf = UITextField().placeholder("手机号码".innerLocalized())
    
    
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
                let workPhone = contact.phones.first(where: { $0.label ==  "_$!<Work>!$_"})?.number ?? ""
                let phone = contact.phones.first(where: { $0.label ==  "_$!<Mobile>!$_"})?.number ?? ""
                self.phoneTf.text = workPhone.isEmpty ? phone : workPhone
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIViewController.sk.getTopVC()?.dismiss(animated: true)
                }
                
            }
            vc.view.backgroundColor = .white
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
            
        }).disposed(by: rx.disposeBag)
        
        container.addSubview(phoneContainer)
        phoneContainer.backgroundColor = UIColor(hexString: "#eaf0f6")
        phoneContainer.cornerRadius = 8
        phoneContainer.addSubview(phoneTf)
        phoneTf.font = UIFont.systemFont(ofSize: 18)
        phoneTf.setPlaceHolderTextColor(R.color.textColor77()!)
        phoneContainer.addSubview(phoneCodeButton)
        phoneCodeButton.imageForNormal = R.image.arrowtriangleDownFill()?.scaled(toHeight: 12)
        phoneCodeButton.contentHorizontalAlignment = .right
        
        phoneCodeButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            let vc = LocalePickerViewController(type: .phoneCode) { phoneCode in
                guard let phoneCode = phoneCode else { return }
                self.phoneCodeImageView.image = phoneCode.flag
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIViewController.sk.getTopVC()?.dismiss(animated: true)
                }
                
            }
            vc.view.backgroundColor = .white
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        
        phoneContainer.addSubview(phoneCodeImageView)
        phoneCodeImageView.contentMode = .scaleAspectFit
        phoneCodeImageView.cornerRadius = 4
        var code: String?
        if #available(iOS 16, *) {
            code = Locale.current.region?.identifier
        } else {
            code = Locale.current.regionCode
        }
        if let code = code, let image = UIImage(named: code) {
            phoneCodeImageView.image = image
        }
        
        
        phoneContainer.addSubview(lineView)
        lineView.backgroundColor = UIColor(hexString: "#c4cfdc")
        
        
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
            let urlstr = APIHost.share.WebpageUrl + "/card/\(self.model?.uuid ?? "")"
            let image = UIImage.sk.QRImage(with: urlstr, size: CGSize(width: 200, height: 200), logoSize: CGSize(width: 40, height: 40),logoImage: R.image.appicon()!,logoRoundCorner: 8)
            guard let phone = self.phoneTf.text,
                  let data = image?.pngData(),
                  let name =  self.model?.full_name,
                  let sendphone = self.model?.tel_cell,
                  let remark = self.messageTf.text,
                  let url = urlstr.url else { return }
            
            guard MFMessageComposeViewController.canSendText() else {
                Toast.showError("不能发送短信".innerLocalized())
                return
            }
            let body = "Hi, hello!\n\n\(name) sent you the following message:\n\n\(remark)\nHere's \(name)'s digital business card. \n\n\(urlstr)"
            let subject = "Sharing for \(name)"
            let vc = MFMessageComposeViewController()
            vc.messageComposeDelegate = self
            vc.recipients = [phone]
            vc.body = body
            vc.subject = subject
            vc.addAttachmentURL(url, withAlternateFilename: "Business Card QRCode")
            vc.addAttachmentData(data, typeIdentifier: "image/png", filename: "Business Card QRCode.png")
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
            
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        phoneContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(56)
            make.top.equalTo(nameContainer.snp.bottom).offset(8)
        }
        phoneCodeButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        phoneCodeImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(16)
            make.width.equalTo(36)
        }
        lineView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(phoneCodeButton.snp.right).offset(16)
            make.width.equalTo(2)
        }
        phoneTf.snp.makeConstraints { make in
            make.left.equalTo(lineView.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneContainer.snp.bottom).offset(30)
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
extension BusinessCardShareByMessageView: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result.rawValue{
        case MFMailComposeResult.sent.rawValue:
            Toast.showSuccess("短信已发送".innerLocalized())
        case MFMailComposeResult.cancelled.rawValue:
            Toast.showSuccess("短信发送取消".innerLocalized())
        case MFMailComposeResult.saved.rawValue:
            Toast.showSuccess("短信已保存".innerLocalized())
        case MFMailComposeResult.failed.rawValue:
            Toast.showError("短信发送失败".innerLocalized())
        default:
            print("邮件没有发送")
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
