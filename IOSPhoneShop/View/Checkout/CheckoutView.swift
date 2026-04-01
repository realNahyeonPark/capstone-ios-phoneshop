/* CheckoutView.swift */
import SwiftUI

struct PaymentURLItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct CheckoutView: View {
    @Environment(\.dismiss) var dismiss
    let products: [Product]
    
    @State private var selectedCoupon: CouponItem?
    @State private var isShowingCouponSheet = false
    @State private var availableCoupons: [CouponItem] = []
    @State private var isLoadingCoupons = false
    
    @State private var activePaymentItem: PaymentURLItem?
    @State private var isOrderSuccess = false
    
    var originalTotalPrice: Int { products.reduce(0) { $0 + $1.price } }
    var discountAmount: Int {
        guard let coupon = selectedCoupon else { return 0 }
        return (originalTotalPrice * coupon.discountRate) / 100
    }
    var finalAmount: Int { max(0, originalTotalPrice - discountAmount) }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                OrderHeaderView(dismiss: dismiss)
                
                ScrollView {
                    VStack(spacing: 20) {
                        SectionCardView(title: "배송지") {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("홍길동 [우리집]").font(.headline)
                                Text("서울시 성북구 화랑로 211 (101동 102호)").font(.body).foregroundColor(.secondary)
                                Text("010-1234-5678").font(.body).foregroundColor(.secondary)
                            }.padding(.vertical, 10)
                        }
                        
                        SectionCardView(title: "할인 쿠폰") {
                            CouponButton(selectedCoupon: selectedCoupon) { isShowingCouponSheet = true }
                        }
                        
                        SectionCardView(title: "결제 수단") {
                            PaymentMethodRow()
                        }
                        
                        SectionCardView(title: "결제 상세 내역") {
                            PricingBreakdown(originalPrice: originalTotalPrice, discount: discountAmount, finalPrice: finalAmount, hasCoupon: selectedCoupon != nil)
                        }
                        
                        Spacer(minLength: 150)
                    }
                    .padding(.horizontal).padding(.top, 35)
                }
                .background(Color(.systemGray6))
            }
            
            BottomPayButton(amount: finalAmount, action: startPaymentProcess)
                .padding(.bottom, 20)
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $isShowingCouponSheet) {
            CouponSelectionSheet(selectedCoupon: $selectedCoupon, availableCoupons: availableCoupons, isLoading: isLoadingCoupons, onAppearAction: loadCoupons)
        }
        .fullScreenCover(item: $activePaymentItem) { item in
            PaymentWebView(url: item.url, successUrlKeyword: "approve") {
                self.activePaymentItem = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isOrderSuccess = true
                }
            }
        }
        .fullScreenCover(isPresented: $isOrderSuccess) {
            OrderSuccessView()
        }
    }

    private func loadCoupons() {
        isLoadingCoupons = true
        CouponService.shared.fetchUserCoupons { fetchedCoupons in
            DispatchQueue.main.async {
                self.availableCoupons = fetchedCoupons ?? []
                self.isLoadingCoupons = false
            }
        }
    }

    private func startPaymentProcess() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let items = products.map { OrderItemRequest(phoneId: $0.id, quantity: 1) }
        let request = KakaoPayRequest(userId: userId, items: items, userCouponId: selectedCoupon?.id)

        PaymentService.shared.readyKakaoPay(request: request) { redirectURL in
            guard let urlString = redirectURL, let url = URL(string: urlString) else {
                return
            }
            
            DispatchQueue.main.async {
                self.activePaymentItem = PaymentURLItem(url: url)
            }
        }
    }
}

struct CouponButton: View {
    let selectedCoupon: CouponItem?
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                if let coupon = selectedCoupon {
                    Text("\(coupon.name) \(coupon.discountRate)%").font(.headline).padding(10).background(Color.blue).foregroundColor(.white).cornerRadius(20)
                } else {
                    Text("쿠폰을 선택하세요.").foregroundColor(.gray).padding(.vertical, 14)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
        }
    }
}

struct PricingBreakdown: View {
    let originalPrice: Int; let discount: Int; let finalPrice: Int; let hasCoupon: Bool
    var body: some View {
        VStack(spacing: 12) {
            PricingRow(title: "총 상품 금액", amount: "\(originalPrice.formatted())원")
            if hasCoupon { PricingRow(title: "쿠폰 할인 금액", amount: "-\(discount.formatted())원", color: .red) }
            Divider()
            HStack {
                Text("결제 예정 금액").font(.headline)
                Spacer()
                Text("\(finalPrice.formatted())원").font(.title3).fontWeight(.bold).foregroundColor(.blue)
            }
        }
    }
}

struct BottomPayButton: View {
    let amount: Int; let action: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            Button(action: action) {
                Text("\(amount.formatted())원 결제하기").font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 55).background(Color.blue).cornerRadius(12).padding()
                    .padding(.bottom, 40)
            }
        }.background(Color.white)
    }
}

struct PaymentMethodRow: View {
    var body: some View {
        HStack(spacing: 12) {
            KakaoPayIconView()
            VStack(alignment: .leading) {
                Text("카카오페이").fontWeight(.bold)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "FEE500"))
        }.padding().background(Color.yellow.opacity(0.1)).cornerRadius(12)
    }
}
