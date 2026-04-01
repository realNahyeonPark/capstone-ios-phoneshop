/* QnaEditView.swift */

import SwiftUI

struct QnaEditView: View {
    @Environment(\.dismiss) var dismiss
    let commentId: Int
    @State private var content: String
    
    init(commentId: Int, initialContent: String) {
        self.commentId = commentId
        _content = State(initialValue: initialContent)
    }
    
    var body: some View {
        Form {
            Section(header: Text("문의 내용 수정")) {
                TextEditor(text: $content)
                    .frame(height: 150)
            }
        }
        .navigationTitle("수정하기")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    CommentService.shared.updateComment(commentId: commentId, content: content) { success in
                        if success { dismiss() }
                    }
                }
                .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
