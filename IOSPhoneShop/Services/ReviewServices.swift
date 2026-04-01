/* ReviewService.swift */
import Foundation

class ReviewService {
    private let baseURL = "http://\(Bundle.main.baseURL)"
    let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
    
    func fetchReviews(phoneId: String) async -> [Review] {
        guard let url = URL(string: "\(baseURL)/reviews/phones/\(phoneId)") else { return [] }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                return []
            }

            if let response = try? JSONDecoder().decode(PhoneReviewResponse.self, from: data) {
                return response.reviews
            }
            if let reviews = try? JSONDecoder().decode([Review].self, from: data) {
                return reviews
            }
            
            return []
        } catch {
            return []
        }
    }
    
    func fetchAllReviews() async -> [Review] {
        var allCollectedReviews: [Review] = []
        
        let actualProducts: [Product] = await withCheckedContinuation { continuation in
            ProductService.shared.fetchAllPhones { products in
                continuation.resume(returning: products ?? [])
            }
        }
        
        for product in actualProducts {
            let reviews = await fetchReviews(phoneId: "\(product.id)")
            allCollectedReviews.append(contentsOf: reviews)
        }
        
        return allCollectedReviews
    }
    
    func fetchAverageRating(phoneId: String) async -> AverageRating? {
        let encodedId = phoneId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? phoneId
        guard let url = URL(string: "\(baseURL)/reviews/phones/\(encodedId)/average") else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(AverageRating.self, from: data)
            return decoded
        } catch {
            return nil
        }
    }
    
    func createReview(phoneId: Int64, rating: Double, content: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/reviews") else { return false }
        
        let requestBody = ReviewCreateRequest(phoneId: phoneId, rating: rating, content: content)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            
            return httpResponse.statusCode == 200 || httpResponse.statusCode == 201
        } catch {
            return false
        }
    }
    
    func deleteReview(reviewId: Int64) async -> Bool {
        guard let url = URL(string: "\(baseURL)/reviews/\(reviewId)") else { return false }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            
            return httpResponse.statusCode == 200 || httpResponse.statusCode == 204
        } catch {
            return false
        }
    }
    
    struct PhoneReviewResponse: Codable {
        let reviews: [Review]
    }
}
