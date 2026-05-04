import Foundation

// ⭐ 1. 회원 탈퇴 시 서버로 보낼 데이터를 정의합니다.
struct WithdrawRequest: Codable {
    let name: String
    let email: String
    let password: String
}

// ⭐ 2. 회원 정보 수정 시 서버로 보낼 데이터를 정의합니다. (API 명세에 맞춰 필드 추가)
struct UserUpdateRequest: Codable {
    let name: String
    let phone: String
    let address: String
    let birthDate: String // 또는 Date (서버 형식에 따라)
}
