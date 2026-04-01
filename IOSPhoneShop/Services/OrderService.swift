/* OrderService.swift */
import Foundation

class OrderService {
    static let shared = OrderService()
    private let baseURL = "http://\(Bundle.main.baseURL)"
    
    func fetchOrderHistory(completion: @escaping ([OrderHistoryResponse]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/orders/history") else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalCacheData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([OrderHistoryResponse].self, from: data)
                
                DispatchQueue.main.async {
                    completion(decodedResponse)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
