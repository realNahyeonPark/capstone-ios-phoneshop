/* CommentService.swift */
import Foundation

class CommentService {
    static let shared = CommentService()
    private let baseURL = "http://\(Bundle.main.baseURL)"
    
    func fetchComments(phoneId: Int, completion: @escaping ([CommentResponse]?) -> Void) {
        let urlString = "\(baseURL)/comments/phones/\(phoneId)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let comments = try decoder.decode([CommentResponse].self, from: data)
                DispatchQueue.main.async { completion(comments) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
    
    func createComment(phoneId: Int, content: String, completion: @escaping (Bool) -> Void) {
        let urlString = "\(baseURL)/comments"
        guard let url = URL(string: urlString) else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = CommentsCreateRequest(phoneId: phoneId, content: content)
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                let success = (200...299).contains(httpResponse.statusCode)
                DispatchQueue.main.async { completion(success) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }

    func updateComment(commentId: Int, content: String, completion: @escaping (Bool) -> Void) {
        let urlString = "\(baseURL)/comments/\(commentId)"
        guard let url = URL(string: urlString) else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = CommentUpdateRequest(content: content)
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                let success = (200...299).contains(httpResponse.statusCode)
                DispatchQueue.main.async { completion(success) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
    
    func deleteComment(commentId: Int, completion: @escaping (Bool) -> Void) {
        let urlString = "\(baseURL)/comments/\(commentId)"
        guard let url = URL(string: urlString) else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                let success = (200...299).contains(httpResponse.statusCode)
                DispatchQueue.main.async { completion(success) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
}
