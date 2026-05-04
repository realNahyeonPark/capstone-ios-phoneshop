import SwiftUI

struct MyReviewsView: View {
    @State private var myReviews: [Review] = []
    @State private var isLoading = true
    
    let service = ReviewService()
    
    @AppStorage("userId") var currentUserId: Int = 0
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if isLoading {
                    ProgressView("기록을 불러오는 중...")
                        .padding(.top, 50)
                } else if myReviews.isEmpty {
                    EmptyReviewView()
                } else {
                    ForEach(myReviews) { review in
                        if let pid = review.phoneId {
                            NavigationLink(destination: ProductReviewBridgeView(phoneId: pid)) {
                                MyReviewCard(review: review) {
                                    Task { await fetchMyReviews() }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            MyReviewCard(review: review) {
                                Task { await fetchMyReviews() }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color(.systemGray6))
        .navigationTitle("내가 쓴 리뷰")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if currentUserId == 0 { }
            await fetchMyReviews()
        }
    }
    
    private func fetchMyReviews() async {
        await MainActor.run {
            self.isLoading = true
            self.myReviews = []
        }
        
        var allMappedReviews: [Review] = []
        
        ProductService.shared.fetchAllPhones { allProducts in
            guard let products = allProducts else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            
            Task {
                for product in products {
                    let reviews = await service.fetchReviews(phoneId: String(product.id))
                    
                    let mapped = reviews.map { review -> Review in
                        var updatedReview = review
                        updatedReview.phoneId = product.id
                        return updatedReview
                    }
                    allMappedReviews.append(contentsOf: mapped)
                }
                
                let filtered = allMappedReviews.filter { $0.userId == currentUserId }
                
                await MainActor.run {
                    self.myReviews = filtered
                    self.isLoading = false
                }
            }
        }
    }
}

struct MyReviewCard: View {
    let review: Review
    let service = ReviewService()
    var onDelete: () -> Void
    
    @State private var isDeleting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.gray.opacity(0.3))
                
                Text(review.username)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(role: .destructive) {
                    deleteAction()
                } label: {
                    if isDeleting {
                        ProgressView().tint(.red)
                    } else {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                .disabled(isDeleting)
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
                .lineSpacing(4)
                .foregroundColor(.primary.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(2)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        ).shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
    }
    
    private func deleteAction() {
        isDeleting = true
        Task {
            let success = await service.deleteReview(reviewId: Int64(review.id))
            await MainActor.run {
                isDeleting = false
                if success {
                    onDelete()
                }
            }
        }
    }
}

struct EmptyReviewView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 150)
            
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(.gray.opacity(0.2))
            
            Text("아직 작성한 리뷰가 없어요")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
