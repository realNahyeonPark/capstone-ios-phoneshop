/* Coupon.swift */
import Foundation

struct CouponCreateRequest: Codable {
    let name: String
    let discountRate: Int
}

struct CouponItem: Identifiable, Codable {
    let id: Int
    let name: String
    let discountRate: Int
    
    enum CodingKeys: String, CodingKey {
            case id = "userCouponId"
            case name = "couponName"
            case discountRate
        }
    
    var discountString: String {
        return "\(discountRate)%"
    }
}

struct CouponListResponse: Codable {
    let coupons: [CouponItem]
}
