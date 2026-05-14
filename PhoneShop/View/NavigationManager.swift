import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: Int = 0

    func forceGoToHome() {
        self.path = NavigationPath()
        self.selectedTab = 0
    }
}
