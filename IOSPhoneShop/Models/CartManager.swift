import Foundation
import Combine

// 서버에서 내려오는 JSON 구조에 맞춘 모델 (예시)
struct CartResponse: Codable {
    let items: [CartItem]
    let totalPrice: Int
}

class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var totalPrice: Int = 0
    @Published var isLoading: Bool = false
    
    // API 엔드포인트
    private let baseURL = "https://your-api-server.com" // 실제 서버 주소로 변경
    
    // 장바구니 데이터 불러오기 (GET /cart)
    func fetchCart() {
        guard let url = URL(string: "\(baseURL)/cart") else { return }
        
        // 1. 토큰 가져오기 (예: UserDefaults나 KeyChain에 저장된 토큰)
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            print("인증 토큰이 없습니다.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // 토큰 인증
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                print("Error fetching cart: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CartResponse.self, from: data)
                DispatchQueue.main.async {
                    self.items = decodedResponse.items
                    self.totalPrice = decodedResponse.totalPrice
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    // 수량 조절 및 삭제는 통상 POST/PUT/DELETE API와 함께 로컬 상태를 업데이트합니다.
    func decreaseQuantity(at index: Int) {
        if items[index].quantity > 1 {
            items[index].quantity -= 1
            // TODO: 서버에 업데이트 API 호출 (PUT /cart/item/...)
        }
    }
    
    func addToCart(product: Product) {
        // TODO: 서버에 추가 API 호출 (POST /cart)
        // 호출 성공 후 fetchCart()를 다시 하거나 로컬 리스트에 추가
    }
}
