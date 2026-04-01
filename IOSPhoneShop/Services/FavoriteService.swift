/* FavoriteService.swift */
import Foundation

class FavoriteService {
    static let shared = FavoriteService()
    private let baseURL = "http://\(Bundle.main.baseURL)"

    func addToFavorites(phoneId: Int, completion: @escaping (Bool) -> Void) {
        var components = URLComponents(string: "\(baseURL)/favorites")
        components?.queryItems = [URLQueryItem(name: "phoneId", value: "\(phoneId)")]
        
        guard let url = components?.url else { return }
        
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            let isAlreadyRegistered = (httpResponse.statusCode == 500 &&
                                       data != nil &&
                                       String(data: data!, encoding: .utf8)?.contains("already") == true)

            if (200...299).contains(httpResponse.statusCode) || isAlreadyRegistered {
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
    
    func removeFromFavorites(phoneId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/favorites/\(phoneId)") else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  error == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            DispatchQueue.main.async { completion(true) }
        }.resume()
    }
}
