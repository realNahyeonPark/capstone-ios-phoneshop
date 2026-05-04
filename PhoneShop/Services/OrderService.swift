import Foundation

class OrderService {
    static let shared = OrderService()
    private let baseURL: String = {
        let host = String(describing: Bundle.main.baseURL)
        return "http://\(host)"
    }()
    
    func fetchOrderHistory(completion: @escaping ([OrderHistoryResponse]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/orders/history") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion([])
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalCacheData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode([OrderHistoryResponse].self, from: data)
                DispatchQueue.main.async { completion(decodedResponse) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}
