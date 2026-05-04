import SwiftUI

struct CouponSelectionSheet: View {
    @Binding var selectedCoupon: CouponItem?
    let availableCoupons: [CouponItem]
    let isLoading: Bool
    let onAppearAction: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F0F2F5").ignoresSafeArea()
                
                if isLoading {
                    ProgressView("쿠폰을 불러오는 중...")
                } else if availableCoupons.isEmpty {
                    emptySelectionView
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(availableCoupons) { coupon in
                                Button {
                                    selectedCoupon = coupon
                                    dismiss()
                                } label: {
                                    couponCardView(coupon: coupon)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("쿠폰 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
            .onAppear(perform: onAppearAction)
        }
    }

    @ViewBuilder
    private func couponCardView(coupon: CouponItem) -> some View {
        let isSelected = selectedCoupon?.id == coupon.id
        
        HStack(spacing: 0) {
            VStack {
                Text("\(coupon.discountRate)%")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.red)
                Text("OFF")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.red.opacity(0.7))
            }
            .frame(width: 80, height: 100)
            .background(Color.white)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1)
                .padding(.vertical, 15)
                .background(Color.white)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(coupon.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("주문 금액 할인")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 15)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.3))
                    .padding(.trailing, 15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .frame(height: 100)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var emptySelectionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "ticket")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            Text("사용 가능한 쿠폰이 없습니다.")
                .foregroundColor(.secondary)
        }
    }
}
