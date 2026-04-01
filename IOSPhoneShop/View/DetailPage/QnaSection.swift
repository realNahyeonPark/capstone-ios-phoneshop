/* QnaSection.swift */
import SwiftUI

struct QnaSection: View {
    let phoneId: Int
    @State private var recentComments: [CommentResponse] = []
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("상품 문의 (Q&A)").font(.headline)
                Spacer()
                NavigationLink(destination: ProductQnaListView(phoneId: phoneId)) {
                                    HStack(spacing: 3) {
                                        Text("전체보기")
                                        Image(systemName: "chevron.right")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
            }
            .padding(.horizontal)
            
            if isLoading {
                ProgressView().frame(maxWidth: .infinity).padding()
            } else if recentComments.isEmpty {
                Text("등록된 문의사항이 없습니다.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 0) {
                    ForEach(recentComments.prefix(3), id: \.commentId) { comment in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(comment.userName)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            Text(comment.content)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .padding()
                        
                        if comment.commentId != recentComments.prefix(3).last?.commentId {
                            Divider().padding(.horizontal)
                        }
                    }
                }
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .onAppear(perform: loadRecentQna)
    }
    
    func loadRecentQna() {
        isLoading = true
        CommentService.shared.fetchComments(phoneId: phoneId) { fetched in
            self.recentComments = fetched ?? []
            self.isLoading = false
        }
    }
}

struct BottomActionBar: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    
    @State private var isShowingCheckout = false
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 15) {
                Button(action: { cartManager.addToCart(phoneId: product.id) }) {
                    Image(systemName: "cart").font(.title2).foregroundColor(.blue)
                        .padding().background(Color.blue.opacity(0.1)).cornerRadius(12)
                }
                
                Button(action: { isShowingCheckout = true }) {
                    Text("구매하기").font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(12)
                }
            }
            .padding(20).padding(.bottom, 10)
        }
        .background(Color.white)
        .navigationDestination(isPresented: $isShowingCheckout) {
            CheckoutView(products: [product])
        }
    }
}
