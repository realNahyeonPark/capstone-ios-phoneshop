import SwiftUI

struct SearchView: View {
    let products: [Product]
    let averageRatings: [AverageRating]
    
    @State private var searchText = ""
    @State private var isSubmitted = false
    @AppStorage("recentSearches") private var recentSearchesData: String = ""
    
    @Environment(\.dismiss) var dismiss

    var recentSearches: [String] {
        recentSearchesData.split(separator: "|").map(String.init)
    }

    var dynamicRecommendations: [String] {
        let allNames = products.map { $0.name }
        let uniqueNames = Array(Set(allNames))
        return Array(uniqueNames.sorted().prefix(10))
    }
    
    var suggestedKeywords: [String] {
        let filtered = products.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.brand.localizedCaseInsensitiveContains(searchText)
        }
        return Array(Set(filtered.map { $0.name })).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .bold))
                }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .bold))
                    
                    TextField("상품명을 입력하세요", text: $searchText)
                        .font(.system(size: 15))
                        .submitLabel(.search)
                        .onSubmit { performSearch(searchText) }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 1.5)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)

            Divider()

            if !isSubmitted {
                if searchText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                            renderRecentSearches
                            renderRecommendationsSection
                        }
                        .padding(.top, 15)
                    }
                } else {
                    renderSuggestedList
                }
            } else {
                SearchResultView(query: searchText, allProducts: products, averageRatings: averageRatings)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
    
    private var renderRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("추천 검색어")
                .font(.system(size: 17, weight: .bold))
                .padding(.horizontal)
            
            if dynamicRecommendations.isEmpty {
                Text("추천할 상품이 없습니다.")
                    .font(.subheadline).foregroundColor(.secondary).padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dynamicRecommendations, id: \.self) { keyword in
                            Button(action: { performSearch(keyword) }) {
                                Text(keyword)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .foregroundColor(.primary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var renderRecentSearches: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("최근 검색어")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                Button("전체 삭제") { recentSearchesData = "" }
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            if recentSearches.isEmpty {
                Text("최근 검색 기록이 없습니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recentSearches, id: \.self) { keyword in
                            HStack(spacing: 5) {
                                Button(keyword) { performSearch(keyword) }
                                    .foregroundColor(.primary)
                                    .font(.system(size: 14))
                                
                                Button(action: {
                                    var current = recentSearches
                                    current.removeAll { $0 == keyword }
                                    recentSearchesData = current.joined(separator: "|")
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var renderSuggestedList: some View {
        List(suggestedKeywords, id: \.self) { keyword in
            Button(action: { performSearch(keyword) }) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    Text(keyword).foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.left").font(.caption).foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            }
            .listRowBackground(Color.white)
        }
        .listStyle(.plain)
    }

    func performSearch(_ keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        self.searchText = trimmed
        self.isSubmitted = true
        
        var current = recentSearches
        if let index = current.firstIndex(of: trimmed) { current.remove(at: index) }
        current.insert(trimmed, at: 0)
        recentSearchesData = Array(current.prefix(10)).joined(separator: "|")
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
