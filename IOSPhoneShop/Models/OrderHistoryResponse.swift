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
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: paidAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
            return displayFormatter.string(from: date)
        }
        return paidAt
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
}
