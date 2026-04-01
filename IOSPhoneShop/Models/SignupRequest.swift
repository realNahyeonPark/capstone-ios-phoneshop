/* SignupRequest.swift */

import Foundation

struct SignupRequest: Codable {
    let email: String
    let password: String
    let name: String
}
