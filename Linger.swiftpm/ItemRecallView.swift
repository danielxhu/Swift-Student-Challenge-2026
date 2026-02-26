import SwiftUI

// MARK: - 本地静态数据模型
struct EverydayItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String // 之后替换为你导入的本地 JPEG 名称
    let isSystemImage: Bool // 仅用于 MVP 演示，后期可删除
}

class ItemRecallViewModel: ObservableObject {
    // 模拟本地 80 个日常物品库 (这里精简演示)
    let allDatabaseItems: [EverydayItem] = [
        EverydayItem(name: "Coffee Cup", imageName: "cup.and.saucer.fill", isSystemImage: true),
        EverydayItem(name: "House Keys", imageName: "key.fill", isSystemImage: true),
        EverydayItem(name: "Glasses", imageName: "eyeglasses", isSystemImage: true),
        EverydayItem(name: "Book", imageName: "book.closed.fill", isSystemImage: true),
        EverydayItem(name: "Apple", imageName: "apple.logo", isSystemImage: true),
        EverydayItem(name: "Clock", imageName: "clock.fill", isSystemImage: true),
        EverydayItem(name: "Umbrella", imageName: "umbrella.fill", isSystemImage: true),
        EverydayItem(name: "Telephone", imageName: "phone.fill", isSystemImage: true),
        EverydayItem(name: "Television", imageName: "tv.fill", isSystemImage: true),
        EverydayItem(name: "Scissors", imageName: "scissors", isSystemImage: true),
        EverydayItem(name: "Fork", imageName: "fork.knife", isSystemImage: true),
        EverydayItem(name: "Car", imageName: "car.fill", isSystemImage: true),
        EverydayItem(name: "Chair", imageName: "chair.lounge.fill", isSystemImage: true),
        EverydayItem(name: "Pencil", imageName: "pencil", isSystemImage: true)
    ]
    
    @Published var currentLevel: Int = 1
    @Published var memorizedItems: [EverydayItem] = []
    @Published var testGridItems: [EverydayItem] = []
    @Published var selectedItemIDs: Set<UUID> = []
    
    @Published var phase: TrainingPhase = .learn // learn -> test -> success
    @Published var feedbackMessage: String = ""
    
    enum TrainingPhase {
        case learn, test, success
    }
    
    // 难度配置规则: [记忆数量, 干扰数量]
    let difficultySettings = [
        1: (3, 2),
        2: (4, 3),
        3: (5, 4),
        4: (6, 5),
        5: (8, 6)
    ]
    
    func startNewSession() {
        phase = .learn
        selectedItemIDs.removeAll()
        feedbackMessage = ""
        
        let settings = difficultySettings[currentLevel] ?? (3, 2)
        let memoryCount = settings.0
        let distractorCount = settings.1
        
        // 随机抽取物品
        var shuffledDB = allDatabaseItems.shuffled()
        memorizedItems = Array(shuffledDB.prefix(memoryCount))
        shuffledDB.removeFirst(memoryCount)
        
        let distractors = Array(shuffledDB.prefix(distractorCount))
        
        // 生成测试网格（记忆物品 + 干扰物品，并打乱）
        testGridItems = (memorizedItems + distractors).shuffled()
    }
    
    func handleTap(on item: EverydayItem) {
        if memorizedItems.contains(item) {
            // 正确选择：播放正向反馈并保持选中
            selectedItemIDs.insert(item.id)
            let positivePraises = ["Well done!", "Great job!", "Perfect!", "Wonderful work!"]
            feedbackMessage = positivePraises.randomElement()!
            
            // 检查是否全部找到
            if selectedItemIDs.count == memorizedItems.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.phase = .success
                }
            }
        } else {
            // 错误选择：绝对零惩罚，中性提示
            feedbackMessage = "Let's try another choice! Take all the time you need."
        }
    }
}

