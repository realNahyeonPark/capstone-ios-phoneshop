/* CouponView.swift */
import SwiftUI

struct CouponView: View {
    @State private var coupons: [CouponItem] = []
    @State private var couponCode: String = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    if isLoading {
                        ProgressView().padding(.top, 50)
                    } else if coupons.isEmpty {
                    } else {
                        ForEach(coupons) { coupon in
                            CouponRow(coupon: coupon)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .background(Color(hex: "F0F2F5"))
        }
        .navigationTitle("쿠폰 · 이용권")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadCoupons)
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
