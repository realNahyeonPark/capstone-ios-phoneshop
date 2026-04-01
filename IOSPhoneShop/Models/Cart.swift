/* Cart.swift */
import Foundation

struct CartResponse: Codable {
    let items: [CartItem]
    let totalPrice: Int
}

struct CartItem: Identifiable, Codable {
    var id: Int { phoneId }
    let phoneId: Int
    let name: String
    let brand: String
    let price: Int
    let imageUrl: String
    var quantity: Int
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: price)) ?? "\(price)") + "원"
    }
}

struct CartItemRequest: Codable {
    let phoneId: Int
}
