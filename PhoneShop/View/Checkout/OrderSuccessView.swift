import SwiftUI

struct OrderSuccessView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                VStack(spacing: 10) {
                    Text("주문이 완료되었습니다!")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("결제가 정상적으로 처리되었습니다.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            
            Spacer()
            
            Button {
                navManager.forceGoToHome()
            } label: {
                Text("메인화면으로 돌아가기")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
    }
    
    private func goToMain() {
        NotificationCenter.default.post(name: NSNotification.Name("popToRoot"), object: nil)
    }
}
