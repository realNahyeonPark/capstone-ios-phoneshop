import SwiftUI

struct ReviewWriteView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var rating: Double = 5.0
    @State private var reviewText = ""
    @State private var isSubmitting = false
    
    let phoneId: Int64
    let productName: String
    let service = ReviewService()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("상품은 어떠셨나요?")) {
                    HStack {
                        Spacer()
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: Double(index) <= rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.title)
                                .onTapGesture {
                                    rating = Double(index)
                                }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("상세 리뷰")) {
                    TextEditor(text: $reviewText)
                        .frame(height: 150)
                        .overlay(
                            Group {
                                if reviewText.isEmpty {
                                    Text("제품의 장단점을 들려주세요!")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 5)
                                        .padding(.top, 8)
                                }
                            }, alignment: .topLeading
                        )
                }
            }
            .navigationTitle("\(productName) 리뷰 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSubmitting ? "전송 중..." : "등록") {
                        submitReview()
                    }
                    .disabled(reviewText.isEmpty || isSubmitting)
                }
            }
        }
    }

    private func submitReview() {
        isSubmitting = true
        
        Task {
            let success = await service.createReview(
                phoneId: phoneId,
                rating: rating,
                content: reviewText
            )
            
            await MainActor.run {
                isSubmitting = false
                if success {
                    dismiss()
                }
            }
        }
    }
}
