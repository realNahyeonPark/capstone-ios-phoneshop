//
//  MainViewModels.swift
//  IOSPhoneShop
//
//  Created by nh on 4/9/26.
//

import SwiftUI

class MainViewModels: ObservableObject {
    @Published var products: [Product] = [] // 원본 데이터
    @Published var selectedBrand: String = "전체"
    @Published var sortOption: SortOption = .latest
    
    enum SortOption: String, CaseIterable {
        case latest = "최신순"
        case priceHigh = "높은 가격순"
        case priceLow = "낮은 가격순"
    }

    // 브랜드 목록 추출 (중복 제거)
    var brands: [String] {
        ["전체"] + Array(Set(products.map { $0.brand })).sorted()
    }

    // 정렬 및 필터링된 결과값
    var filteredProducts: [Product] {
        var result = products
        
        // 1. 브랜드 필터링
        if selectedBrand != "전체" {
            result = result.filter { $0.brand == selectedBrand }
        }
        
        // 2. 정렬 로직
        switch sortOption {
        case .latest:
            result.sort { $0.id > $1.id } // ID가 클수록 최신이라고 가정
        case .priceHigh:
            result.sort { $0.price > $1.price }
        case .priceLow:
            result.sort { $0.price < $1.price }
        }
        
        return result
    }

    func loadProducts() {
        // 기존의 데이터 로드 로직 유지
    }
}
#Preview {
    MainViewModels()
}
