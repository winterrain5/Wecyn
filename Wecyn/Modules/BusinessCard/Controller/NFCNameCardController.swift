//
//  NFCNameCardController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/26.
//

import UIKit
import NFCReaderWriter
import SafariServices
import MessageUI
import ImagePickerSwift
import Photos

enum NameCardDataType {
    case FirstName
    case LastName
    case Headline
    case CompanyName
    case Mobile
    case OfficeNumber
    case Email
    case OfficeLocation
    case Website
}

class NameCardModel {
    var img:UIImage?
    var value:String
    var type:NameCardDataType
    
    init(img: UIImage?, value: String, type: NameCardDataType) {
        self.img = img
        self.value = value
        self.type = type
    }
}

class NFCNameCardController: BaseTableController,SFSafariViewControllerDelegate,MFMailComposeViewControllerDelegate ,MFMessageComposeViewControllerDelegate{
    let readerWriter = NFCReaderWriter.sharedInstance()
    let namecardView = NFCNameCardView()
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToPickBusinessCard()
        v.didPhotoSelected = { [weak self, weak v] (images: [UIImage], assets: [PHAsset], _: Bool) in
            guard let self else { return }
            
            for (index, asset) in assets.enumerated() {
                switch asset.mediaType {
                case .image:
                    
                    let vc = AddNewBusinessCardController(image: images[index])
                    self.navigationController?.pushViewController(vc)
                    
                default:
                    break
                }
            }
        }

        v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
            guard let self else { return }
            
