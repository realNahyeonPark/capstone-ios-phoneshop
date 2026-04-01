/* ReviewSummarySection.swift */
import SwiftUI

struct ReviewSummarySection: View {
    let product: Product
    let reviews: [Review]
    let averageRating: Double?
    
    var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("상품 리뷰").font(.headline)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption)
                            
                            Text(String(format: "%.1f", averageRating ?? 0.0))
                                .font(.subheadline).fontWeight(.bold)
                            
                            Text("(\(reviews.count))")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                
                NavigationLink(destination: ReviewListView(product: product)) {
                    HStack(spacing: 2) {
                        Text("전체보기")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption).foregroundColor(.secondary)
                    .padding(.vertical, 4).padding(.horizontal, 8)
                    .background(Color(.systemGray5)).cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            if let latestReview = reviews.first {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { i in
                                Image(systemName: "star.fill")
                                    .foregroundColor(i < Int(latestReview.rating) ? .yellow : .gray)
                                    .font(.system(size: 10))
                            }
                        }
                        Text(latestReview.username).font(.caption2).foregroundColor(.secondary)
                        Spacer()
                        Text(latestReview.createdAt.prefix(10)).font(.caption2).foregroundColor(.secondary)
                    }
                    Text(latestReview.content)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 24))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("아직 작성된 리뷰가 없습니다.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            }
        }
    }
}
