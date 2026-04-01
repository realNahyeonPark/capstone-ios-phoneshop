import SwiftUI
import Combine

@MainActor
class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var totalPrice: Int = 0
    @Published var isLoading: Bool = false
    
    private let baseURL = "http://\(Bundle.main.baseURL)"
    
    func fetchCart() {
        guard let url = URL(string: "\(baseURL)/cart") else { return }
        guard let token = UserDefaults.standard.string(forKey: "userToken") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        self.isLoading = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let decodedResponse = try JSONDecoder().decode(CartResponse.self, from: data)
                self.items = decodedResponse.items
                self.totalPrice = decodedResponse.totalPrice
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }
    
    func addToCart(phoneId: Int) {
        sendRequest(path: "/cart/items", method: "POST", phoneId: phoneId)
    }

    func decreaseQuantity(phoneId: Int) {
        sendRequest(path: "/cart/items/decrease", method: "POST", phoneId: phoneId)
    }

    func removeFromCart(phoneId: Int) {
        sendRequest(path: "/cart", method: "DELETE", phoneId: phoneId)
    }

    private func sendRequest(path: String, method: String, phoneId: Int) {
        guard let url = URL(string: "\(baseURL)\(path)") else { return }
        guard let token = UserDefaults.standard.string(forKey: "userToken") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = CartItemRequest(phoneId: phoneId)
        request.httpBody = try? JSONEncoder().encode(body)
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        fetchCart()
                    }
                }
            } catch {
            }
        }
    }
}
