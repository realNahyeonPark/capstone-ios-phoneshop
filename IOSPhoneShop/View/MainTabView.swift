/* MainTabView.swift */
import SwiftUI

struct MainTabView: View {
    let averageRatings: [AverageRating]
    @Binding var isLoggedIn: Bool
    @Binding var userName: String
    @Binding var userEmail: String
    
    @StateObject private var viewModel = MainViewModels()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MainView(averageRatings: averageRatings)
            }
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                SearchView(products: viewModel.products, averageRatings: averageRatings)
            }
            .tabItem {
                Label("검색", systemImage: "magnifyingglass")
            }
            .tag(1)

            NavigationStack {
                MyPageView(isLoggedIn: $isLoggedIn)
            }
            .tabItem {
                Label("마이", systemImage: "person.fill")
            }
            .tag(2)
            
            NavigationStack{
                CartView()
            }.tabItem{
                Label("장바구니", systemImage: "cart.fill")
            }.tag(3)
        }
        .onAppear {
            viewModel.loadProducts()
        }
    }
}
