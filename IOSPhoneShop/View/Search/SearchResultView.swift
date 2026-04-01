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

    var finalResults: [Product] {
        let filtered = allProducts.filter { product in
            let matchesQuery = query.isEmpty || product.name.localizedCaseInsensitiveContains(query)
            let matchesBrand = filterConfig.selectedBrands.isEmpty || filterConfig.selectedBrands.contains(product.brand)
            let productPrice = Double(product.price)
            let matchesPrice = productPrice >= filterConfig.minPrice && productPrice <= filterConfig.maxPrice
            return matchesQuery && matchesBrand && matchesPrice
        }
        
        switch selectedSort {
        case .accuracy:  return filtered
        case .priceLow:  return filtered.sorted { $0.price < $1.price }
        case .priceHigh: return filtered.sorted { $0.price > $1.price }
        case .rating:
            return filtered.sorted { p1, p2 in
                let r1 = averageRatings.first(where: { $0.phoneId == Int64(p1.id) })?.averageRating ?? 0.0
                let r2 = averageRatings.first(where: { $0.phoneId == Int64(p2.id) })?.averageRating ?? 0.0
                return r1 > r2
            }
        default: return filtered
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button { selectedSort = option } label: {
                                Text(option.rawValue)
                                    .font(.system(size: 13, weight: selectedSort == option ? .bold : .medium))
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(selectedSort == option ? Color.black : Color.white)
                                    .foregroundColor(selectedSort == option ? .white : .primary)
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(selectedSort == option ? Color.black : Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Divider().frame(height: 20).padding(.horizontal, 8)
                
                Button { isShowingFilter = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text("필터")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.trailing, 16)
                }
            }
            .padding(.vertical, 12)
            .background(Color.white)

            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)

            if finalResults.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(finalResults) { product in
                            let ratingData = averageRatings.first(where: { $0.phoneId == Int64(product.id) })
                            
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductRowView(
                                    product: product,
                                    rating: ratingData?.averageRating ?? 0.0,
                                    reviewCount: Int.random(in: 10...500)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.leading, 150)
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .sheet(isPresented: $isShowingFilter) {
            FilterModalView(config: $filterConfig, allProducts: allProducts, query: query)
        }
    }
}

struct ProductRowView: View {
    let product: Product
    let rating: Double
    let reviewCount: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: product.fullImageUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color(.systemGray6))
            }
            .frame(width: 130, height: 130)
            .cornerRadius(8)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(product.brand)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Text(product.name)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 11))
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 12, weight: .bold))
                    Text("(\(reviewCount))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 12)
                
                HStack(alignment: .bottom, spacing: 1) {
                    Text(product.formattedPrice)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    Text("원")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.bottom, 2)
                }
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(Color.white)
    }
}
