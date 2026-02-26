import SwiftUI

struct ContentView: View {
    @StateObject var state = AppState()
    // 🌟 监听 App 的当前状态（前台、后台、非活跃）
    @Environment(\.scenePhase) var scenePhase 
    
    var body: some View {
        Group {
            if !state.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .environmentObject(state)
        .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
        .preferredColorScheme(.dark)
        .onAppear {
            AudioManager.shared.startBGM()
        }
        // 🌟 核心修复：一旦 App 进入后台或被停止，立刻强行停止音乐！
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                AudioManager.shared.startBGM()
            } else if newPhase == .background || newPhase == .inactive {
                AudioManager.shared.stopBGM()
            }
        }
        .onDisappear {
            // 双保险：界面销毁时也停止播放
            AudioManager.shared.stopBGM()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            TrainHubView()
                .tabItem { Label("Fitness", systemImage: "brain") }
            FamilyProgressView()
                .tabItem { Label("Family", systemImage: "person.2") }
            HelpCenterView()
                .tabItem { Label("Help", systemImage: "questionmark.circle") }
        }
        .accentColor(Color(red: 0.85, green: 0.4, blue: 0.0)) 
    }
}
