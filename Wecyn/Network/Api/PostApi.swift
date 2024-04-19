//
//  PostApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/12.
//

import Foundation
import Moya
enum PostApi {
    case addPost(_ content:String,_ images:[String]? = nil,_ video:String? = nil, _ type:Int = 1)
    case postList(_ userId:Int? = nil,_ lastPostId:Int? = nil)
    case updatePostType(_ id:Int,_ type:Int)
    case feedList(lastPostId:Int? = nil)
    case addComment(_ id:Int,_ content:String)
    case commentList(_ id:Int,_ lastCommentId:Int? = nil)
    case addReply(_ commentId:Int,_ toUserId:Int,_ content:String)
    case setLike(_ id:Int,_ type:Int = 1)
    case cancelLike(_ id:Int,_ type:Int = 1)
    case likeShow(_ id:Int,_ lastLikeId:Int?  = nil)
    case likedList(_ userId:Int? = nil,_ lastId:Int? = nil)
    case repost(_ id:Int,_ content:String,_ type:Int = 1)
    case getUploadVideoUrl
    case test
}

extension PostApi: TargetType {
    var path: String {
        switch self{
        case .addPost:
            return "/api/post/addPost/"
        case .postList:
            return "/api/post/postList/"
        case .updatePostType:
            return "/api/post/updatePostType/"
        case .feedList:
            return "/api/post/feedList/"
        case .addComment:
            return "/api/post/addComment/"
        case .commentList:
            return "/api/post/commentListM/"
        case .addReply:
            return "/api/post/addReply/"
        case .setLike:
            return "/api/post/setLike/"
        case .cancelLike:
            return "/api/post/cancelLike/"
        case .likeShow:
            return "/api/post/likeShow/"
        case .likedList:
            return "/api/post/likedList/"
        case .repost:
            return "/api/post/repost/"
        case .getUploadVideoUrl:
            return "/api/post/getUploadVideoUrl/"
        case .test:
            return "/api/test/imNotificationTest/"
        }
    }
    var method: Moya.Method {
        switch self{
        case .addPost,.addReply,.cancelLike,.setLike,.addComment,.repost:
            return .post
        case .postList,.feedList,.commentList,.likeShow,.likedList,.getUploadVideoUrl,.test:
            return .get
        case .updatePostType:
            return .put
        }
    }
    var task: Task {
        switch self{
        case .addPost(let content,let images,let video,let type):
            return requestParametersByPost(["content":content,"images":images,"video":video,"type":type])
        case .postList(let userId,let lastId):
            return requestParametersByGet(["user_id":userId,"last_id":lastId])
        case .updatePostType(let id,let type):
            return requestParametersByPost(["id":id,"type":type])
        case .feedList(let lastId):
            return requestParametersByGet(["last_id":lastId])
        case .addComment(let id, let content):
            return requestParametersByPost(["post_id":id,"content":content])
        case .addReply(let commentId, let toUserId, let content):
            return requestParametersByPost(["comment_id":commentId,"to_user_id":toUserId,"content":content])
        case .setLike(let id,let type):
            return requestParametersByPost(["source_id":id,"type":type])
        case .cancelLike(let id,let type):
            return requestParametersByPost(["source_id":id,"type":type])
        case .likeShow(let id,let lastId):
            return requestParametersByGet(["id":id,"last_id":lastId])
        case .commentList(let id,let lastId):
            return requestParametersByGet(["id":id,"last_id":lastId])
        case .likedList(let userId,let lastId):
            return requestParametersByGet(["user_id":userId,"last_id":lastId])
        case .repost(let id,let content,let type):
            return requestParametersByPost(["id":id,"content":content,"type":type])
        case .getUploadVideoUrl:
            return .requestPlain
        case .test:
            return requestParametersByGet(["is_online_only":1,"not_offline_push":1])
        }
    }
}
