/* CartService.swift */
import Foundation

class CartService {
    static let shared = CartService()
    private let baseURL = "http://\(Bundle.main.baseURL)"
    
    func addToCart(phoneId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/cart/items") else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let addRequest = CartItemRequest(phoneId: phoneId)
        
        if let body = try? JSONEncoder().encode(addRequest) {
            request.httpBody = body
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            let success = (200...299).contains(httpResponse.statusCode)
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
}
