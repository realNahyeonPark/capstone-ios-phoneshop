import SwiftUI
import Combine
import UserNotifications

@MainActor
class CartService: ObservableObject {
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
        sendRequest(path: "/cart/items", method: "POST", phoneId: phoneId, shouldNotify: true)
    }

    func decreaseQuantity(phoneId: Int) {
        sendRequest(path: "/cart/items/decrease", method: "POST", phoneId: phoneId)
    }

    func removeFromCart(phoneId: Int) {
        sendRequest(path: "/cart", method: "DELETE", phoneId: phoneId)
    }

    private func sendRequest(path: String, method: String, phoneId: Int, shouldNotify: Bool = false) {
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
                
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    if shouldNotify {
                        scheduleCartReminder()
                    }
                    fetchCart()
                }
            } catch { }
        }
    }
    
    private func scheduleCartReminder() {
        let content = UNMutableNotificationContent()
        content.title = "장바구니에 상품이 담겼습니다! 🛒"
        content.body = "지금 구매하면 바로 출발합니다!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "CartReminder-\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { _ in }
    }
    
    func clearCart() {
        guard let url = URL(string: "\(baseURL)/cart") else { return }
        guard let token = UserDefaults.standard.string(forKey: "userToken") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        self.isLoading = true
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        self.items = []
                        self.totalPrice = 0
                        fetchCart()
                    }
                }
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }
}
