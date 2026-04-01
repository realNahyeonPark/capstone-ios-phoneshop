/* AdminProductManagementView.swift */
import SwiftUI

struct AdminProductManagementView: View {
    @State private var products: [Product] = []
    @State private var isLoading: Bool = false
    @State private var showAddView: Bool = false
    
    @State private var showDeleteAlert = false
    @State private var productToDelete: Product?

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(products, id: \.id) { product in
                        HStack(spacing: 15) {
                            AsyncImage(url: URL(string: product.imageUrl)) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 90, height: 90)
                            .clipped()
                            .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(product.brand)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(product.price)원")
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 5)
                            
                            Spacer()

                            Button(action: {
                                productToDelete = product
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(12)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("상품 관리")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddView = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear(perform: loadProducts)
        .sheet(isPresented: $showAddView, onDismiss: loadProducts) {
            NavigationStack { AdminProductAddView() }
        }
        .alert("상품 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                if let product = productToDelete { confirmDelete(product: product) }
            }
        } message: {
            Text("'\(productToDelete?.name ?? "")'을(를) 삭제하시겠습니까?")
        }
        .overlay { if isLoading { ProgressView() } }
    }

    func loadProducts() {
        isLoading = true
        ProductService.shared.fetchAllPhones { fetchedProducts in
            self.products = fetchedProducts ?? []
            self.isLoading = false
        }
    }

    func confirmDelete(product: Product) {
        ProductService.shared.deleteProduct(id: product.id) { success in
            if success {
                withAnimation { products.removeAll { $0.id == product.id } }
            }
        }
    }
}
