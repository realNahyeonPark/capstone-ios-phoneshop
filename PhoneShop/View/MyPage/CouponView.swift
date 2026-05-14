import SwiftUI

struct CouponView: View {
    @State private var coupons: [CouponItem] = []
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color(hex: "F0F2F5").ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            } else if coupons.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(coupons) { coupon in
                            CouponRow(coupon: coupon)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .navigationTitle("쿠폰 · 이용권")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadCoupons)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 150)
            Image(systemName: "ticket.fill")
                .font(.system(size: 70))
                .foregroundStyle(.gray.opacity(0.2))
            Text("보유중인 쿠폰이 없습니다.")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    func loadCoupons() {
        isLoading = true
        CouponService.shared.fetchUserCoupons { fetched in
            DispatchQueue.main.async {
                self.coupons = fetched ?? []
                self.isLoading = false
            }
        }
    }
}
