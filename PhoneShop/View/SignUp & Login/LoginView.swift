import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") var isLoggedInStorage: Bool = false
    
    @Binding var isLoggedIn: Bool
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var showSheet: Bool
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                VStack(spacing: 30) {
                    Text("한성전자")
                        .font(.system(size: 40, weight: .bold))
                    
                    VStack(spacing: 12) {
                        TextField("이메일", text: $email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .autocapitalization(.none)
                        
                        SecureField("비밀번호", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    VStack(spacing: 20) {
                        Button(action: loginUser) {
                            Text("로그인")
                                .font(.headline).foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        
                        HStack {
                            NavigationLink("회원가입", destination: SignUpView())
                            Spacer()
                            NavigationLink("비밀번호 찾기", destination: ResetPasswordView())
                        }
                        .font(.footnote)
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 30)
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSheet = false
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("뒤로")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .alert("로그인", isPresented: $showAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func loginUser() {
        let loginData = LoginRequest(email: email, password: password)
        
        UserService.shared.login(loginData: loginData) { token in
            if token != nil {
                Task {
                    await UserService.shared.fetchAndSaveUserInfo()
                    DispatchQueue.main.async {
                        self.isLoggedInStorage = true
                        self.isLoggedIn = true
                        self.showSheet = false
                    }
                }
            } else {
                self.alertMessage = "로그인 정보가 올바르지 않습니다."
                self.showAlert = true
            }
        }
    }
}
