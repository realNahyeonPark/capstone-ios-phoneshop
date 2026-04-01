/* MainViewModels.swift */
import Combine
import Foundation

@MainActor
class MainViewModels: ObservableObject {
    @Published var products: [Product] = []
    private let service = ProductService()

    func loadProducts() {
        service.fetchAllPhones { [weak self] fetchedProducts in
            Task { @MainActor in
                if let data = fetchedProducts {
                    self?.products = data
                }
            }
        }
    }
}