// MARK: - 主视图
// MARK: - 主视图 (黑橙护眼版)
struct ItemRecallView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ItemRecallViewModel()
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 20)]
    let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0)
    let darkGrayCard = Color(white: 0.15)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // 全局纯黑背景
            
            VStack {
                topNavBar
                Spacer()
                if viewModel.phase == .learn {
                    learnPhaseView
                } else if viewModel.phase == .test {
                    testPhaseView
                } else {
                    successPhaseView
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startNewSession()
            state.speak("Take a look at these items. Try to remember them.")
        }
    }
    
    // MARK: - 顶部导航栏
    var topNavBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack { Image(systemName: "chevron.left"); Text("Back") }
                    .font(.system(size: state.fontSize(24), weight: .bold))
                    .foregroundColor(deepOrange)
                    .padding()
                    .background(darkGrayCard)
                    .cornerRadius(12)
            }
            Spacer()
            Button(action: { state.speak("This app works fully offline! Ask a family member for help if needed.") }) {
                HStack { Image(systemName: "questionmark.circle.fill"); Text("Help") }
                    .font(.system(size: state.fontSize(24), weight: .bold))
                    .foregroundColor(deepOrange)
                    .padding()
                    .background(darkGrayCard)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - Learn Mode
    var learnPhaseView: some View {
        VStack(spacing: 30) {
            Text("Remember these items")
                .font(.system(size: state.fontSize(32), weight: .heavy))
                .foregroundColor(.white)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(viewModel.memorizedItems) { item in
                        VStack {
                            itemImage(for: item)
                                .frame(width: 120, height: 120)
                                .background(darkGrayCard) // 深灰卡片
                                .cornerRadius(20)
                                .shadow(color: deepOrange.opacity(0.1), radius: 5, x: 0, y: 5)
                            
                            Text(item.name)
                                .font(.system(size: state.fontSize(24), weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
            
            Button(action: {
                viewModel.phase = .test
                viewModel.feedbackMessage = ""
                state.speak("Tap all the items you saw!")
            }) {
                Text("I'm Ready!")
                    .font(.system(size: state.fontSize(32), weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(deepOrange) // 深橙色大按钮
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding()
            }
        }
    }
    
    // MARK: - Test Mode
    var testPhaseView: some View {
        VStack(spacing: 20) {
            Text("Tap all the items you saw!")
                .font(.system(size: state.fontSize(32), weight: .heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(viewModel.feedbackMessage)
                .font(.system(size: state.fontSize(24), weight: .bold))
                .foregroundColor(viewModel.feedbackMessage.contains("try") ? .gray : .green)
                .frame(height: 60)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .onChange(of: viewModel.feedbackMessage) { oldValue, newValue in
                    if !newValue.isEmpty { state.speak(newValue) }
                }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(viewModel.testGridItems) { item in
                        Button(action: { viewModel.handleTap(on: item) }) {
                            itemImage(for: item)
                                .frame(width: 120, height: 120)
                                .background(darkGrayCard)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(viewModel.selectedItemIDs.contains(item.id) ? Color.green : Color.clear, lineWidth: 8)
                                )
                                .opacity(viewModel.selectedItemIDs.contains(item.id) ? 0.6 : 1.0)
                        }
                        .disabled(viewModel.selectedItemIDs.contains(item.id))
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Success Mode
    var successPhaseView: some View {
        VStack(spacing: 40) {
            Image(systemName: "star.circle.fill").font(.system(size: 100)).foregroundColor(deepOrange)
            Text("Great session!")
                .font(.system(size: state.fontSize(40), weight: .heavy))
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                Button(action: { viewModel.startNewSession() }) {
                    Text("Play Again")
                        .font(.system(size: state.fontSize(28), weight: .bold))
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.green)
                        .foregroundColor(.white).cornerRadius(16)
                }
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Back to Train Hub")
                        .font(.system(size: state.fontSize(28), weight: .bold))
                        .frame(maxWidth: .infinity).padding()
                        .background(darkGrayCard)
                        .foregroundColor(.white).cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(deepOrange, lineWidth: 2))
                }
            }
            .padding(.horizontal, 40)
        }
        .onAppear { 
            state.speak("Great session! You did wonderful work.")
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "progressItemRecall") + 1, forKey: "progressItemRecall")
        }
    }
    
    @ViewBuilder
    func itemImage(for item: EverydayItem) -> some View {
        if item.isSystemImage {
            Image(systemName: item.imageName)
                .resizable().scaledToFit().padding(30).foregroundColor(deepOrange) // 系统图标也变成橙色
        } else {
            Image(item.imageName).resizable().scaledToFit().padding(10)
        }
    }
}
