import SwiftUI
import FirebaseCore

@main
struct PremadeHubApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
