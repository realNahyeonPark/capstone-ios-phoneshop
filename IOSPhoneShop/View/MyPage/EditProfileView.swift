/* EditProfileView.swift */
import SwiftUI

struct EditProfileView: View {
    @Binding var userName: String
    
    @State private var password: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("이름")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        TextField("이름을 입력해주세요", text: $userName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 0.5)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("비밀번호 확인")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        SecureField("비밀번호를 입력해주세요", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 0.5)
                            )
                    }
                    
                }
                .padding(.horizontal, 20)
            }
            VStack {
                Divider()
                Button(action: saveChanges) {
                    Text("수정완료")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(password.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(password.isEmpty)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
            .background(Color.white)
        }
        .navigationTitle("정보 수정")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
    }
    
    func saveChanges() {
        let updateData = UpdateUserRequest(name: userName, password: password)
        
        UserService.shared.updateUserInfo(updateData: updateData) { success in
            if success {
                dismiss()
            } else {
            }
        }
    }
}
