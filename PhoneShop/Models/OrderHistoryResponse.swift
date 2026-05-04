import Foundation

struct OrderHistoryResponse: Codable, Identifiable {
    let orderId: Int
    let status: String
    let finalPrice: Int
    let createdAt: String
    let paidAt: String
    let items: [OrderHistoryItemResponse]

    var id: Int { orderId }
    
    var formattedPaidDate: String {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: paidAt) {
            return displayDate(from: date)
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: paidAt) {
                return displayDate(from: date)
            }
        }
        
        return paidAt
    }
    
    private func displayDate(from date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        return displayFormatter.string(from: date)
    }
}

struct OrderHistoryItemResponse: Codable, Identifiable {
    let phoneId: Int
    let phoneName: String
    let brand: String
    let imageUrl: String?
    let quantity: Int
    let unitPrice: Int
    let totalPrice: Int

    var id: Int { phoneId }

    var fullImageURL: URL? {
        guard let imageUrl = imageUrl, !imageUrl.isEmpty else { return nil }
        if imageUrl.hasPrefix("http") { return URL(string: imageUrl) }
        
        let path = imageUrl.hasPrefix("/") ? imageUrl : "/" + imageUrl
        let host = String(describing: Bundle.main.baseURL)
        return URL(string: "http://\(host)\(path)")
    }
}
