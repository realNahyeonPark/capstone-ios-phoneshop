/* ReviewListView.swift */
import SwiftUI

struct ReviewListView: View {
    let product: Product
    let service = ReviewService()
    
    @State private var showWriteSheet = false
    @State private var reviews: [Review] = []
    @State private var averageRatingInfo: AverageRating?

    var body: some View {
        List {
            Section {
                HStack(spacing: 20) {
                    VStack {
                        Text(String(format: "%.1f", averageRatingInfo?.averageRating ?? 0.0))
                            .font(.system(size: 40, weight: .bold))
                        Text("전체 평점")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(0..<5) { i in
                            let starLevel = 5 - i
                            let countForLevel = Double(reviews.filter { Int($0.rating) == starLevel }.count)
                            let totalCount = Double(max(reviews.count, 1))
                            let ratio = countForLevel / totalCount
                            
                            HStack {
                                Text("\(starLevel)점").font(.caption).frame(width: 25)
                                ProgressView(value: ratio).tint(.yellow)
                            }
                        }
                    }
                }
                .padding(.vertical)
            } header: {
                Text("평점 요약")
            }

            Section(header: Text("리뷰 \(reviews.count)개")) {
                if reviews.isEmpty {
                    Text("작성된 리뷰가 없습니다.")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(reviews) { review in
                        ReviewRow(review: review)
                    }
                }
            }
        }
        .navigationTitle("\(product.name) 리뷰")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showWriteSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        
        .sheet(isPresented: $showWriteSheet, onDismiss: {
            Task { await loadData() }
        }) {
            ReviewWriteView(
                phoneId: Int64(product.id),
                productName: product.name
            )
        }
        .task {
            await loadData()
        }
    }

    private func loadData() async {
        let productIdString = String(product.id)
        async let fetchedReviews = service.fetchReviews(phoneId: productIdString)
        async let fetchedRating = service.fetchAverageRating(phoneId: productIdString)
        
        self.reviews = await fetchedReviews
        self.averageRatingInfo = await fetchedRating
    }
}

struct ReviewRow: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ForEach(0..<5) { i in
                    Image(systemName: i < Int(review.rating) ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
                
                Text(review.username)
                    .font(.caption).bold()
                
                Spacer()
                
                Text(review.createdAt.prefix(10))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(review.content)
                .font(.subheadline)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
    }
}
