import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartService: CartService
    @State private var showingClearAlert = false
    
    var productsToOrder: [Product] {
        cartService.items.map { item in
            Product(
                id: item.phoneId,
                name: item.name,
                brand: item.brand,
                price: item.price,
                imageUrl: item.imageUrl,
                favoriteCount: item.favoriteCount ?? 0)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if cartService.isLoading {
                    ProgressView().frame(maxHeight: .infinity)
                } else if cartService.items.isEmpty {
                    emptyCartView.frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(cartService.items, id: \.phoneId) { item in
                                CartItemRow(item: item)
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                    .background(Color.white)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("총 \(cartService.items.count)개 상품")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(cartService.totalPrice)원")
                                .font(.title3)
                                .bold()
                        }
                        .padding(.horizontal)
                        .padding(.top, 15)
                        
                        NavigationLink(destination: CheckoutView(products: productsToOrder)) {
                            Text("주문하기")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
                }
            }
            .navigationTitle("장바구니")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !cartService.items.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("비우기") {
                            showingClearAlert = true
                        }
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    }
                }
            }
            .alert("장바구니 비우기", isPresented: $showingClearAlert) {
                Button("취소", role: .cancel) { }
                Button("전체 삭제", role: .destructive) {
                    cartService.clearCart()
                }
            } message: {
                Text("장바구니에 담긴 모든 상품을 삭제하시겠습니까?")
            }
            .onAppear {
                cartService.fetchCart()
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 15) {
            Image(systemName: "cart")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            Text("장바구니에 담긴 상품이 없습니다.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
    }
}
