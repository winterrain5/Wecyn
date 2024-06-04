//
//  PostService.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/12.
//

import Foundation

class PostService {
    
    /// 发布post
    /// - Returns: PostAddedModel
    static func addPost(model: AddPostRequestModel) -> Observable<PostListModel>{
        let target = MultiTarget(PostApi.addPost(model))
        return APIProvider.rx.request(target).asObservable().mapObject(PostListModel.self)
    }
    
    static func postList(userId:Int? = nil,lastId:Int = 0) -> Observable<[PostListModel]> {
        let target = MultiTarget(PostApi.postList(userId,lastId))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(PostListModel.self)
    }
    
    static func postInfo(id:Int) -> Observable<PostListModel> {
        let target = MultiTarget(PostApi.postInfo(id))
        return APIProvider.rx.request(target).asObservable().mapObject()
    }
    
    static func postFeedList(lastId:Int? = nil) -> Observable<[PostListModel]> {
        let target = MultiTarget(PostApi.feedList(lastPostId: lastId))
        return APIProvider.rx.request(target).asObservable().mapObjectArray()
    }
    
    
    /// 更新post状态
    /// - Parameters:
    ///   - id: post id
    ///   - type: 1 公开  2 仅好友可见 3 仅自己可见 0 删除
    /// - Returns: ResponseStatus
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
        return APIProvider.rx.request(target).asObservable().mapObjectArray(PostCommentModel.self)
    }
    
    static func addReply(commentId:Int,content:String,toUserId:Int = 0) -> Observable<PostCommentReplyModel> {
        let target = MultiTarget(PostApi.addReply(commentId, toUserId, content))
        return APIProvider.rx.request(target).asObservable().mapObject(PostCommentReplyModel.self)
    }
    
    static func likedList(userId:Int = 0,lastId:Int? = nil) -> Observable<[PostListModel]> {
        let target = MultiTarget(PostApi.likedList(lastId))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(PostListModel.self)
    }
    
    static func repost(id:Int,content:String,type:Int = 1) -> Observable<PostListModel> {
        let target = MultiTarget(PostApi.repost(id, content,type))
        return APIProvider.rx.request(target).asObservable().mapObject(PostListModel.self)
    }
    
    static func getUploadVideoUrl() -> Observable<UploadVideoResponse> {
        let target = MultiTarget(PostApi.getUploadVideoUrl)
        return APIProvider.rx.request(target).asObservable().mapObject(UploadVideoResponse.self)
    }
    static func testNotification() -> Observable<ResponseStatus> {
        let target = MultiTarget(PostApi.test)
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    // 2 未关注（Post仅粉丝可见，但查看者未关注），3 不可查看（Post仅自己可见），4 Post已删除
    static func getPostVisibleStatus(id:Int) -> Observable<Int>  {
        let target = MultiTarget(PostApi.getPostVisibleStatus(id))
        return APIProvider.rx.request(target).asObservable().mapDataValue()
    }
}

class UploadVideoResponse:BaseModel {
    var url = ""
    var video = ""
    var outputURL:URL!
}

class PostUser :BaseModel,Codable {
    var avatar: String = ""
    var id: Int = 0
    var last_name: String = ""
    var first_name: String = ""
    var headline: String = ""
    var is_following:Bool = false
    var full_name:String {
        return String.fullName(first: first_name, last: last_name)
    }
}

class PostImageObject: BaseModel {
    
    var url:String = ""
    var img_w:CGFloat = 0
    var img_h:CGFloat = 0
    
    var heightForOneImage:CGFloat {
        var imgH = (kScreenWidth - 32) * (img_h / img_w)
        imgH = imgH >= kScreenHeight * 0.6 ? kScreenHeight * 0.6 : imgH
        return imgH
    }
    var widhtForMoreThanOneImage:CGFloat {
        return 160 * (img_w / img_h)
    }
    
