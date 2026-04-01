/* LoginResponse.swift */
import Foundation

nonisolated struct LoginResponse: Codable, Sendable {
    let token: String
    let id: Int64?
    let username: String?
    let userRole: String?
    
    enum CodingKeys: String, CodingKey {
        case token
        case id
        case username
        case userRole = "role"
    }
}
