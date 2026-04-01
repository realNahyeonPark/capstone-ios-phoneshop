import SwiftUI

struct ReviewPreviewSection: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("상품 리뷰").font(.headline)
                    ReviewRatingLabel(rating: product.rating, count: product.reviewCount)
                }
                Spacer()
                // 전체보기 버튼
                NavigationLink(destination: ReviewListView(product: product)) {
                    Text("전체보기").font(.caption).padding(8).background(Color(.systemGray5)).cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // 최근 리뷰 미리보기 박스
            LatestReviewCard()
        }
    }
}

// ⭐ 오류 해결: Review 모델 인스턴스를 생성할 때 파라미터를 모두 채워줍니다.
struct LatestReviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("배송이 아주 빠르고 제품 상태가 좋습니다.")
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
