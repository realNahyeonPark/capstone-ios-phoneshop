/* /* CheckoutView.swift - 피드백 반영 UI */
 import SwiftUI

 struct CheckoutView: View {
     @Environment(\.dismiss) var dismiss
     let products: [Product]
     
     // State management for coupon
     @State private var selectedCoupon: CouponItem?
     @State private var isShowingCouponSheet = false
     @State private var availableCoupons: [CouponItem] = []
     @State private var isLoadingCoupons = false
     
    
     // Computed pricing properties (assuming integer prices and rates)
     // 1. 총 상품 금액 (정가 합계)
     var originalTotalPrice: Int {
         products.reduce(0) { $0 + $1.price }
     }
     
     // 2. 할인 금액 계산 (총액 * 할인율 / 100)
     var discountAmount: Int {
         guard let coupon = selectedCoupon else { return 0 }
         return (originalTotalPrice * coupon.discountRate) / 100
     }
     
     // 3. 최종 결제 금액
     var finalAmount: Int {
         max(0, originalTotalPrice - discountAmount)
     }

     var body: some View {
         VStack(spacing: 0) {
             // 커스텀 헤더 (뒤로가기 + 타이틀)
             OrderHeaderView(dismiss: dismiss)
             
             ScrollView {
                 VStack(spacing: 20) {
                     
                     // ✅ 1. 배송지 정보 (아래로 길게 세로 패딩 추가)
                     SectionCardView(title: "배송지") {
                         VStack(alignment: .leading, spacing: 10) {
                             Text("홍길동 [우리집]")
                                 .font(.headline)
                             Text("서울시 성북구 화랑로 211 (101동 102호)")
                                 .font(.body)
                                 .foregroundColor(.secondary)
                             Text("010-1234-5678")
                                 .font(.body)
                                 .foregroundColor(.secondary)
                         }
                         .padding(.vertical, 10) // Extra vertical space added here
                     }
                     
                     // ✅ 2. 할인 쿠폰
                     SectionCardView(title: "할인 쿠폰") {
                         Button {
                             isShowingCouponSheet = true
                         } label: {
                             HStack {
                                 if let coupon = selectedCoupon {
                                     // 적용된 쿠폰 이름
                                     HStack(spacing: 8) {
                                         Image(systemName: "tag.fill")
                                             .font(.caption2)
                                         
                                         Text("\(coupon.name) \(coupon.discountRate)%")
                                             .font(.headline)
                                             .fontWeight(.semibold)
                                             .lineLimit(1)
                                     }
                                     .foregroundColor(.white)
                                     .padding(.horizontal, 12)
                                     .padding(.vertical, 10)
                                     .background(Color.blue)
                                     .cornerRadius(20)
                                     
                                 } else {
                                     HStack {
                                         Text("쿠폰을 선택하세요. ")
                                             .font(.body)
                                             .foregroundColor(.gray)
                                     }
                                     .padding(.vertical, 14)
                                 }
                                 
                                 Spacer()
                                 
                                 // 우측 화살표 아이콘 (크기 확대)
                                 Image(systemName: "chevron.right")
                                     .font(.subheadline) // 이전 캡션에서 확대
                                     .foregroundColor(.gray)
                             }
                         }
                     }

                     // 3. 결제 수단 (카카오페이 고정)
                     SectionCardView(title: "결제 수단") {
                         HStack(spacing: 12) {
                             KakaoPayIconView()
                             VStack(alignment: .leading) {
                                 Text("카카오페이").fontWeight(.bold)
                                 Text("간편결제 서비스").font(.caption).foregroundColor(.secondary)
                             }
                             Spacer()
                             Image(systemName: "checkmark.circle.fill")
                                 .foregroundColor(Color(hex: "FEE500"))
                         }
                         .padding()
                         .background(Color.yellow.opacity(0.1))
                         .cornerRadius(12)
                     }
                     
                     // ✅ 4. Detailed Pricing Breakdown (Price - Discount = Final)
                     SectionCardView(title: "결제 상세 내역") {
                         VStack(spacing: 12) {
                             PricingRow(title: "총 상품 금액", amount: "\(originalTotalPrice.formatted())원")
                             if selectedCoupon != nil {
                                 PricingRow(title: "쿠폰 할인 금액", amount: "-\(discountAmount.formatted())원", color: .red)
                             }
                             Divider()
                             HStack {
                                 Text("결제 예정 금액").font(.headline)
                                 Spacer()
                                 Text("\(finalAmount.formatted())원")
                                     .font(.title3)
                                     .fontWeight(.bold)
                                     .foregroundColor(.blue) // 결제 금액 강조
                             }
                         }
                     }
                     Spacer(minLength: 40)
                 }
                 .padding(.horizontal)
                 .padding(.top, 20)
             }
             .background(Color(.systemGray6))
             
             // ✅ 5. 하단 고정 결제 버튼 (파란색, "결제하기" 텍스트)
             VStack {
                 Divider()
                 Button {
                     // 1. 데이터 준비
                         let userId = UserDefaults.standard.integer(forKey: "userId") // 저장된 userId 가져오기
                         
                         // 2. 상품 리스트 변환 (현재 products 배열을 OrderItemRequest로 매핑)
                         // 예시처럼 같은 phoneId를 묶어서 수량을 계산하거나, 단순 나열할 수 있습니다.
                         let items = products.map { OrderItemRequest(phoneId: $0.id, quantity: 1) }
                         
                         let request = KakaoPayRequest(
                             userId: userId,
                             items: items,
                             userCouponId: selectedCoupon?.id // 선택된 쿠폰이 있다면 id 전달
                         )

                         // 3. 서버 호출
                         PaymentService.shared.readyKakaoPay(request: request) { redirectURL in
                             if let urlString = redirectURL, let url = URL(string: urlString) {
                                 DispatchQueue.main.async {
                                     // 4. 받아온 URL로 브라우저 열기 (QR 결제 창)
                                     UIApplication.shared.open(url)
                                 }
                             }
                         }
                 } label: {
                     Text("결제하기")
                         .font(.headline)
                         .foregroundColor(.white)
                         .frame(maxWidth: .infinity)
                         .frame(height: 55)
                         .background(Color.blue) // Changed color to blue
                         .cornerRadius(10)
                         .padding()
                 }
             }
             .background(Color.white)
         }
         // 뒤로가기 버튼이 중복되는 현상 제거
         .navigationBarBackButtonHidden(true)
         .navigationBarHidden(true)
         .edgesIgnoringSafeArea(.bottom) // forSticky effect
         .sheet(isPresented: $isShowingCouponSheet) {
             CouponSelectionSheet(selectedCoupon: $selectedCoupon, availableCoupons: availableCoupons, isLoading: isLoadingCoupons, onAppearAction: loadCoupons)
         }
     }

     private func loadCoupons() {
         isLoadingCoupons = true
         CouponService.shared.fetchUserCoupons { fetchedCoupons in
             self.availableCoupons = fetchedCoupons ?? []
             self.isLoadingCoupons = false
         }
     }
 }

 // --- Component Views (Support Components) ---

 struct OrderHeaderView: View {
     let dismiss: DismissAction
     var body: some View {
         HStack {
             Button {
                 dismiss()
             } label: {
                 Image(systemName: "chevron.left")
                     .font(.title3)
                     .foregroundColor(.primary)
                     .padding(10)
                     .background(Circle().fill(Color.white))
             }
             Spacer()
             Text("주문/결제")
                 .font(.headline)
                 .fontWeight(.bold)
             Spacer()
             // Placeholder for right item
             Color.clear.frame(width: 44, height: 44)
         }
         .padding(.horizontal)
         .padding(.vertical, 12)
         .background(Color(.systemGray6))
     }
 }

 // 공통 카드 스타일 디자인
 struct SectionCardView<Content: View>: View {
     let title: String
     let content: Content
     
     init(title: String, @ViewBuilder content: () -> Content) {
         self.title = title
         self.content = content()
     }
     
     var body: some View {
         VStack(alignment: .leading, spacing: 15) {
             Text(title)
                 .font(.subheadline)
                 .fontWeight(.bold)
                 .foregroundColor(.secondary)
             content
         }
         .padding()
         .frame(maxWidth: .infinity, alignment: .leading)
         .background(Color.white)
         .cornerRadius(12)
     }
 }

 struct KakaoPayIconView: View {
     var body: some View {
         RoundedRectangle(cornerRadius: 6)
             .fill(Color(hex: "FEE500"))
             .frame(width: 40, height: 40)
             .overlay(Text("P").fontWeight(.black).font(.system(size: 20)))
     }
 }

 struct PricingRow: View {
     let title: String
     let amount: String
     var color: Color = .primary
     
     var body: some View {
         HStack {
             Text(title)
                 .foregroundColor(.secondary)
             Spacer()
             Text(amount)
                 .foregroundColor(color)
         }
     }
 }

 // Separate Sheet View for coupon selection
 struct CouponSelectionSheet: View {
     @Binding var selectedCoupon: CouponItem?
     let availableCoupons: [CouponItem]
     let isLoading: Bool
     let onAppearAction: () -> Void
     @Environment(\.dismiss) var dismiss

     var body: some View {
         NavigationStack {
             List {
                 if isLoading {
                     ProgressView().padding()
                 } else if availableCoupons.isEmpty {
                     Text("사용 가능한 쿠폰이 없습니다.").foregroundColor(.secondary)
                 } else {
                     ForEach(availableCoupons) { coupon in
                         Button {
                             selectedCoupon = coupon
                             dismiss()
                         } label: {
                             HStack {
                                 VStack(alignment: .leading) {
                                     Text(coupon.name).font(.headline)
                                     Text("\(coupon.discountRate)% 할인").font(.subheadline).foregroundColor(.red)
                                 }
                                 Spacer()
                                 if selectedCoupon?.id == coupon.id {
                                     Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                                 }
                             }
                         }
                     }
                 }
             }
             .navigationTitle("쿠폰 선택")
             .toolbar {
                 Button("닫기") { dismiss() }
             }
             .onAppear(perform: onAppearAction)
         }
     }
 }

 // Extension to handle Hex colors
 extension Color {
     init(hex: String) {
         let scanner = Scanner(string: hex)
         scanner.currentIndex = scanner.string.startIndex
         var rgbValue: UInt64 = 0
         scanner.scanHexInt64(&rgbValue)
         let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
         let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
         let b = Double(rgbValue & 0x0000FF) / 255.0
         self.init(red: r, green: g, blue: b)
     }
 }

 */

