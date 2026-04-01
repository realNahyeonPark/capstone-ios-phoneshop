/* CouponSelectionSheet.swift */
import SwiftUI

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
            .toolbar { Button("닫기") { dismiss() } }
            .onAppear(perform: onAppearAction)
        }
    }
}
