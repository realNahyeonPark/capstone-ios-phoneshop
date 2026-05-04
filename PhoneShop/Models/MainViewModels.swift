import Combine
import Foundation
import SwiftUI

@MainActor
class MainViewModels: ObservableObject {
    @Published var products: [Product] = []
    
    @Published var selectedBrand: String = "전체"
    @Published var sortOption: SortOption = .latest
    
    private let service = ProductService()

    enum SortOption: String, CaseIterable {
        case latest = "최신순"
        case priceHigh = "높은 가격순"
        case priceLow = "낮은 가격순"
    }

    var brands: [String] {
        let allBrands = products.map { $0.brand }
        return ["전체"] + Array(Set(allBrands)).sorted()
    }

    var filteredProducts: [Product] {
        var result = products
        
        if selectedBrand != "전체" {
            result = result.filter { $0.brand == selectedBrand }
        }
        
        switch sortOption {
        case .latest:
            result.sort { $0.id > $1.id }
        case .priceHigh:
            result.sort { $0.price > $1.price }
        case .priceLow:
            result.sort { $0.price < $1.price }
        }
        
        return result
    }

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
