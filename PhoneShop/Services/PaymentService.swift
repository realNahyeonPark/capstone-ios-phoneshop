import Foundation

class PaymentService {
    private struct ApproveResult: Codable {
        let success: Bool?
        let orderId: Int?
        let message: String?
    }
    
    static let shared = PaymentService()
    private let baseURL: String = {
        let host = String(describing: Bundle.main.baseURL)
        return "http://\(host)"
    }()

    func readyKakaoPay(request: KakaoPayRequest) async -> String? {
        guard let url = URL(string: "\(baseURL)/v1/kakao-pay/ready") else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let decodedResponse = try JSONDecoder().decode(KakaoPayResponse.self, from: data)
            
            UserDefaults.standard.set(decodedResponse.tid, forKey: "kakaoPayTID")
            return decodedResponse.next_redirect_pc_url
            
        } catch {
            return nil
        }
    }
    
    func approvePayment(pgToken: String) async -> Bool {
        let tid = UserDefaults.standard.string(forKey: "kakaoPayTID")
        let query = tid != nil ? "pg_token=\(pgToken)&tid=\(tid!)" : "pg_token=\(pgToken)"
        
        guard let url = URL(string: "\(baseURL)/v1/kakao-pay/success?\(query)") else { return false }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            
            let is2xx = (200...299).contains(httpResponse.statusCode)
            var finalSuccess = is2xx
            
            do {
                let result = try JSONDecoder().decode(ApproveResult.self, from: data)
                if let success = result.success {
                    finalSuccess = success
                }
                
                if finalSuccess {
                    NotificationCenter.default.post(name: .init("reloadOrders"), object: nil)
                }
            } catch {
                if is2xx {
                    NotificationCenter.default.post(name: .init("reloadOrders"), object: nil)
                }
            }
            return finalSuccess
            
        } catch {
            return false
        }
    }
}
