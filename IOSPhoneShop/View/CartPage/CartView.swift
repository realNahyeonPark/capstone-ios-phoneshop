import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    
    var productsToOrder: [Product] {
        cartManager.items.map { item in
            Product(id: item.phoneId, name: item.name, brand: item.brand, price: item.price, imageUrl: item.imageUrl)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if cartManager.isLoading {
                    ProgressView("장바구니를 불러오는 중...")
                } else if cartManager.items.isEmpty {
                    emptyCartView
                } else {
                    CartListView()
                    
                    VStack(spacing: 15) {
                        Divider()
                        HStack {
                            Text("총 주문 금액")
                                .font(.headline)
                            Spacer()
                            Text("\(cartManager.totalPrice)원")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        NavigationLink(destination: CheckoutView(products: productsToOrder)) {
                            Text("주문하기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .background(Color.white)
                }
            }
            .navigationTitle("장바구니")
            .onAppear {
                cartManager.fetchCart()
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.badge.minus")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.4))
            Text("장바구니가 비었습니다.")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}
