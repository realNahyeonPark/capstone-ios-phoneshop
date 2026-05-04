import SwiftUI

struct ReviewListView: View {
    let product: Product
    let service = ReviewService()
    
    @State private var showWriteSheet = false
    @State private var reviews: [Review] = []
    @State private var averageRatingInfo: AverageRating?

    var body: some View {
        List {
            VStack(spacing: 0) {
                Divider()
                
                HStack(alignment: .center, spacing: 6) {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < Int(averageRatingInfo?.averageRating.rounded() ?? 0) ? "star.fill" : "star")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text("\(reviews.count)")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 25)
                
                Divider()
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            
            if reviews.isEmpty {
                Text("작성된 리뷰가 없습니다.")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .listRowInsets(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
            } else {
                ForEach(reviews) { review in
                    ReviewRow(review: review)
                        .listRowInsets(EdgeInsets(top: 15, leading: 16, bottom: 15, trailing: 16))
                }
            }
        }
        .listStyle(.plain)
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
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.gray.opacity(0.3))
                
                Text(review.username)
                    .font(.system(size: 15, weight: .bold))
                
                Spacer()
            }
            
            HStack(spacing: 4) {
                HStack(spacing: 1) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(review.rating) ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(review.createdAt.prefix(10))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                Spacer()
            }
            
            Text(review.content)
                .font(.system(size: 14))
                .lineSpacing(3)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
