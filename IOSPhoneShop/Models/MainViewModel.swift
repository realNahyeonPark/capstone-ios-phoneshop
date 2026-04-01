import SwiftUI

class MainViewModel: ObservableObject {
    @Published var products: [Product] = []
    private let service = ProductService()

    func loadProducts() {
        service.fetchAllPhones { [weak self] fetchedList in
            if let list = fetchedList {
                self?.products = list
            }
        }
    }
}
