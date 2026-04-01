/* QnaWriteView.swift */
import SwiftUI

struct QnaWriteView: View {
    @Environment(\.dismiss) var dismiss
    let phoneId: Int
    @State private var content: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("문의 내용")) {
                TextEditor(text: $content)
                    .frame(height: 150)
            }
        }
        .navigationTitle("문의하기")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("등록") {
                    CommentService.shared.createComment(phoneId: phoneId, content: content) { success in
                        if success { dismiss() }
                    }
                }
                .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
