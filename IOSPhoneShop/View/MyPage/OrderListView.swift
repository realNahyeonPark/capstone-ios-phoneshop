/* OrderListView.swift */
import SwiftUI

struct OrderListView: View {
    @State private var orders: [OrderHistoryResponse] = []
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            List {
                if orders.isEmpty && !isLoading {
                    emptyStateView
                } else {
                    ForEach(orders) { order in
                        OrderRowView(order: order)
                            .padding(.vertical, 4)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            
            if isLoading {
                ProgressView("주문 내역을 불러오는 중...")
            }
        }
        .navigationTitle("주문 목록")
        .onAppear {
            fetchOrders()
        }
    }
    
    private func fetchOrders() {
        isLoading = true
        OrderService.shared.fetchOrderHistory { fetchedOrders in
            DispatchQueue.main.async {
                isLoading = false
                if let fetchedOrders = fetchedOrders {
                    self.orders = fetchedOrders
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bag.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("주문 내역이 없습니다.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }
}

struct OrderRowView: View {
    let order: OrderHistoryResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(order.paidAt.prefix(10))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(order.status == "PAID" ? "결제완료" : order.status)
                    .font(.caption)
                    .foregroundColor(order.status == "PAID" ? .blue : .gray)
            }
            
            ForEach(order.items) { item in
                HStack(spacing: 15) {
                    if let imageUrlString = item.imageUrl, let imageUrl = URL(string: imageUrlString) {
                            AsyncImage(url: imageUrl) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 55, height: 55)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 55, height: 55)
                                        .cornerRadius(8)
                                case .failure:
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 55, height: 55)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 55, height: 55)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.phoneName)
                            .font(.system(size: 16, weight: .medium))
                            .lineLimit(1)
                        Text("\(item.unitPrice.formatted())원 · \(item.quantity)개")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                Text("총 결제금액")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(order.finalPrice.formatted())원")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}
