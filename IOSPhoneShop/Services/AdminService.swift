/* AdminService.swift */
import Foundation

class AdminService {
    static let shared = AdminService()
    private let baseURL = "http://\(Bundle.main.baseURL)"
    
    private init() {}

    func fetchTotalSales(completion: @escaping (Int?) -> Void) {
        let urlString = "\(self.baseURL)/admin/totalSales"
        guard let url = URL(string: urlString) else { return }
        
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                let totalSales = try JSONDecoder().decode(Int.self, from: data)
                DispatchQueue.main.async { completion(totalSales) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}
