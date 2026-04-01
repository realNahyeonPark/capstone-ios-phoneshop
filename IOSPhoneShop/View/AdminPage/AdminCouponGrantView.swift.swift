/* AdminCouponGrantView */
import SwiftUI
import Foundation

struct AdminCouponGrantView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var couponName: String = ""
    @State private var discountAmount: String = ""
    @State private var isGranting: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("쿠폰 정보")) {
                TextField("쿠폰 이름", text: $couponName)
                TextField("할인율", text: $discountAmount)
                    .keyboardType(.numberPad)
            }
            
            Section {
                Button(action: grantCoupon) {
                    if isGranting {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("쿠폰 발급하기")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(couponName.isEmpty || discountAmount.isEmpty || isGranting)
                .foregroundColor(.white)
                .listRowBackground(couponName.isEmpty || discountAmount.isEmpty ? Color.gray : Color.blue)
            }
        }
        .navigationTitle("쿠폰 발급")
        .alert("알림", isPresented: $showAlert) {
            Button("확인") { if alertMessage == "쿠폰이 발급되었습니다. " { dismiss() } }
        } message: {
            Text(alertMessage)
        }
    }
    
    func grantCoupon() {
        guard let rate = Int(discountAmount) else {
            alertMessage = "할인율은 숫자만 입력 가능합니다."
            showAlert = true
            return
        }
        
        isGranting = true
        
        CouponService.shared.createCoupon(name: couponName, discountRate: rate) { success in
            DispatchQueue.main.async {
                isGranting = false
                if success {
                    alertMessage = "쿠폰이 발급되었습니다."
                    showAlert = true
                } else {
                    alertMessage = "쿠폰 발급에 실패했습니다. 관리자 권한을 확인하세요."
                    showAlert = true
                }
            }
        }
    }
}
