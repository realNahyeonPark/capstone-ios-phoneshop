import SwiftUI

@main
struct iOSPhoneShopApp: App {
    @StateObject var favoritesManager = FavoritesManager()
    @StateObject var cartManager = CartManager()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(averageRatings: [])
                .environmentObject(favoritesManager)
                .environmentObject(cartManager)
        }
    }
}
