//
//  CommentService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 15/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class CommentService {
    
    // MARK: Properties
    static var shared = CommentService()
    
    // MARK: Constructor
    private init() {}
    
    // MARK: Methods
    func listener(to postID: String, onGetNewComment: @escaping (Comment)->Void) {
        let postCommentsPath = String(format: "post-comments/%@", postID)
        ServiceManager.database.listenToKey(toPath: postCommentsPath) { (commentID: String) in
            let commentPath = String(format: "comments/%@", commentID)
            ServiceManager.database.getValue(path: commentPath, completion: { (data: Dictionary<String, Any>?) in
                guard let dicComment = data else { return }
                guard let newComment = Comment.transform(from: dicComment) else { return }
                onGetNewComment(newComment)
            })
        }
    }
    
    func postComment(on postID: String, comment: String, onSuccess:(()->(Void))?, onError:((Error)->(Void))?) {
        guard let userID = ServiceManager.auth.getUserID() else { return }
        guard let commentID = ServiceManager.database.getUniqueId(forPath: "comments") else { return }
        ServiceManager.database.setValue(path: "comments", dataID: commentID, data: ["userID": userID, "comment": comment]) { (error: Error?) in
            if error != nil { onError?(error!); return }
            ServiceManager.database.setValue(path: "post-comments/" + postID, dataID: commentID, data: "true", completion: { (error: Error?) in
                if error != nil { onError?(error!); return }
                onSuccess?()
            })
        }
    }
}
