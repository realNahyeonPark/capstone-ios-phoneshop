import SwiftUI
import UserNotifications

@main
struct iOSPhoneShopApp: App {
    @StateObject var favoritesManager = FavoritesManager()
    @StateObject var cartService = CartService()
    
    init() {
        requestNotificationPermission()
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(averageRatings: [])
                .environmentObject(favoritesManager)
                .environmentObject(cartService)
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
}
