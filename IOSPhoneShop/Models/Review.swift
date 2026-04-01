/* Review.swift */
import Foundation

struct Review: Identifiable, Codable {
    let id: Int
    let rating: Double
    let content: String
    let userId: Int
    let username: String
    let createdAt: String
    
    var phoneId: Int?

    enum CodingKeys: String, CodingKey {
        case id = "reviewId"
        case username = "userName"
        case rating, content, userId, createdAt
    }
}
struct AverageRating: Codable, Sendable {
    let averageRating: Double
    let phoneId: Int64
}

struct ReviewCreateRequest: Codable {
    let phoneId: Int64
    let rating: Double
    let content: String
}
