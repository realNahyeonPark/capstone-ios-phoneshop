/* WishlistView.swift */
import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var allProducts: [Product] = []

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    let favoriteProducts = allProducts.filter { favoritesManager.isFavorite(productId: $0.id) }
                    
                    if favoriteProducts.isEmpty {
                        emptyStateView
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(favoriteProducts) { product in
                                WishlistProductCardView(product: product)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("찜한 목록")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchLatestProducts()
        }
    }

    var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 150)
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(.gray.opacity(0.2))
            Text("위시리스트가 비어있어요")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func fetchLatestProducts() {
        ProductService.shared.fetchAllPhones { products in
            if let products = products {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.allProducts = products
                    }
                }
            }
        }
    }
}

struct WishlistProductCardView: View {
    let product: Product
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: product.fullImageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(20)
                    default:
                        Rectangle().foregroundColor(.gray.opacity(0.1))
                    }
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button(action: {
                    withAnimation(.spring()) {
                        favoritesManager.toggleFavorite(product: product)
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.red)
                        .padding(12)
                        .shadow(color: .white, radius: 4)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                
                Text(product.formattedPrice)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
}
