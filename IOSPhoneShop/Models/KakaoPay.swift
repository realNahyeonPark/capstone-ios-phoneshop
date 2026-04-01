/* KakaoPay.swift */
import Foundation

struct OrderItemRequest: Encodable {
    let phoneId: Int
    let quantity: Int
}

struct KakaoPayRequest: Encodable {
    let userId: Int
    let items: [OrderItemRequest]
    let userCouponId: Int?
}

struct KakaoPayResponse: Decodable {
    let tid: String
    let next_redirect_pc_url: String
    let next_redirect_app_url: String
}
