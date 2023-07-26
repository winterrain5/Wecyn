//
//  NFCController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/24.
//

import UIKit
import CoreNFC
import NFCReaderWriter
class NFCController: BaseViewController {
    let readerWriter = NFCReaderWriter.sharedInstance()
    let textLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let writeButton = UIButton()
        writeButton.titleColorForNormal = .blue
        writeButton.titleForNormal = "write"
        writeButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.write()
        }).disposed(by: rx.disposeBag)
        self.view.addSubview(writeButton)
        writeButton.frame = CGRect(x: 0, y: 100, width: 40, height: 30)
        writeButton.center.x = self.view.center.x
        
        let readButton = UIButton()
        readButton.titleColorForNormal = .blue
        readButton.titleForNormal = "read"
        readButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.read()
        }).disposed(by: rx.disposeBag)
        self.view.addSubview(readButton)
        readButton.frame = CGRect(x: 0, y: 200, width: 40, height: 30)
        readButton.center.x = self.view.center.x
        
        self.view.addSubview(textLabel)
        textLabel.textColor = .blue
        textLabel.numberOfLines = 0
        textLabel.frame = CGRect(x: 16, y: 300, width: kScreenWidth - 32, height: 0)
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
extension NFCController: NFCReaderDelegate {
    
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
            self.textLabel.text = text
            self.textLabel.sizeToFit()
        }
        self.readerWriter.alertMessage = "NFC Tag Info detected"
        self.readerWriter.end()
    }
}

extension Data {
    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}

