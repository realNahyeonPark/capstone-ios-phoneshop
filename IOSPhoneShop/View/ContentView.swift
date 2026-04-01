/* ContentView.swift */
import SwiftUI

struct ContentView: View {
    let averageRatings: [AverageRating]
    
    @State private var isLoggedIn = false
    @State private var userName: String = ""
    @State private var userEmail: String = ""

    var body: some View {
        if isLoggedIn {
            MainTabView(averageRatings: averageRatings, isLoggedIn: $isLoggedIn, userName: $userName, userEmail: $userEmail).environmentObject(CartManager())
        } else {
            LoginView(isLoggedIn: $isLoggedIn, userName: $userName, userEmail: $userEmail)
        }
    }
}
