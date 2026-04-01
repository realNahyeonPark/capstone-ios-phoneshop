import Foundation

class PaymentService {
    static let shared = PaymentService()
    private let baseURL = "http://\(Bundle.main.baseURL)"

    func readyKakaoPay(request: KakaoPayRequest, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/kakao-pay/ready") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let decodedResponse = try? JSONDecoder().decode(KakaoPayResponse.self, from: data) {
                completion(decodedResponse.next_redirect_pc_url)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
