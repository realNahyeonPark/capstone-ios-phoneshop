import SwiftUI

enum SortOption: String, CaseIterable {
    case accuracy = "추천순"
    case priceLow = "낮은가격순"
    case priceHigh = "높은가격순"
    case review = "리뷰많은순"
    case rating = "별점높은순"
    case alphabet = "가나다순"
}

struct SearchResultView: View {
    let query: String
    let allProducts: [Product]
    let averageRatings: [AverageRating]

    @State private var isShowingFilter = false
    @State private var filterConfig = FilterConfig()
    @State private var selectedSort: SortOption = .accuracy
    
    private var statsDict: [Int64: Double] {
        Dictionary(uniqueKeysWithValues: averageRatings.map { ($0.phoneId, $0.averageRating) })
    }

    var finalResults: [Product] {
        let filtered = allProducts.filter { p in
            (query.isEmpty || p.name.localizedCaseInsensitiveContains(query)) &&
            (filterConfig.selectedBrands.isEmpty || filterConfig.selectedBrands.contains(p.brand)) &&
            (Double(p.price) >= filterConfig.minPrice && Double(p.price) <= filterConfig.maxPrice)
        }
        
        switch selectedSort {
        case .priceLow:  return filtered.sorted { $0.price < $1.price }
        case .priceHigh: return filtered.sorted { $0.price > $1.price }
        case .rating:    return filtered.sorted { statsDict[Int64($0.id)] ?? 0 > statsDict[Int64($1.id)] ?? 0 }
        case .alphabet:  return filtered.sorted { $0.name < $1.name }
        default: return filtered
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Divider()
            
            if finalResults.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                productItems
            }
        }
        .background(Color.white)
        .sheet(isPresented: $isShowingFilter) {
            FilterModalView(config: $filterConfig, allProducts: allProducts, query: query)
        }
    }
}

private extension SearchResultView {
    var headerSection: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SortOption.allCases, id: \.self) { opt in
                        Button(opt.rawValue) { selectedSort = opt }
                            .modifier(SortButtonModifier(isSelected: selectedSort == opt))
                    }
                }.padding(.horizontal, 16)
            }
            Divider().frame(height: 20).padding(.horizontal, 8)
            Button { isShowingFilter = true } label: {
                Label("필터", systemImage: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(.black)
            }.padding(.trailing, 16)
        }.padding(.vertical, 12)
    }

    var productItems: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(finalResults, id: \.id) { p in
                    NavigationLink(destination: ProductDetailView(product: p)) {
                        ProductRowView(product: p)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 150)
                }
            }
        }
    }
}

struct ProductRowView: View {
    let product: Product
    
    @State private var rating: Double = 0.0
    @State private var totalReviewCount: Int = 0
    private let reviewService = ReviewService()
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: product.fullImageUrl) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(.systemGray6)
            }
            .frame(width: 130, height: 130)
            .cornerRadius(8)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(product.brand).font(.system(size: 13)).foregroundColor(.secondary)
                Text(product.name).font(.system(size: 20, weight: .bold)).lineLimit(2)
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill").foregroundColor(.orange).font(.system(size: 11))
                    Text(String(format: "%.1f", rating)).font(.system(size: 12, weight: .bold))
                    Text("(\(totalReviewCount.formatted()))").font(.system(size: 12)).foregroundColor(.secondary)
                }
                
                Spacer(minLength: 12)
                
                Text(product.formattedPrice).font(.system(size: 18, weight: .bold))
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
        .padding(20)
        .task {
            if let stats = await reviewService.fetchAverageRating(phoneId: String(product.id)) {
                self.rating = stats.averageRating
                self.totalReviewCount = stats.totalReviewCount ?? 0
            }
        }
    }
}

struct SortButtonModifier: ViewModifier {
    let isSelected: Bool
    func body(content: Content) -> some View {
        content
            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(isSelected ? .black : .white)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(isSelected ? .black : Color(.systemGray4), lineWidth: 1))
    }
}
