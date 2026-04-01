/* FavoritesManager.swift */
import SwiftUI
import Combine

class FavoritesManager: ObservableObject {
    @Published var favoriteIds: Set<Int> = []
    private let storageKey = "Local_Favorite_IDs"
    
    private var baseURL: String {
        return "http://\(Bundle.main.baseURL)/favorites"
    }
    
    init() {
        loadFromLocal()
        fetchFavorites()
    }
    
    func isFavorite(productId: Int) -> Bool {
        return favoriteIds.contains(productId)
    }
    
    func fetchFavorites() {
        guard let url = URL(string: baseURL) else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let decodedIds = try? JSONDecoder().decode([Int].self, from: data) {
                DispatchQueue.main.async {
                    self.favoriteIds = Set(decodedIds)
                    self.saveToLocal()
                }
            }
        }.resume()
    }
    
    func toggleFavorite(product: Product) {
        if isFavorite(productId: product.id) {
            FavoriteService.shared.removeFromFavorites(phoneId: product.id) { success in
                if success {
                    DispatchQueue.main.async {
                        self.favoriteIds.remove(product.id)
                        self.saveToLocal()
                    }
                }
            }
        } else {
            FavoriteService.shared.addToFavorites(phoneId: product.id) { success in
                DispatchQueue.main.async {
                    self.favoriteIds.insert(product.id)
                    self.saveToLocal()
                }
            }
        }
    }
    
    private func saveToLocal() {
        let array = Array(self.favoriteIds)
        UserDefaults.standard.set(array, forKey: storageKey)
    }
    
    private func loadFromLocal() {
        if let savedIds = UserDefaults.standard.array(forKey: storageKey) as? [Int] {
            self.favoriteIds = Set(savedIds)
        }
    }
}
