import Foundation

class FavoriteService {
    static let shared = FavoriteService()
    private let baseURL = "http://localhost:8080" // 서버 주소 확인!

    func addToFavorites(phoneId: Int, completion: @escaping (Bool) -> Void) {
        // 명세서의 Parameter 방식에 따라 URL 생성 (예: /favorites?phoneId=1)
        var components = URLComponents(string: "\(baseURL)/favorites")
        components?.queryItems = [URLQueryItem(name: "phoneId", value: "\(phoneId)")]
        
        guard let url = components?.url else { return }
        
        // 토큰 가져오기
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            // 성공 상태 코드 확인
            let success = (200...299).contains(httpResponse.statusCode)
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
}