            if let photo {
                let vc = AddNewBusinessCardController(image: photo)
                self.navigationController?.pushViewController(vc)
                
            }
        }
        return v
    }()
    
    var datas:[NameCardModel] = []
    var id:Int? = nil
    var uuid:String? = nil
    init(id:Int? = nil,uuid:String? = nil){
        self.id = id
        self.uuid = uuid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isSkeletonable = true
    }
    
    func addBarItem() {
        
        self.navigation.bar.alpha = 0
        
        let scan = UIButton()
        scan.imageForNormal = R.image.viewfinderCircleFill()
        scan.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            
            let alert = UIAlertController.init(title: "Scan BusinessCard", message: "Select photo from camera or photolibrary", preferredStyle: .actionSheet)
            
            alert.addAction(title: "Camera",style: .destructive) { _ in
                self.showImagePickerController(sourceType: .camera)
            }
            alert.addAction(title: "PhotoLibrary",style: .destructive) { _ in
                self.showImagePickerController(sourceType: .photoLibrary)
            }
            
            
            alert.addAction(title: "Cancel",style: .cancel)
            
            alert.show()
           
            
        
        }).disposed(by: rx.disposeBag)
        let scanItem = UIBarButtonItem(customView: scan)
        self.navigation.item.leftBarButtonItem = scanItem
        
        let editButton = UIButton()
        let editItem = UIBarButtonItem(customView: editButton)
        editButton.rx.tap.subscribe(onNext:{ [weak self] in
            let vc = NFCNameCardEditController()
            self?.navigationController?.pushViewController(vc)
            vc.updateComplete = {
                self?.refreshData()
            }
        }).disposed(by: rx.disposeBag)
        editButton.imageForNormal = R.image.squareAndPencilCircleFill()
        
      
        
        let shareButton = UIButton()
        let shareItem = UIBarButtonItem(customView: shareButton)
        shareButton.imageForNormal = R.image.squareAndArrowUpCircleFill()
        shareButton.showsMenuAsPrimaryAction = true
        let action1 = UIAction(title:"Share url with others") { _ in
            let uuid = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.uuid ?? ""
            let shareURLString = APIHost.share.WebpageUrl + "/card/\(uuid)"
            guard let url = URL(string: shareURLString) else {
                return
            }
            
            let vc = VisualActivityViewController(url: url)
            vc.previewLinkColor = .magenta
            self.present(vc, animated: true)
        }
        let action2 = UIAction(title:"Share QR code") { _ in
            let uuid = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.uuid ?? ""
            let shareURLString = APIHost.share.WebpageUrl + "/card/\(uuid)"
            guard let image = UIImage.sk.QRImage(with: shareURLString, size: CGSize(width: 120, height: 120), logoSize: nil) else {
                return
            }
            let vc = VisualActivityViewController(image: image)
            vc.previewImageSideLength = 40
            self.present(vc, animated: true)
        }
        let menuItems = [action1,action2]
        let menu = UIMenu(children: menuItems)
        shareButton.menu = menu
        
        let fixItem2 = UIBarButtonItem.fixedSpace(width: 22)
        
        self.navigation.item.rightBarButtonItems = [editItem,fixItem2,shareItem]
        
        if  self.navigationController?.children.count ?? 0  > 1 {
            self.addLeftBarButtonItem(image: R.image.xmarkCircleFill())
            self.leftButtonDidClick = { [weak self] in
                self?.returnBack()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    override func refreshData() {
        
        if self.id == nil { // 查看自己的名片
            addBarItem()
            UserService.getUserInfo().subscribe(onNext:{
                UserDefaults.sk.set(object: $0, for: UserInfoModel.className)
                self.addWriteToNFCTagFooter()
                self.addDatas($0)
                Logger.debug($0, label: "getUserInfo")
            },onError: { e in
            }).disposed(by: rx.disposeBag)
            return
        }
        
        
        guard let id = self.id else { return }
        
        let fuserInfo = NetworkService.friendUserInfo(id)
        let fNameCard = NetworkService.friendNameCard(uuid: uuid,id:id)
        Observable.zip(fuserInfo,fNameCard).subscribe(onNext:{ info, namecard in
            /// 1 没关系，2 好友关系，3 已申请好友，4 被申请好友
            if info.friend_status == 1 {
                self.addConnectFooter()
                self.addDatas(namecard)
            } else {
                self.addDatas(namecard)
            }
            
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    func addDatas(_ model:UserInfoModel) {
        datas.removeAll()
        if !model.tel_cell.isEmpty {
            let mobile = NameCardModel(img: R.image.iphoneGen1CircleFill(), value: model.tel_cell, type: .Mobile)
            datas.append(mobile)
        }
        
        if !model.tel_work.isEmpty {
            let officeNumber = NameCardModel(img: R.image.phoneCircleFill(), value: model.tel_work, type: .OfficeNumber)
            datas.append(officeNumber)
        }
        
        if !model.email.isEmpty {
            let email = NameCardModel(img: R.image.envelopeCircleFill(), value: model.email, type: .Email)
            datas.append(email)
        }
        
        if !model.adr_work.isEmpty {
            let location = NameCardModel(img: R.image.locationCircleFill(), value: model.adr_work, type: .OfficeLocation)
            datas.append(location)
        }
        
        if !model.url.isEmpty {
            let website = NameCardModel(img: R.image.rectangleOnRectangleCircleFill(), value: model.url, type: .Website)
            datas.append(website)
        }
        self.namecardView.model = model
        self.tableView?.reloadData()
    }
    
    override func createListView() {
        super.createListView()
        self.tableView?.register(cellWithClass: UITableViewCell.self)
        self.tableView?.tableHeaderView = namecardView
        namecardView.size = CGSize(width: kScreenWidth, height: 308)
        namecardView.dataUpdateComplete = {  [weak self] height in
            self?.namecardView.size = CGSize(width: kScreenWidth, height: height)
            self?.tableView?.tableHeaderView = self?.namecardView
        }
        
        self.tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight, right: 0)
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        if datas.count > 0 {
            let  model = datas[indexPath.row]
            cell.imageView?.image = model.img
            cell.textLabel?.text = model.value
            
            cell.textLabel?.font = UIFont.sk.pingFangRegular(15)
            cell.textLabel?.textColor = R.color.textColor22()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.id == nil { return }
        Haptico.selection()
        let data = datas[indexPath.row]
        switch data.type {
        case .Mobile:
            let alert = UIAlertController(style: .actionSheet)
            alert.addAction(UIAlertAction(title: "Send Text Message", style: .default,handler: { _ in
                if MFMessageComposeViewController.canSendText() {
                    let vc = MFMessageComposeViewController()
                    vc.recipients = [data.value]
                    //设置代理
                    vc.messageComposeDelegate = self
                    self.present(vc, animated: true)
                } else {
                    print("本设备不能发短信")
                }
            }))
            alert.addAction(UIAlertAction(title: "Call", style: .default, handler:{ _ in
                let phone = "telprompt://" + data.value
                if let url = phone.url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        case .OfficeNumber:
            let phone = "telprompt://" + data.value
            if let url = phone.url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        case .Email:
            if MFMailComposeViewController.canSendMail() {  //  是否可以发邮件 //  如果不能,去系统设置接收邮箱
                let vc = MFMailComposeViewController()
                vc.mailComposeDelegate = self
                vc.setToRecipients([data.value])//  接收邮件的邮箱
                vc.setSubject("")
                vc.setMessageBody("", isHTML: false)
                self.present(vc, animated: true)
            } else if let emailUrl = createEmailUrl(to: data.value, subject: "", body: "") {
                UIApplication.shared.open(emailUrl)
            }
        case .OfficeLocation:
            let vc = MapViewController(location: data.value)
            self.navigationController?.pushViewController(vc)
        case .Website:
            if data.value.isValidHttpUrl || data.value.isValidHttpsUrl {
                if let url = URL(string: data.value) {
                    let vc = SFSafariViewController(url: url)
                    vc.delegate = self
                    self.present(vc, animated: true)
                }
            } else {
                if let url = URL(string: "http://" + data.value) {
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true)
                }
            }
        default:
            print(data.type)
        }
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        controller.dismiss(animated: true)
        
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
    
    //MFMessageComposeViewControllerDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
        //判断短信的状态
        switch result{
            
        case .sent:
            Toast.showSuccess("Message has been sent")
        case .cancelled:
            print("短信取消发送")
        case .failed:
            print("短信发送失败")
            Toast.showError("Message sending failed")
        default:
            print("短信没发送")
            break
        }
    }
    
    func addConnectFooter(){
        let connectButton = LoadingButton()
        let saveToContactButton = UIButton()
        
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(connectButton)
        connectButton.isSkeletonable = true
        connectButton.isHiddenWhenSkeletonIsActive = true
        connectButton.snp.makeConstraints { make in
            make.width.equalTo(kScreenWidth - 64)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalToSuperview().offset(16)
        }
        connectButton.titleForNormal = "Connect"
        connectButton.titleColorForNormal = .white
        connectButton.backgroundColor = R.color.theamColor()
        connectButton.cornerRadius = 8
        connectButton.titleLabel?.font = UIFont.sk.pingFangSemibold(16)
        connectButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            connectButton.startAnimation()
            NetworkService.addFriend(userId: self.id ?? 0).subscribe(onNext:{
                connectButton.stopAnimation()
                if $0.success == 1 {
                    self.dismiss(animated: true)
                } else {
                    Toast.showError($0.message)
                }
                
            },onError: { e in
                connectButton.stopAnimation()
                Toast.showError(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
        view.addSubview(saveToContactButton)
        saveToContactButton.titleForNormal = "Save to contact"
        saveToContactButton.titleColorForNormal = R.color.textColor22()
        saveToContactButton.titleLabel?.font = UIFont.sk.pingFangSemibold(16)
        saveToContactButton.snp.makeConstraints { make in
            make.top.equalTo(connectButton.snp.bottom).offset(16)
            make.height.equalTo(36)
            make.centerX.equalToSuperview()
        }
        
        self.tableView?.tableFooterView = view
        view.size = CGSize(width: kScreenWidth, height: 128)
    }
    
    func addWriteToNFCTagFooter(){
        let writeToNFCTagButton = UIButton()
        let noNFCTagButton = UIButton()
        
        
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(writeToNFCTagButton)
        
        
        writeToNFCTagButton.isSkeletonable = true
        writeToNFCTagButton.isHiddenWhenSkeletonIsActive = true
        writeToNFCTagButton.snp.makeConstraints { make in
            make.width.equalTo(kScreenWidth - 64)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalToSuperview().offset(16)
        }
        writeToNFCTagButton.titleForNormal = "Write To NFC Tag"
        writeToNFCTagButton.titleColorForNormal = .white
        writeToNFCTagButton.backgroundColor = R.color.theamColor()
        writeToNFCTagButton.cornerRadius = 8
        writeToNFCTagButton.titleLabel?.font = UIFont.sk.pingFangSemibold(16)
        writeToNFCTagButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.write()
        }).disposed(by: rx.disposeBag)
        
        view.addSubview(noNFCTagButton)
        noNFCTagButton.isSkeletonable = true
        noNFCTagButton.isHiddenWhenSkeletonIsActive = true
        noNFCTagButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.top.equalTo(writeToNFCTagButton.snp.bottom).offset(16)
        }
        noNFCTagButton.titleForNormal = " No NFC Tag"
        noNFCTagButton.titleColorForNormal = R.color.iconColor()
        noNFCTagButton.titleLabel?.font = UIFont.sk.pingFangSemibold(12)
        noNFCTagButton.imageForNormal = R.image.questionmarkCircleFill()
        noNFCTagButton.sk.setImageTitleLayout(.imgRight,spacing: 4)
        noNFCTagButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Toast.showMessage("Some message")
        }).disposed(by: rx.disposeBag)
        
        self.tableView?.tableFooterView = view
        view.size = CGSize(width: kScreenWidth, height: 112)
    }
    
    // iOS 13 NFC Writer: write data to record
    func write(){
        readerWriter.newWriterSession(with: self, isLegacy: true, invalidateAfterFirstRead: true, alertMessage: "Nearby NFC card for write")
        readerWriter.begin()
        self.readerWriter.detectedMessage = "Write data success"
    }
    
    // iOS 13 NFC Tag Reader: Tag Info and NFCNDEFMessage
    func read(){
        readerWriter.newWriterSession(with: self, isLegacy: false, invalidateAfterFirstRead: true, alertMessage: "Nearby NFC card for read tag identifier")
        readerWriter.begin()
        //readerWriter.detectedMessage = "detected Tag info"
    }
    
    func contentsForMessages(_ messages: [NFCNDEFMessage]) -> String {
        var recordInfos = ""
        
        for message in messages {
            for (i, record) in message.records.enumerated() {
                recordInfos += "Record(\(i + 1)):\n"
                recordInfos += "Type name format: \(record.typeNameFormat.rawValue)\n"
                recordInfos += "Type: \(record.type as NSData)\n"
                recordInfos += "Identifier: \(record.identifier)\n"
                recordInfos += "Length: \(message.length)\n"
                
                if let string = String(data: record.payload, encoding: .ascii) {
                    recordInfos += "Payload content:\(string)\n"
                }
                recordInfos += "Payload raw data: \(record.payload as NSData)\n\n"
            }
        }
        
        return recordInfos
    }
    
    
    func getTagInfos(_ tag: __NFCTag) -> [String: Any] {
        var infos: [String: Any] = [:]
        
        switch tag.type {
        case .miFare:
            if let miFareTag = tag.asNFCMiFareTag() {
                switch miFareTag.mifareFamily {
                case .desfire:
                    infos["TagType"] = "MiFare DESFire"
                case .ultralight:
                    infos["TagType"] = "MiFare Ultralight"
                case .plus:
                    infos["TagType"] = "MiFare Plus"
                case .unknown:
                    infos["TagType"] = "MiFare compatible ISO14443 Type A"
                @unknown default:
                    infos["TagType"] = "MiFare unknown"
                }
                if let bytes = miFareTag.historicalBytes {
                    infos["HistoricalBytes"] = bytes.hexadecimal
                }
                infos["Identifier"] = miFareTag.identifier.hexadecimal
            }
        case .iso7816Compatible:
            if let compatibleTag = tag.asNFCISO7816Tag() {
                infos["TagType"] = "ISO7816"
                infos["InitialSelectedAID"] = compatibleTag.initialSelectedAID
                infos["Identifier"] = compatibleTag.identifier.hexadecimal
                if let bytes = compatibleTag.historicalBytes {
                    infos["HistoricalBytes"] = bytes.hexadecimal
                }
                if let data = compatibleTag.applicationData {
                    infos["ApplicationData"] = data.hexadecimal
                }
                infos["OroprietaryApplicationDataCoding"] = compatibleTag.proprietaryApplicationDataCoding
            }
        case .ISO15693:
            if let iso15693Tag = tag.asNFCISO15693Tag() {
                infos["TagType"] = "ISO15693"
                infos["Identifier"] = iso15693Tag.identifier
                infos["ICSerialNumber"] = iso15693Tag.icSerialNumber.hexadecimal
                infos["ICManufacturerCode"] = iso15693Tag.icManufacturerCode
            }
            
        case .feliCa:
            if let feliCaTag = tag.asNFCFeliCaTag() {
                infos["TagType"] = "FeliCa"
                infos["Identifier"] = feliCaTag.currentIDm
                infos["SystemCode"] = feliCaTag.currentSystemCode.hexadecimal
            }
        default:
            break
        }
        return infos
    }
    
    
}

extension NFCNameCardController {
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        if case .camera = sourceType {
            _photoHelper.presentCamera(byController: UIViewController.sk.getTopVC()!)
        } else {
            _photoHelper.presentPhotoLibrary(byController: UIViewController.sk.getTopVC()!)
        }
    }
    
}
extension NFCNameCardController: NFCReaderDelegate {
    
    func reader(_ session: NFCReader, didInvalidateWithError error: Error) {
        print("ERROR:\(error)")
        readerWriter.end()
    }
    
    func readerDidBecomeActive(_ session: NFCReader) {
        print("Reader did become")
    }
    
    /// -----------------------------
    // MARK: - 1. NFC Reader(iOS 11):
    /// -----------------------------
    func reader(_ session: NFCReader, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let  recordInfos = contentsForMessages(messages)
        
        DispatchQueue.main.async {
            print(recordInfos)
        }
        readerWriter.end()
    }
    
    /// -----------------------------
    // MARK: - 2. NFC Writer(iOS 13):
    /// -----------------------------
    func reader(_ session: NFCReader, didDetect tags: [NFCNDEFTag]) {
        print("did detect tags")
        guard let user = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className) else {
            return
        }
        var payloadData = Data([0x02])
        let uri = "terrabyte.sg/wecyn/?id=\(user.id)&uuid=\(user.uuid)"
        payloadData.append(uri.data(using: .utf8)!)
        
        let payload = NFCNDEFPayload.init(
            format: NFCTypeNameFormat.nfcWellKnown,
            type: "U".data(using: .utf8)!,
            identifier: Data.init(count: 0),
            payload: payloadData,
            chunkSize: 0)
        
        let message = NFCNDEFMessage(records: [payload])
        
        readerWriter.write(message, to: tags.first!) { (error) in
            if let err = error {
                print("ERR:\(err)")
            } else {
                print("write success")
            }
            self.readerWriter.end()
        }
    }
    
    /// --------------------------------
    // MARK: - 3. NFC Tag Reader(iOS 13)
    /// --------------------------------
    func reader(_ session: NFCReader, didDetect tag: __NFCTag, didDetectNDEF message: NFCNDEFMessage) {
        let tagId = readerWriter.tagIdentifier(with: tag)
        let content = contentsForMessages([message])
        
        let tagInfos = getTagInfos(tag)
        var tagInfosDetail = ""
        tagInfos.forEach { (item) in
            tagInfosDetail = tagInfosDetail + "\(item.key): \(item.value)\n"
        }
        
        DispatchQueue.main.async {
            var text = "Read Tag Identifier:\(tagId.hexadecimal)\n"
            text.append("TagInfo:\n\(tagInfosDetail)\nNFCNDEFMessage:\n\(content)")
            print(text)
        }
        self.readerWriter.alertMessage = "NFC Tag Info detected"
        self.readerWriter.end()
    }
}

