import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModels()
    @EnvironmentObject var navManager: NavigationManager
    
    let averageRatings: [AverageRating]
    let horizontalPadding: CGFloat = 16
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack(path: $navManager.path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    searchBarSection
                    
                    BannerView()
                        .frame(height: 200)
                        .padding(.bottom, 12)

                    VStack(alignment: .leading, spacing: 8) {
                        filterHeaderSection
                        productGridSection
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationDestination(for: String.self) { value in
                if value == "search" { SearchView(products: viewModel.products, averageRatings: averageRatings) }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { logoToolbarItem }
            .background(Color.white.ignoresSafeArea())
        }
        .onAppear { viewModel.loadProducts() }
    }

    private var searchBarSection: some View {
        NavigationLink(value: "search") {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .semibold))
                Text("Alpha Pro")
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 1.5))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    private var filterHeaderSection: some View {
        HStack(alignment: .center) {
            Text("추천 상품")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 10) {
                brandMenu
                sortMenu
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, 4)
    }

    private var brandMenu: some View {
        Menu {
            ForEach(viewModel.brands, id: \.self) { brand in
                Button {
                    updateViewModel { viewModel.selectedBrand = brand }
                } label: {
                    HStack {
                        Text(brand)
                        if viewModel.selectedBrand == brand { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.selectedBrand)
                Image(systemName: "chevron.down")
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color.gray.opacity(0.1)).cornerRadius(8)
            .foregroundColor(.black)
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(MainViewModels.SortOption.allCases, id: \.self) { option in
                Button {
                    updateViewModel { viewModel.sortOption = option }
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if viewModel.sortOption == option { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 13, weight: .medium))
                .padding(6).background(Color.gray.opacity(0.1)).cornerRadius(8)
                .foregroundColor(.black)
        }
    }

    private var productGridSection: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewModel.filteredProducts) { product in
                NavigationLink(value: product) {
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

    private var logoToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("한성전자")
                .font(.system(size: 26, weight: .black))
                .padding(.leading)
        }
    }

    private func updateViewModel(action: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}
