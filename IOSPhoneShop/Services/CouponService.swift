/* CouponService.swift */
import Foundation

class CouponService {
    static let shared = CouponService()
    private let baseURL = "http://\(Bundle.main.baseURL)"
    
    func createCoupon(name: String, discountRate: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/admin/coupons") else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = CouponCreateRequest(name: name, discountRate: discountRate)
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let success = (response as? HTTPURLResponse)?.statusCode == 200 || (response as? HTTPURLResponse)?.statusCode == 201
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }
    
    func fetchUserCoupons(completion: @escaping ([CouponItem]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/coupons") else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                let decodedCoupons = try JSONDecoder().decode([CouponItem].self, from: data)
                DispatchQueue.main.async {
                    completion(decodedCoupons)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
