//
//  NFCNameCardController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/26.
//

import UIKit
import NFCReaderWriter

class NameCardModel {
    var img:UIImage?
    var value:String
    var sel:String
    
    init(img: UIImage?, value: String, sel: String) {
        self.img = img
        self.value = value
        self.sel = sel
    }
}

class NFCNameCardController: BaseTableController {
    let readerWriter = NFCReaderWriter.sharedInstance()
    let namecardView = NFCNameCardView()

    let editButton = UIButton()
    let closeButton = UIButton()
    var datas:[NameCardModel] = []
    var id:Int? = nil
    init(id:Int? = nil){
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isSkeletonable = true
       
        self.view.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(16)
            make.width.height.equalTo(30)
        }
        editButton.rx.tap.subscribe(onNext:{ [weak self] in
            let vc = NFCNameCardEditController()
            self?.navigationController?.pushViewController(vc)
            vc.updateComplete = {
                self?.refreshData()
            }
        }).disposed(by: rx.disposeBag)
        editButton.imageForNormal = R.image.squareAndPencilCircleFill()
        
        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
            make.width.height.equalTo(30)
        }
        closeButton.imageForNormal = R.image.xmarkCircleFill()
        closeButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
        
        self.navigation.bar.isHidden = true
        
        refreshData()
    }
    
    override func refreshData() {
       
        if self.id == nil {
            
            UserService.getUserInfo().subscribe(onNext:{
                UserDefaults.sk.set(object: $0, for: UserInfoModel.className)
                self.addWriteToNFCTagFooter()
                self.addDatas($0)
            },onError: { e in
            }).disposed(by: rx.disposeBag)
            return
        }
        
        guard let id = self.id else { return }
        FriendService.friendNameCard(id:id).subscribe(onNext:{
            self.addConnectFooter()
            self.addDatas($0)
        },onError: { e in
        }).disposed(by: self.rx.disposeBag)
    }
    
    func addDatas(_ model:UserInfoModel) {
        datas.removeAll()
        if !model.mobile.isEmpty {
            let mobile = NameCardModel(img: R.image.iphoneGen1CircleFill(), value: model.mobile, sel: "mobileDidSelect")
            datas.append(mobile)
        }
        
        if !model.office_number.isEmpty {
            let officeNumber = NameCardModel(img: R.image.phoneCircleFill(), value: model.office_number, sel: "officeNumberSelect")
            datas.append(officeNumber)
        }
        
        if !model.email.isEmpty {
            let email = NameCardModel(img: R.image.envelopeCircleFill(), value: model.email, sel: "emailDidSelect")
            datas.append(email)
        }
        
        if !model.office_location.isEmpty {
            let location = NameCardModel(img: R.image.locationCircleFill(), value: model.office_location, sel: "locationDidSelect")
            datas.append(location)
        }
        
        if !model.website.isEmpty {
            let website = NameCardModel(img: R.image.rectangleOnRectangleCircleFill(), value: model.website, sel: "websiteDidSelect")
            datas.append(website)
        }
        self.namecardView.model = model
        self.tableView?.reloadData()
    }
    
    override func createListView() {
        super.createListView()
        self.tableView?.register(cellWithClass: UITableViewCell.self)
        self.tableView?.tableHeaderView = namecardView
        namecardView.size = CGSize(width: kScreenWidth, height: 268)
     
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
            cell.textLabel?.textColor = R.color.textColor162C46()
        }
        return cell
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
            FriendService.addFriend(userId: self.id ?? 0).subscribe(onNext:{
                connectButton.stopAnimation()
                if $0.success == 1 {
                    self.dismiss(animated: true)
                } else {
                    Toast.showError(withStatus: $0.message)
                }
                
            },onError: { e in
                connectButton.stopAnimation()
                Toast.showError(withStatus: e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
        view.addSubview(saveToContactButton)
        saveToContactButton.titleForNormal = "Save to contact"
        saveToContactButton.titleColorForNormal = R.color.textColor162C46()
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
        guard let uid = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.id else {
            return
        }
        var payloadData = Data([0x02])
        let uri = "terrabyte.sg/wecyn/uid/\(uid)"
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

