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
    
    
    /// 点赞
    /// - Parameters:
    ///   - sourceId: 当type=1时，source_id传post_id，当type=2时，source_id传commtent_id，当type=3时，source_id传reply_id。type默认是1
    ///   - type: 1 2 3
    /// - Returns: ResponseStatus
    static func setLike(sourceId:Int,type:Int = 1) -> Observable<ResponseStatus> {
        let target = MultiTarget(PostApi.setLike(sourceId,type))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 取消点赞
    /// - Parameters:
    ///   - sourceId: 当type=1时，source_id传post_id，当type=2时，source_id传commtent_id，当type=3时，source_id传reply_id。type默认是1
    ///   - type: 1 2 3
    /// - Returns: ResponseStatus
    static func cancelLike(sourceId:Int,type:Int = 1) -> Observable<ResponseStatus> {
        let target = MultiTarget(PostApi.cancelLike(sourceId,type))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    static func addComment(postId:Int,content:String) -> Observable<PostCommentModel> {
        let target = MultiTarget(PostApi.addComment(postId, content))
        return APIProvider.rx.request(target).asObservable().mapObject(PostCommentModel.self)
    }
    
    static func commentList(postId:Int,lastCommentId:Int? = nil) -> Observable<[PostCommentModel]> {
        let target = MultiTarget(PostApi.commentList(postId,lastCommentId))
        return APIProvider.rx.request(target).asObservable().mapArray(PostCommentModel.self)
    }
    
    static func addReply(commentId:Int,content:String,toUserId:Int = 0) -> Observable<PostCommentReplyModel> {
        let target = MultiTarget(PostApi.addReply(commentId, toUserId, content))
        return APIProvider.rx.request(target).asObservable().mapObject(PostCommentReplyModel.self)
    }
    
    static func likedList(userId:Int = 0,lastId:Int? = nil) -> Observable<[PostListModel]> {
        let target = MultiTarget(PostApi.likedList(lastId))
        return APIProvider.rx.request(target).asObservable().mapArray(PostListModel.self)
    }
    
    static func repost(id:Int,content:String,type:Int = 1) -> Observable<PostListModel> {
        let target = MultiTarget(PostApi.repost(id, content,type))
        return APIProvider.rx.request(target).asObservable().mapObject(PostListModel.self)
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
        var imgH = (kScreenWidth - 32) * (height / width)
        imgH = imgH >= kScreenHeight * 0.6 ? kScreenHeight * 0.6 : imgH
        return imgH
    }
    var widhtForMoreThanOneImage:CGFloat {
        return 160 * (width / height)
    }
}
class PostListModel :BaseModel {
    var images: [String] = []
    var images_obj:[PostImageObject] = []
    var content: String = ""
    var like_count: Int = 0
    var id: Int = 0
    var comment_count: Int = 0
    var create_time: String = ""
    var type: Int = 0
    var repost_count: Int = 0
    var user: PostUser = PostUser()
    var is_own_post:Bool {
        let userid = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.id.int ?? 0
        return userid ==  user.id
    }
    var liked:Bool = false
    var contentH:CGFloat {
        let height = content.heightWithConstrainedWidth(width: kScreenWidth - 32, font: UIFont.sk.pingFangRegular(15))
        return height < 18 ? 18 : height
    }
    var sourceDataH:CGFloat {
        let height = source_data?.content.heightWithConstrainedWidth(width: kScreenWidth - 32, font: UIFont.sk.pingFangRegular(12)) ?? 0
        return (height < 16 ? 16 : height) + 44
    }
    var imgH:CGFloat {
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
        return imgH
    }
    var cellHeight:CGFloat {
        let topH = 60.cgFloat
        let bottomH = 30.cgFloat
        var space:CGFloat = 0
        var sourceH:CGFloat = 0
        if source_data != nil {
            sourceH = sourceDataH
            space += 8
        }
        if images_obj.count > 0 {
            space += 8
        }
        space += 24
        return contentH.ceil + topH + imgH.ceil + bottomH + space + sourceH
    }
    
    var post_time:String {
        return formateTime(create_time)
    }
    
    var source_id:Int?
    var source_data:PostListModel?
    
    var posted:Bool = false
}

class PostCommentModel :BaseModel {
    var like_count: Int = 0
    var id: Int = 0
    var content: String = ""
    var post_id: Int = 0
    var create_time: String = ""
    var user: PostUser = PostUser()
    var comment_count: Int = 0
    var repost_count: Int = 0
    var liked:Bool = false
    var reply_list:[PostCommentReplyModel] = []
    var post_time:String {
        return formateTime(create_time)
    }
    var cellHeight:CGFloat {
        let contentH = content.heightWithConstrainedWidth(width: kScreenWidth - 56, font: UIFont.systemFont(ofSize: 14, weight: .regular))
        return 72 + contentH
    }
}

class PostCommentReplyModel:BaseModel {
    var like_count: Int = 0
    var id: Int = 0
    var content: String = ""
    var comment_id: Int = 0
    var create_time: String = ""
    var to_user: PostUser = PostUser()
    var user: PostUser = PostUser()
    var liked:Bool = false
    var post_time:String {
       
        return formateTime(create_time)
    }
}

func formateTime(_ create_time:String) -> String {
    let createTime = create_time.date(format: "dd-MM-yyyy HH:mm:ss")
    let now = Date()
    let duration = (createTime?.distance(to: now) ?? 0).int
    let day = duration / (60 * 60 * 24);
    let hour = (duration % ( 60 * 60 * 24)) / (60 * 60)
    let minitue = (duration % (60 * 60)) / (60)
    
//    if day > 365 {
//        let year = day / 365
//        let yearUnit = year > 1 ? "years" : "year"
//        return  "\(year) \(yearUnit)"
//    }
//    if day > 30 {
//        let month = day / 30
//        let monthkUnit = month > 1 ? "months" : "month"
//        return  "\(month) \(monthkUnit)"
//    }
//    if day > 7 {
//        let week = day / 7
//        let weekUnit = week > 1 ? "weeks" : "week"
//        return  "\(week) \(weekUnit)"
//    }
    if day > 7 {
        let dateStr = createTime?.toString(format: "dd-MM-yyyy")
        return dateStr ?? ""
    }
    if day > 0 && day < 7 {
        let dayUnit = day > 1 ? "days" : "day"
        return "Posted \(day) \(dayUnit) ago"
    }
    
    if hour > 0 {
        let hourUnit = hour > 1 ? "hours" : "hour"
        return  "Posted \(hour) \(hourUnit) ago"
    }
    if minitue > 0 {
        let minUnit = minitue > 1 ? "mins" : "min"
        return  "Posted \(minitue) \(minUnit) ago"
    }
    return "Posted just now"
}