    override func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.img_w <-- "width"
        mapper <<<
            self.img_h <-- "height"
    }
    
}

class PostListModel :BaseModel {
    var images: [String] = []
    var images_obj:[PostImageObject] = []
    var content: String = ""
    var formatedContent: String {
        var result = content
        
        at_list.forEach({ user in
            let name = user.name.replacingOccurrences(of: " ", with: "")
            result = result.replacingOccurrences(of: "[@\(user.id)]", with: " @\(name) ")
        })
        result = result.replacingOccurrences(of: "  ", with: " ")
        return result
    }
    var at_list:[PostAtList] = []
    var like_count: Int = 0
    var id: Int = 0
    var comment_count: Int = 0
    var create_time: String = ""
    var type: Int = 0
    var repost_count: Int = 0
    var user: PostUser = PostUser()
    var video: String = ""
    var video_thumbnail_image: UIImage? 
    var video_thumbnail_image_size: CGSize {
        var size:CGSize = CGSize(width: kScreenWidth - 32, height: (kScreenWidth - 32) * 3 / 4)
//        guard let image = video_thumbnail_image else {
//            return .zero
//        }
//        if image.size.width < (kScreenWidth - 32) {
//            size = video_thumbnail_image?.size ?? .zero
//        } else {
//            size = video_thumbnail_image?.scaled(toWidth: kScreenWidth - 32)?.size ?? .zero
//        }
        return size
    }
    var is_own_post:Bool {
        let userid = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.id.int ?? 0
        return userid ==  user.id
    }
    var liked:Bool = false
    var contentH:CGFloat {
        let height = formatedContent.heightWithConstrainedWidth(width: kScreenWidth - 32, font: UIFont.sk.pingFangRegular(15))
        return height < 18 ? 18 : height
    }
    var sourceDataContentH:CGFloat {
        let height = source_data?.formatedContent.heightWithConstrainedWidth(width: kScreenWidth - 64, font: UIFont.sk.pingFangRegular(12)) ?? 0
        return (height < 16 ? 16 : height) + 44
    }
    var imgH:CGFloat {
        var imgH:CGFloat = 0
        if video.isEmpty {
            if images_obj.count == 0 {
                imgH = 0
            }
            if images_obj.count == 1 {
                imgH = images_obj.first?.heightForOneImage ?? 0
                
            }
            if images_obj.count > 1 {
                imgH = 160
            }
        } else {
            imgH = video_thumbnail_image_size.height
        }
        
        return imgH
    }
    var cellHeight:CGFloat {
        let topH = 60.cgFloat
        let bottomH = 30.cgFloat
        var space:CGFloat = 0
        var sourceH:CGFloat = 0
        if source_data != nil {
            sourceH = sourceDataContentH
            space += 8
        }
        if images_obj.count > 0 || !video.isEmpty{
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
class PostAtList: BaseModel {
    var id:Int = 0
    var name:String = ""
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
    guard let createTime = create_time.toDate(format: "dd-MM-yyyy HH:mm:ss") else {
        return ""
    }
    let now = Date()
    let duration = createTime.distance(to: now).int
    let day = duration / (60 * 60 * 24);
    let hour = (duration % ( 60 * 60 * 24)) / (60 * 60)
    let minitue = (duration % (60 * 60)) / (60)
    
    if day > 7 {
        let dateStr = createTime.toString(format: "dd-MM-yyyy HH:mm")
        return dateStr
    }
    if day > 0 && day < 7 {
        let dayUnit = day > 1 ? "days" : "day"
        return "· \(day) \(dayUnit) ago"
    }
    
    if hour > 0 {
        let hourUnit = hour > 1 ? "hours" : "hour"
        return  "· \(hour) \(hourUnit) ago"
    }
    if minitue > 0 {
        let minUnit = minitue > 1 ? "mins" : "min"
        return  "· \(minitue) \(minUnit) ago"
    }
    return "· just now"
}
