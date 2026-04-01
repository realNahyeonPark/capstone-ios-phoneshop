/* ProductDetailHeaderImage.swift */
import SwiftUI

struct ProductDetailHeaderImage: View {
    let product: Product
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemGray6)
                .frame(height: 300)

            AsyncImage(url: product.fullImageUrl) { phase in
                switch phase {
                case .empty: ProgressView()
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 280)
                        .frame(maxWidth: .infinity)
                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                @unknown default: EmptyView()
                }
            }
            .frame(height: 300)

            Button(action: {
                withAnimation(.spring()) {
                    favoritesManager.toggleFavorite(product: product)
                }
            }) {
                Image(systemName: favoritesManager.isFavorite(productId: product.id) ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(favoritesManager.isFavorite(productId: product.id) ? .red : .gray)
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.8)))
                    .padding(15)
            }
        }
    }
}
