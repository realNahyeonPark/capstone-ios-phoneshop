/* SignUpView.swift */
import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let userService = UserService()
    
    var body: some View {
        VStack {
            Spacer().frame(height: 160)
            
            VStack(spacing: 30) {
                VStack {
                    Text("회원가입").font(.system(size: 40, weight: .bold))
                }
                
                VStack(spacing: 12) {
                    Group {
                        TextField("이름", text: $name)
                        TextField("이메일", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("비밀번호", text: $password)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Button(action: {
                            if !name.isEmpty && !email.isEmpty && !password.isEmpty {
                                let signupData = SignupRequest(
                                    email: email,
                                    password: password,
                                    name: name
                                )
                                
                                userService.registerUser(signupData: signupData) { success in
                                    if success {
                                        dismiss()
                                    } else {
                                        alertMessage = "회원가입 실패 (이미 가입된 이메일일 수 있습니다.)"
                                        showAlert = true
                                    }
                                }
                            } else {
                                alertMessage = "모든 정보를 입력해주세요."
                                showAlert = true
                            }
                        }) {
                    Text("가입하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
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
}
