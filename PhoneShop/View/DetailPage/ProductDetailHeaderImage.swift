import SwiftUI

struct ProductDetailHeaderImage: View {
    let product: Product
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var showLoginAlert = false
    
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

            let isFavoriteRed = isLoggedIn && favoritesManager.isFavorite(productId: product.id)

            Button(action: {
                if isLoggedIn {
                    withAnimation(.spring()) {
                        favoritesManager.toggleFavorite(product: product)
                    }
                } else {
                    showLoginAlert = true
                }
            }) {
                Image(systemName: isFavoriteRed ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(isFavoriteRed ? .red : .gray)
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.8)))
                    .padding(15)
            }
        }
        .alert("알림", isPresented: $showLoginAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("찜하기 기능은 로그인 후 이용 가능합니다.")
        }
    }
}
