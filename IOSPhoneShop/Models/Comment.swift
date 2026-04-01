/* Comment.swift */
import Foundation

struct CommentsCreateRequest: Codable {
    let phoneId: Int
    let content: String
}

struct CommentResponse: Codable, Identifiable {
    var id: Int { commentId }
    
    let commentId: Int
    let userId: Int
    let userName: String
    let content: String
}

struct CommentUpdateRequest : Codable {
    let content: String
}
