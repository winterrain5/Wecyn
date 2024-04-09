//
//  CommonService.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/29.
//

import Foundation
import RxSwift
enum UploadContentType {
    case Image
    case video
    case audio
    case file(ext:String)
    
    var ext:String {
        switch self {
        case .Image:
            return "jpeg"
        case .video:
            return "mp4"
        case .audio:
            return "mp3"
        case .file(let ext):
            return ext
        }
    }
    
    var contentType:String {
        switch self {
        case .Image:
            return "image/png"
        case .video:
            return "video/mp4"
        case .audio:
            return "audio/mp3"
        case .file(let ext):
            switch ext {
            case "vcf":
                return "text/x-vcard"
            case "json":
                return "application/json"
            case "pdf":
                return "application/pdf"
            case "doc":
                return "application/msword"
            case "ppt":
                return "application/x-ppt"
            case "xls":
                return "application/x-xls"
            case "png":
                return "image/png"
            case "mp4":
                return "video/mp4"
            case "mp3":
                return "audio/mp3"
            case "txt":
                return "text/plain"
            default:
                return "text/plain"
            }
        }
    }
    /*
     application/json： JSON数据格式
     application/pdf：pdf格式
     application/msword ： Word文档格式
     */
}
class CommonService:NSObject {
    
    static let share = CommonService()
    static func getUploadFileUrl(_ ext:String,_ contentType:UploadContentType) -> Observable<UploadMediaModel> {
        let target = MultiTarget(CommonApi.getUploadFileUrl(ext,contentType.contentType))
        return APIProvider.rx.request(target).asObservable().mapObject()
    }
    
    func uploadMedia(_ uploadUrl:String,_ data:Data,_ contentType:UploadContentType,complete:@escaping (String)->(),failure:@escaping (Error)->()){
        
        let url = URL(string:uploadUrl)
        var request = URLRequest(url: url!, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod =  "PUT"
        request.addValue(contentType.contentType, forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        
        session.uploadTask(with: request, from: data) { data, response, error in
            //上传完毕后
            if error == nil,let data = data {
                let result = String.init(data: data, encoding: .utf8) ?? ""
                if result.isEmpty {
                    complete(result)
                } else {
                    failure(APIError.requestError(code: -1, message: "upload file failed"))
                }
                print("result:\(result)")
                
            } else {
                failure(APIError.requestError(code: -1, message: error?.localizedDescription ?? ""))
            }
        }.resume()
        
    }
    
    
}

extension CommonService: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("bytesSent:\(bytesSent),totalBytesSent:\(totalBytesSent),totalBytesExpectedToSend:\(totalBytesExpectedToSend)")
    }
}

class UploadMediaModel: BaseModel {
    var upUrl:String = ""
    var downUrl:String = ""
}
