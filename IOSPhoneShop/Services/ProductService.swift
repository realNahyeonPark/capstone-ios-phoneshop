/* ProductService.swift */
import Foundation
import UIKit

class ProductService {
    static let shared = ProductService()
    private let baseURL = "http://\(Bundle.main.baseURL)"

    // 상품 등록 (관리자 전용)
    func createProduct(name: String, brand: String, price: Int, image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/phones") else { return }
        
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let httpBody = NSMutableData()
        
        let jsonDict: [String: Any] = [
            "name": name,
            "brand": brand,
            "price": price
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict) {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"phone\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            httpBody.append(jsonData)
            httpBody.append("\r\n".data(using: .utf8)!)
        }
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"image\"; filename=\"product.jpg\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            httpBody.append(imageData)
            httpBody.append("\r\n".data(using: .utf8)!)
        }
        
        httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = httpBody as Data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let success = (httpResponse.statusCode == 200 || httpResponse.statusCode == 201)
                DispatchQueue.main.async { completion(success) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
    
    // 등록한 상품 삭제 (관리자 전용)
    func deleteProduct(id: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/phones/\(id)") else { return }
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

    func fetchAllPhones(completion: @escaping ([Product]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/phones") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let decoder = JSONDecoder()
            do {
                if let products = try? decoder.decode([Product].self, from: data) {
                    DispatchQueue.main.async { completion(products) }
                    return
                }
                
                let response = try decoder.decode(ProductResponse.self, from: data)
                DispatchQueue.main.async { completion(response.items) }
                
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}
