import SwiftUI

struct ContentView: View {
    let averageRatings: [AverageRating]
    @StateObject private var navManager = NavigationManager()
    
    @AppStorage("userRole") var userRole: String = "USER"
    
    @State private var isLoggedIn = false
    @State private var userName: String = "게스트"
    @State private var userEmail: String = ""

    var body: some View {
        MainTabView(averageRatings: averageRatings,
                    isLoggedIn: $isLoggedIn,
                    userName: $userName,
                    userEmail: $userEmail)
            .environmentObject(CartService())
            .environmentObject(navManager)
            .fullScreenCover(isPresented: .constant(!isLoggedIn && userRole == "GUEST_REQUIRED")) {
            }
    }
}
