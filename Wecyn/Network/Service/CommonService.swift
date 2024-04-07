//
//  CommonService.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/29.
//

import Foundation
import RxSwift
enum UploadContentType:String {
    case Image = "image/png"
    case video = "video/mp4"
    case audio = "audio/mp3"
    
    var ext:String {
        switch self {
        case .Image:
            return "jpeg"
        case .video:
            return "mp4"
        case .audio:
            return "mp3"
        }
    }
}
class CommonService:NSObject {
    
    static let share = CommonService()
    static func getUploadFileUrl(_ ext:String,_ contentType:UploadContentType) -> Observable<UploadMediaModel> {
        let target = MultiTarget(CommonApi.getUploadFileUrl(ext,contentType.rawValue))
        return APIProvider.rx.request(target).asObservable().mapObject()
    }
    
    func uploadMedia(_ uploadUrl:String,_ data:Data,_ contentType:UploadContentType,complete:@escaping (String)->(),failure:@escaping (Error)->()){
        
        let url = URL(string:uploadUrl)
        var request = URLRequest(url: url!, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod =  "PUT"
        request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
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
