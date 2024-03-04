//
//  NotificationService.swift
//  Wecyn
//
//  Created by Derrick on 2024/2/27.
//

import Foundation
import RxSwift
class NotificationService {
    static func getNotificationList(type:Int = 0,lastId:Int?) -> Observable<[NotificationModel]> {
        let target = MultiTarget(NotificatonApi.NotificationList(type,lastId))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(NotificationModel.self)
    }
    static func getNotificationCount() -> Observable<Int> {
        let target = MultiTarget(NotificatonApi.NotificationCount)
        return APIProvider.rx.request(target).asObservable().mapDictionary("sys", Int.self)
    }
}


class NotificationModel:BaseModel {
    var status: Int = 0
    var content: String = ""
    var is_unread: Int = 0
    var id: Int = 0
    var extra: NotificationExtraModel?
    var title: String = ""
    var create_time: String = ""
    var type: Int = 0
}


class NotificationExtraModel :NSObject {
       var id: Int = 0
       var type: Int = 0

}

