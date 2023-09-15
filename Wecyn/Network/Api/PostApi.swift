//
//  PostApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/12.
//

import Foundation
import Moya
enum PostApi {
    case addPost(_ content:String,_ images:[String]? = nil, _ type:Int = 1)
    case postList(_ userId:Int? = nil,_ lastPostId:Int? = nil)
    case updatePostType(_ id:Int,_ type:Int)
    case feedList(lastPostId:Int? = nil)
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
        }
    }
    var method: Moya.Method {
        switch self{
        case .addPost:
            return .post
        case .postList,.feedList:
            return .get
        case .updatePostType:
            return .put
        }
    }
    var task: Task {
        switch self{
        case .addPost(let content,let images,let type):
            return requestParametersByPost(["content":content,"images":images,"type":type])
        case .postList(let userId,let lastId):
            return requestParametersByGet(["user_id":userId,"last_id":lastId])
        case .updatePostType(let id,let type):
            return requestParametersByPost(["id":id,"type":type])
        case .feedList(let lastId):
            return requestParametersByGet(["last_id":lastId])
        }
    }
}
