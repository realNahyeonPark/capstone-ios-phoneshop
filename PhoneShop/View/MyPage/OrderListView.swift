import SwiftUI

struct OrderListView: View {
    @State private var orders: [OrderHistoryResponse] = []
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).opacity(0.5).ignoresSafeArea()
            
            if orders.isEmpty && !isLoading {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(orders) { order in
                            OrderRowView(order: order)
                        }
                    }
                    .padding(.top, 8)
                }
                .refreshable {
                    await fetchOrdersAsync()
                }
            }
            
            if isLoading {
                ProgressView("주문 내역을 불러오는 중...")
            }
        }
        .navigationTitle("주문 목록")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchOrders()
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("reloadOrders"))) { _ in
            fetchOrders()
        }
    }
    
    private func fetchOrders() {
        isLoading = true
        OrderService.shared.fetchOrderHistory { fetchedOrders in
            isLoading = false
            if let fetchedOrders = fetchedOrders {
                self.orders = fetchedOrders
            }
        }
    }
    
    private func fetchOrdersAsync() async {
        return await withCheckedContinuation { continuation in
            OrderService.shared.fetchOrderHistory { fetchedOrders in
                if let fetchedOrders = fetchedOrders {
                    self.orders = fetchedOrders
                }
                continuation.resume()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bag").font(.system(size: 60)).foregroundStyle(.gray.opacity(0.3))
            Text("주문 내역이 없습니다.").font(.system(size: 16)).foregroundColor(.secondary)
            Spacer()
        }.frame(maxWidth: .infinity)
    }
}
struct OrderRowView: View {
    let order: OrderHistoryResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(order.formattedPaidDate)
                    .font(.system(size: 15, weight: .bold))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            Divider().padding(.horizontal, 16)
            
            ForEach(order.items) { item in
                HStack(alignment: .top, spacing: 12) {
                    if let imageUrl = item.fullImageURL {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                Rectangle().fill(Color.gray.opacity(0.1))
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fit)
                            case .failure:
                                Image(systemName: "photo").foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.05), lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.phoneName)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text("\(item.unitPrice.formatted())원 · \(item.quantity)개")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            
            Divider().padding(.horizontal, 16)
            
            HStack {
                Text("총 결제금액")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(order.finalPrice.formatted())원")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .overlay(
            Rectangle()
                .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
        )
    }
}

