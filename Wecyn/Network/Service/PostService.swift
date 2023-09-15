//
//  PostService.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/12.
//

import Foundation

class PostService {
    
    /// 发布post
    /// - Parameters:
    ///   - content: 文字内容
    ///   - images: 图片base64数组
    ///   - type: 类型 1 公开  2 仅好友可见 3 仅自己可见
    /// - Returns: PostAddedModel
    static func addPost(content:String,images:[String] = [],type:Int = 1) -> Observable<PostListModel>{
        let target = MultiTarget(PostApi.addPost(content,images,type))
        return APIProvider.rx.request(target).asObservable().mapObject(PostListModel.self)
    }
    
    static func postList(userId:Int? = nil,lastId:Int = 0) -> Observable<[PostListModel]> {
        let target = MultiTarget(PostApi.postList(userId,lastId))
        return APIProvider.rx.request(target).asObservable().mapArray(PostListModel.self)
    }
    
    static func postFeedList(lastId:Int? = nil) -> Observable<[PostListModel]> {
        let target = MultiTarget(PostApi.feedList(lastPostId: lastId))
        return APIProvider.rx.request(target).asObservable().mapArray(PostListModel.self)
    }

    
    static func updatePostType(id:Int,type:Int) -> Observable<ResponseStatus> {
        let target = MultiTarget(PostApi.updatePostType(id, type))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
}

class PostUser :BaseModel {
    var avatar: String = ""
    var id: Int = 0
    var last_name: String = ""
    var first_name: String = ""
    var headline: String = ""
    
    var full_name:String {
        return String.fullName(first: first_name, last: last_name)
    }
}

class PostImageObject: BaseModel {
    var url:String = ""
    var width:CGFloat = 0
    var height:CGFloat = 0
  
    var heightForOneImage:CGFloat {
        return (kScreenWidth - 32) * (height / width)
    }
    var widhtForMoreThanOneImage:CGFloat {
        return 160 * (width / height)
    }
}
class PostListModel :BaseModel {
    var images: [String] = []
    var images_obj:[PostImageObject] {
        images.map({
            let obj = PostImageObject()
            obj.url = $0
            obj.width = 3
            obj.height = 4
            return obj
        })
    }
    var content: String = ""
    var like_count: Int = 0
    var id: Int = 0
    var comment_count: Int = 0
    var create_time: String = ""
    var type: Int = 0
    var repost_count: Int = 0
    var user: PostUser = PostUser()
    var is_need_follow:Bool = true
   
    var cellHeight:CGFloat {
        let contentH:CGFloat = content.heightWithConstrainedWidth(width: kScreenWidth - 32, font: UIFont.sk.pingFangRegular(15))
        let topH = 60.cgFloat
        var imgH:CGFloat = 0
        if images_obj.count == 0 {
            imgH = 0
        }
        if images_obj.count == 1 {
            imgH = images_obj.first?.heightForOneImage ?? 0
        }
        if images_obj.count > 1 {
            imgH = 160
        }
        let bottomH = 30.cgFloat
        let space = 40.cgFloat
        return contentH + topH + imgH + bottomH + space
    }
    
    var post_time:String {
        let createTime = create_time.date(format: "dd-MM-yyyy HH:mm:ss")
        let now = Date()
        let duration = createTime?.distance(to: now) ?? 0
        return formateTime(Int(duration))
    }
    
    func formateTime(_ duration:Int) -> String {
        let day = duration / (60 * 60 * 24);
        let hour = (duration % (60 * 60 * 24)) / (60 * 60)
        let minitue = (duration % (60 * 60)) / (60)
        
        if day > 365 {
            let year = day / 365
            let yearUnit = year > 1 ? "years" : "year"
            return  "\(year) \(yearUnit)"
        }
        if day > 30 {
            let month = day / 30
            let monthkUnit = month > 1 ? "months" : "month"
            return  "\(month) \(monthkUnit)"
        }
        if day > 7 {
            let week = day / 7
            let weekUnit = week > 1 ? "weeks" : "week"
            return  "\(week) \(weekUnit)"
        }
        if day > 0 && day < 7 {
            let dayUnit = day > 1 ? "days" : "day"
            return "\(day) \(dayUnit) "
        }
        
        if hour > 0 {
            let hourUnit = hour > 1 ? "hours" : "hour"
            return  "\(hour) \(hourUnit) "
        }
        if minitue > 0 {
            let minUnit = minitue > 1 ? "mins" : "min"
            return  "\(minitue) \(minUnit)"
        }
        return "just now"
    }
    
}
