//
//  NFCNameCardController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/26.
//

import UIKit
import NFCReaderWriter
class NFCNameCardController: BaseViewController {
    let readerWriter = NFCReaderWriter.sharedInstance()
    let namecardView = NFCNameCardView()
    let connectButton = LoadingButton()
    let writeToNFCTagButton = UIButton()
    let saveToContactButton = UIButton()
    let editButton = UIButton()
    let closeButton = UIButton()
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
        
        self.view.addSubview(namecardView)
        namecardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(340)
        }
        
        self.view.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(16)
        }
        editButton.imageForNormal = R.image.squareAndPencilCircleFill()
        
        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
        }
        closeButton.imageForNormal = R.image.xmarkCircleFill()
        closeButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
        
        let user = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
        if let id = self.id {
            if id == user?.id {
                self.addWriteToNFCTagButton()
                self.namecardView.model = user
                return
            }
            
            self.view.showSkeleton()
            func mapUserInfoModel(_ friendInfo:FriendUserInfoModel) {
                
                self.view.hideSkeleton()
                let model = UserInfoModel()
                
                model.id = friendInfo.id
                model.avatar = friendInfo.avatar
                model.first_name = friendInfo.first_name
                model.last_name = friendInfo.last_name
                
                self.namecardView.model = model
                
                FriendService.friendList().subscribe(onNext:{
                    if !$0.contains(where: { $0.id == self.id }) {
                        self.addConnectButton()
                    }
                }).disposed(by: rx.disposeBag)
                
            }
            
            FriendService.friendUserInfo(id).subscribe(onNext:{
                self.view.hideSkeleton()
                mapUserInfoModel($0)
            },onError: { e in
                self.view.hideSkeleton()
            }).disposed(by: self.rx.disposeBag)
            
            
        } else {
            self.namecardView.model = user
            self.addWriteToNFCTagButton()
        }
       
        
        
    }
    

    func addConnectButton() {
        self.view.addSubview(connectButton)
        connectButton.isSkeletonable = true
        connectButton.isHiddenWhenSkeletonIsActive = true
        connectButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
            make.top.equalTo(namecardView.snp.bottom).offset(32)
        }
        connectButton.titleForNormal = "Connect"
        connectButton.titleColorForNormal = .white
        connectButton.backgroundColor = R.color.theamColor()
        connectButton.cornerRadius = 8
        connectButton.titleLabel?.font = UIFont.sk.pingFangSemibold(16)
        connectButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.connectButton.startAnimation()
            FriendService.addFriend(userId: self.id ?? 0).subscribe(onNext:{
                self.connectButton.stopAnimation()
                if $0.success == 1 {
                    self.dismiss(animated: true)
                } else {
                    Toast.showError(withStatus: $0.message)
                }
                
            },onError: { e in
                self.connectButton.stopAnimation()
                Toast.showError(withStatus: e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
        self.view.addSubview(saveToContactButton)
        saveToContactButton.titleForNormal = "Save to contact"
        saveToContactButton.titleColorForNormal = R.color.textColor162C46()
        saveToContactButton.titleLabel?.font = UIFont.sk.pingFangSemibold(16)
        saveToContactButton.snp.makeConstraints { make in
            make.top.equalTo(connectButton.snp.bottom).offset(20)
            make.height.equalTo(36)
            make.centerX.equalToSuperview()
        }
    }
    
    func addWriteToNFCTagButton() {
        self.view.addSubview(writeToNFCTagButton)
        writeToNFCTagButton.isSkeletonable = true
        writeToNFCTagButton.isHiddenWhenSkeletonIsActive = true
        writeToNFCTagButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
            make.top.equalTo(namecardView.snp.bottom).offset(32)
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
