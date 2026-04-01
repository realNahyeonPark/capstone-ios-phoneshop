/* WithdrawView.swift */
import SwiftUI

struct WithdrawView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isLoggedIn: Bool
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let service = UserService()

    var body: some View {
        VStack(spacing: 30) {
            Spacer().frame(height: 100)
            
            Text("회원 탈퇴")
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, 10)

            VStack(spacing: 12) {
                CustomTextField(placeholder: "이름", text: $name)
                CustomTextField(placeholder: "이메일", text: $email, isSecure: false)
                CustomTextField(placeholder: "비밀번호", text: $password, isSecure: true)
            }
            .padding(.horizontal, 30)

            Button(action: handleWithdraw) {
                Text("본인 확인 및 탈퇴하기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormInvalid ? Color.gray.opacity(0.4) : Color.red)
                    .cornerRadius(12)
            }
            .disabled(isFormInvalid)
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(false)
        .alert("알림", isPresented: $showAlert) {
            Button("확인") {
                if alertMessage == "탈퇴가 완료되었습니다." {
                    isLoggedIn = false
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    var isFormInvalid: Bool {
        name.isEmpty || email.isEmpty || password.isEmpty
    }

    func handleWithdraw() {
        let request = WithdrawRequest(name: name, email: email, password: password)
        service.withdrawUser(requestData: request) { success in
            DispatchQueue.main.async {
                if success {
                    alertMessage = "탈퇴가 완료되었습니다."
                } else {
                    alertMessage = "정보가 일치하지 않거나 서버 오류가 발생했습니다."
                }
                showAlert = true
            }
        }
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .autocapitalization(.none)
    }
}

#Preview{
    WithdrawView(isLoggedIn: .constant(true))
}
