import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @State private var selectedTab = 0
    @Namespace var animation
    @State private var reviews: [Review] = []
    @State private var averageRatingInfo: AverageRating?
    private let reviewService = ReviewService()

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ProductDetailHeaderImage(product: product)
                        
                        ProductBasicInfoSection(
                            product: product,
                            averageRating: self.averageRatingInfo?.averageRating,
                            totalReviewCount: self.reviews.count,
                            selectedTab: $selectedTab,
                            proxy: proxy
                        )
                        
                        Divider().frame(height: 8).background(Color(.systemGray6))
                        
                        
                        DetailStickyHeaderView(selectedTab: $selectedTab, proxy: proxy, animation: animation)
                        
                        VStack(spacing: 0) {
                            SpecificationSection(product: product)
                                .id(0)
                                .padding(.top, 20)
                            
                            Divider().padding(.vertical, 30)
                            
                            ReviewSummarySection(
                                product: product,
                                reviews: self.reviews,
                                averageRating: self.averageRatingInfo?.averageRating
                            )
                            .id(1)
                            
                            Divider().padding(.vertical, 30)
                            
                            QnaSection(phoneId: product.id)
                                .id(2)
                                .padding(.bottom, 50)
                            
                        }
                    }
                }
            }
            
            BottomActionBar(product: product)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let productIdString = String(product.id)
            async let fetchedReviews = reviewService.fetchReviews(phoneId: productIdString)
            async let fetchedRating = reviewService.fetchAverageRating(phoneId: productIdString)
            
            self.reviews = await fetchedReviews
            self.averageRatingInfo = await fetchedRating
        }
    }
}
