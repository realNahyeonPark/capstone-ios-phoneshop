import SwiftUI

struct ProductCardView: View {
    let product: Product
    
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var showLoginAlert = false
    
    @State private var averageRating: Double?
    private let reviewService = ReviewService()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Color(.systemGray6)
                
                AsyncImage(url: product.fullImageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 160)
                            .clipped()
                    case .failure(_):
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 160)
                .contentShape(Rectangle())
                .clipped()
                
                Button {
                    if isLoggedIn {
                        favoritesManager.toggleFavorite(product: product)
                    } else {
                        showLoginAlert = true
                    }
                } label: {
                    let isCurrentlyFavorite = isLoggedIn && favoritesManager.isFavorite(productId: product.id)
                    
                    Image(systemName: isCurrentlyFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isCurrentlyFavorite ? .red : .white)
                        .padding(8)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(product.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", averageRating ?? 0.0))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 6)
                    
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(product.favoriteCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
                
                Text(product.formattedPrice)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.top, 2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(12)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .task {
            self.averageRating = await reviewService.fetchAverageRating(phoneId: String(product.id))?.averageRating
        }
        .alert("알림", isPresented: $showLoginAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("찜하기 기능은 로그인 후 이용 가능합니다.")
        }
    }
}
