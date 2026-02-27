import SwiftUI

@main
struct MyApp: App {
    init() {
        _ = CoreDataManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
