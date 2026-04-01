/* OrderSuccessView.swift */
import SwiftUI

struct OrderSuccessView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            Text("결제가 완료되었습니다!")
                .font(.title2)
                .fontWeight(.bold)
            
            Button {
                dismiss()
            } label: {
                Text("홈으로 돌아가기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
