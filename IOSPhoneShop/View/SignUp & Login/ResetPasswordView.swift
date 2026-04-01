/* ResetPasswordView.swift */
import SwiftUI

struct ResetPasswordView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var tempPassword = ""
    @State private var showResult = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack {
            Spacer().frame(height: 160)
            
            VStack(spacing: 30) {
                VStack {
                    Text("비밀번호 찾기")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                VStack(spacing: 12) {
                    Group {
                        TextField("이름", text: $name)
                        TextField("이메일", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                VStack(spacing: 20) {
                    Button(action: {
                        if !name.isEmpty && !email.isEmpty {
                            handleResetPassword()
                        } else {
                            alertMessage = "이름과 이메일을 모두 입력해주세요."
                            showAlert = true
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("임시 비밀번호 발급")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isLoading)
                    
                    if showResult {
                        VStack(spacing: 10) {
                            Text("임시 비밀번호가 발급되었습니다.")
                                .foregroundColor(.secondary)
                            Text(tempPassword)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .textSelection(.enabled)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .transition(.opacity)
                    }
                }
            }
            .padding(.horizontal, 30)
            Spacer()
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    func handleResetPassword() {
        isLoading = true
        
        UserService.shared.resetPassword(name: name, email: email) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let newPassword = result {
                    withAnimation {
                        self.tempPassword = newPassword
                        self.showResult = true
                    }
                } else {
                    self.alertMessage = "일치하는 회원 정보가 없거나 서버 오류입니다."
                    self.showAlert = true
                    self.showResult = false
                }
            }
        }
    }
}
