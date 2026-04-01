import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModels()
    
    let averageRatings: [AverageRating]
    let horizontalPadding: CGFloat = 16
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink(destination: SearchView(products: viewModel.products, averageRatings: averageRatings)) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("Galaxy S26 Ultra")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    
                    BannerView()
                        .frame(height: 200)
                        .padding(.bottom, 12)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("추천 상품")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, horizontalPadding)
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(viewModel.products) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
                                    ProductCardView(product: product)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("한성전자")
                        .font(.system(size: 26, weight: .black))
                        .padding(.leading)
                }
            }
            .background(Color.white.ignoresSafeArea())
        }
        .onAppear {
            viewModel.loadProducts()
        }
    }
}
