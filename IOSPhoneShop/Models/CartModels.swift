/* CartModels.swift */
import Foundation

// 1. 상품 추가/감소 요청 (보통 상품 ID와 수량이 필요합니다)
struct CartItemRequest: Codable {
    let phoneId: Int
    let quantity: Int
}

// 2. 장바구니 조회 응답 (백엔드 구조에 맞춰 예상한 모델입니다)
struct CartResponse: Codable {
    let items: [CartItem]
    let totalPrice: Int
}

struct CartItem: Codable, Identifiable {
    let id: Int // cartItemId
    let phoneId: Int
    let name: String
    let price: Int
    let quantity: Int
    let imageUrl: String?
}
