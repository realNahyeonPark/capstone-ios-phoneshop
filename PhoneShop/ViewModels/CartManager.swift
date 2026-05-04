//import SwiftUI
//import Combine
//import UserNotifications
//
//@MainActor
//class CartManager: ObservableObject {
//    @Published var items: [CartItem] = []
//    @Published var totalPrice: Int = 0
//    @Published var isLoading: Bool = false
//    
//    private let baseURL = "http://\(Bundle.main.baseURL)"
//    
//    // MARK: - 장바구니 데이터 가져오기
//    func fetchCart() {
//        guard let url = URL(string: "\(baseURL)/cart") else { return }
//        guard let token = UserDefaults.standard.string(forKey: "userToken") else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        self.isLoading = true
//        
//        Task {
//            do {
//                let (data, _) = try await URLSession.shared.data(for: request)
//                let decodedResponse = try JSONDecoder().decode(CartResponse.self, from: data)
//                
//                self.items = decodedResponse.items
//                self.totalPrice = decodedResponse.totalPrice
//                self.isLoading = false
//            } catch {
//                print("❌ 장바구니 불러오기 실패: \(error)")
//                self.isLoading = false
//            }
//        }
//    }
//    
//    // MARK: - 상품 추가 (알림 포함)
//    func addToCart(phoneId: Int) {
//        // 네트워크 요청과 알림 처리를 한 번에 수행
//        sendRequest(path: "/cart/items", method: "POST", phoneId: phoneId, shouldNotify: true)
//    }
//
//    func decreaseQuantity(phoneId: Int) {
//        sendRequest(path: "/cart/items/decrease", method: "POST", phoneId: phoneId)
//    }
//
//    func removeFromCart(phoneId: Int) {
//        sendRequest(path: "/cart", method: "DELETE", phoneId: phoneId)
//    }
//
//    // MARK: - 공통 네트워크 요청 함수
//    private func sendRequest(path: String, method: String, phoneId: Int, shouldNotify: Bool = false) {
//        guard let url = URL(string: "\(baseURL)\(path)") else { return }
//        guard let token = UserDefaults.standard.string(forKey: "userToken") else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let body = CartItemRequest(phoneId: phoneId)
//        request.httpBody = try? JSONEncoder().encode(body)
//        
//        Task {
//            do {
//                let (_, response) = try await URLSession.shared.data(for: request)
//                
//                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
//                    print("✅ 요청 성공: \(path)")
//                    
//                    // 성공했을 때 알림 예약 (상품 추가 시에만)
//                    if shouldNotify {
//                        scheduleCartReminder()
//                    }
//                    
//                    // 목록 새로고침
//                    fetchCart()
//                }
//            } catch {
//                print("❌ 요청 실패: \(error)")
//            }
//        }
//    }
//    
//    // MARK: - 알림 예약 로직
//    private func scheduleCartReminder() {
//        let content = UNMutableNotificationContent()
//        content.title = "장바구니에 상품이 담겼습니다! 🛒"
//        content.body = "지금 구매하면 바로 출발합니다!"
//        content.sound = .default
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        let request = UNNotificationRequest(identifier: "CartReminder-\(UUID().uuidString)", content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("❌ 알림 예약 실패: \(error.localizedDescription)")
//            } else {
//                print("🚀 알림 예약 성공! 5초 뒤에 확인하세요.")
//            }
//        }
//    }
//    
//    func clearCart() {
//        // ... 기존 clearCart 코드 동일 ...
//    }
//}
