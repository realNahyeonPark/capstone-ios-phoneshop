/* OrderService.swift */
import Foundation

struct OrderHistoryWrapper: Codable {
    let data: [OrderHistoryResponse]
}

class OrderService {
    static let shared = OrderService()
    private let baseURL = "http://\(Bundle.main.baseURL)"
    
    func fetchOrderHistory(completion: @escaping ([OrderHistoryResponse]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/orders/history") else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([OrderHistoryResponse].self, from: data)
                
                DispatchQueue.main.async {
                    completion(decodedResponse) // 배열 그대로 전달
                }
            } catch {
                print("❌ 최종 디코딩 실패 원인: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
