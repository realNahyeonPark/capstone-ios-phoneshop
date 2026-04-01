import SwiftUI

struct ProductBasicInfoSection: View {
    let product: Product
    let averageRating: Double?
    let totalReviewCount: Int
    @Binding var selectedTab: Int
    let proxy: ScrollViewProxy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(product.name)
                .font(.system(size: 22, weight: .bold))
                .lineLimit(2)
                .foregroundColor(.primary)
            
            Button(action: {
                withAnimation {
                    selectedTab = 1
                    proxy.scrollTo(1, anchor: .top)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                    
                    Text(String(format: "%.1f", averageRating ?? 0.0))
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("(\(totalReviewCount)개 상품평)")
                        .font(.system(size: 14))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Text(product.formattedPrice)
                .font(.system(size: 24, weight: .black))
        }
        .padding(20)
    }
}
