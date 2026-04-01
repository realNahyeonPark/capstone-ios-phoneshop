/* Product.swift */
import Foundation

struct Product: Identifiable, Codable, Sendable, Equatable {
    let id: Int
    let name: String
    let brand: String
    let price: Int
    let imageUrl: String
    
    var fullImageUrl: URL? {
        let currentBase = Bundle.main.baseURL
        
        var cleanPath = imageUrl.replacingOccurrences(of: "http://localhost:8080", with: "")
        
        if cleanPath.hasPrefix("http") {
            return URL(string: cleanPath)
        }
        
        if !cleanPath.hasPrefix("/") {
            cleanPath = "/" + cleanPath
        }
        
        return URL(string: "http://\(currentBase)\(cleanPath)")
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: price)) ?? "\(price)") + "원"
    }
}

nonisolated struct ProductResponse: Codable, Sendable {
    let items: [Product]
}
