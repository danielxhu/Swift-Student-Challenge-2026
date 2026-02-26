import SwiftUI

@main
struct MyApp: App {
    // 强制初始化我们的 CoreData 堆栈，确保离线数据库就绪
    init() {
        _ = CoreDataManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            // 指向我们写好的调度中心
            ContentView()
        }
    }
}
