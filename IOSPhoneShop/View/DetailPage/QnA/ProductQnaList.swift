/* ProductQnaListView.swift */
import SwiftUI

struct ProductQnaListView: View {
    let phoneId: Int
    let currentUserId = UserDefaults.standard.integer(forKey: "userId")
    
    @State private var comments: [CommentResponse] = []
    @State private var isShowingWriteSheet = false
    @State private var editingComment: CommentResponse? = nil
    @State private var showingDeleteAlert = false
    @State private var commentToDelete: Int? = nil
    
    var body: some View {
        List {
            if comments.isEmpty {
                Text("아직 등록된 문의가 없습니다.")
                    .foregroundColor(.secondary).padding()
            } else {
                ForEach(comments, id: \.commentId) { comment in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(comment.userName).font(.subheadline).bold()
                            Spacer()
                            
                            if comment.userId == currentUserId {
                                HStack(spacing: 8) {
                                    Button(action: { editingComment = comment }) {
                                        Text("수정")
                                            .font(.caption).bold()
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 10).padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.1)).cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        self.commentToDelete = comment.commentId
                                        self.showingDeleteAlert = true
                                    }) {
                                        Text("삭제")
                                            .font(.caption).bold()
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 10).padding(.vertical, 5)
                                            .background(Color.red.opacity(0.1)).cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        Text(comment.content).font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("상품 문의")
        .onAppear(perform: loadComments)
        .toolbar {
            Button("문의하기") { isShowingWriteSheet = true }
        }
        .sheet(isPresented: $isShowingWriteSheet, onDismiss: loadComments) {
            NavigationStack { QnaWriteView(phoneId: phoneId) }
        }
        .sheet(item: $editingComment, onDismiss: loadComments) { comment in
            NavigationStack { QnaEditView(commentId: comment.commentId, initialContent: comment.content) }
        }
        .alert("문의 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                if let id = commentToDelete {
                    CommentService.shared.deleteComment(commentId: id) { success in
                        if success { loadComments() }
                    }
                }
            }
        } message: {
            Text("작성하신 문의 내용을 삭제하시겠습니까?")
        }
    }
    
    func loadComments() {
        CommentService.shared.fetchComments(phoneId: phoneId) { fetched in
            self.comments = fetched ?? []
        }
    }
}
