/* ProductReviewBridgeView.swift */
import SwiftUI

struct ProductReviewBridgeView: View {
    let phoneId: Int
    @State private var product: Product?
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("상품 정보를 불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let product = product {
                ReviewListView(product: product)
            } else {
                VStack {
                    Image(systemName: "iphone.slash")
                        .font(.largeTitle)
                        .padding(.bottom, 10)
                    Text("해당 상품 정보를 찾을 수 없습니다.")
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            loadProductData()
        }
    }

    private func loadProductData() {
        ProductService.shared.fetchAllPhones { allProducts in
            DispatchQueue.main.async {
                if let allProducts = allProducts {
                    self.product = allProducts.first(where: { $0.id == phoneId })
                }
                self.isLoading = false
            }
        }
    }
}
