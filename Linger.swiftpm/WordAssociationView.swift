import SwiftUI

// MARK: - 数据模型
struct WordAssociationTask: Identifiable {
    let id = UUID()
    let coreObject: String
    let coreImage: String
    let isSystemImage: Bool
    let relatedWords: [String]
    let distractorWords: [String]
}

class WordAssociationViewModel: ObservableObject {
    // 模拟本地语义网络数据库
    let allTasks: [WordAssociationTask] = [
        WordAssociationTask(
            coreObject: "Dog",
            coreImage: "pawprint.fill",
            isSystemImage: true,
            relatedWords: ["Bark", "Bone", "Tail", "Leash"],
            distractorWords: ["Feather", "Engine", "Cloud", "Spoon"]
        ),
        WordAssociationTask(
            coreObject: "Car",
            coreImage: "car.fill",
            isSystemImage: true,
            relatedWords: ["Tire", "Engine", "Drive", "Road"],
            distractorWords: ["Branch", "Ocean", "Oven", "Pillow"]
        ),
        WordAssociationTask(
            coreObject: "Tree",
            coreImage: "leaf.fill",
            isSystemImage: true,
            relatedWords: ["Leaf", "Branch", "Root", "Wood"],
            distractorWords: ["Wheel", "Screen", "Keyboard", "Shoe"]
        ),
        WordAssociationTask(
            coreObject: "Beach",
            coreImage: "sun.max.fill",
            isSystemImage: true,
            relatedWords: ["Sand", "Ocean", "Shell", "Sun"],
            distractorWords: ["Snow", "Blanket", "Fork", "Desk"]
        )
    ]
    
    @Published var currentTask: WordAssociationTask?
    @Published var phase: TrainingPhase = .learn
    @Published var testWords: [String] = [] // 打乱后的词汇列表 (相关词 + 干扰词)
    @Published var selectedWords: Set<String> = []
    @Published var feedbackMessage: String = ""
    
    enum TrainingPhase { case learn, test, success }
    
    func startSession() {
        phase = .learn
        feedbackMessage = ""
        selectedWords.removeAll()
        
        // 随机抽取一个任务
        currentTask = allTasks.randomElement()
        
        // 准备测试用的词汇网格（所有相关词 + 提取部分干扰词，并打乱顺序）
        if let task = currentTask {
            let distractors = Array(task.distractorWords.shuffled().prefix(4))
            testWords = (task.relatedWords + distractors).shuffled()
        }
    }
    
    func startTest() {
        phase = .test
        feedbackMessage = ""
    }
    
    func handleTap(word: String) {
        guard let task = currentTask else { return }
        
        if task.relatedWords.contains(word) {
            // 正确选择
            selectedWords.insert(word)
            feedbackMessage = ["Well done!", "Great job!", "Perfect!"].randomElement()!
            
            // 检查是否找齐了所有的相关词汇
            if selectedWords.count == task.relatedWords.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.phase = .success
                }
            }
        } else {
            // 错误选择：零惩罚
            feedbackMessage = "Let's try another choice! Take all the time you need."
        }
    }
}

// MARK: - 主视图
// MARK: - 主视图 (黑橙护眼版)
struct WordAssociationView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = WordAssociationViewModel()
    
    let columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0)
    let darkGrayCard = Color(white: 0.15)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                topNavBar
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
            viewModel.startSession()
            state.speak("Review the words related to the object.")
        }
    }
    
    var topNavBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack { Image(systemName: "chevron.left"); Text("Back") }
                    .font(.system(size: state.fontSize(24), weight: .bold)).foregroundColor(deepOrange).padding().background(darkGrayCard).cornerRadius(12)
            }
            Spacer()
            Button(action: { state.speak("This app works fully offline! Ask a family member for help if needed.") }) {
                HStack { Image(systemName: "questionmark.circle.fill"); Text("Help") }
                    .font(.system(size: state.fontSize(24), weight: .bold)).foregroundColor(deepOrange).padding().background(darkGrayCard).cornerRadius(12)
            }
        }
        .padding()
    }
    
    var learnPhaseView: some View {
        VStack(spacing: 30) {
            if let task = viewModel.currentTask {
                Text("Words related to:")
                    .font(.system(size: state.fontSize(32), weight: .heavy)).foregroundColor(.white)
                
                VStack {
                    coreImage(for: task).frame(width: 150, height: 150).background(darkGrayCard).cornerRadius(24)
                    Text(task.coreObject).font(.system(size: state.fontSize(36), weight: .bold)).foregroundColor(.white)
                }
                
                VStack(spacing: 15) {
                    ForEach(task.relatedWords, id: \.self) { word in
                        Text(word)
                            .font(.system(size: state.fontSize(28), weight: .bold))
                            .frame(maxWidth: .infinity).padding()
                            .background(darkGrayCard)
                            .foregroundColor(deepOrange) // 相关词用橙色高亮
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(deepOrange.opacity(0.3), lineWidth: 2))
                    }
                }.padding(.horizontal, 40)
            }
            Spacer()
            Button(action: {
                viewModel.startTest()
                state.speak("Tap all the words related to the object.")
            }) {
                Text("I'm Ready!").font(.system(size: state.fontSize(32), weight: .bold)).frame(maxWidth: .infinity).padding().background(deepOrange).foregroundColor(.white).cornerRadius(16).padding()
            }
        }
    }
    
    var testPhaseView: some View {
        VStack(spacing: 20) {
            if let task = viewModel.currentTask {
                Text("Tap words related to:")
                    .font(.system(size: state.fontSize(32), weight: .heavy)).foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal)
                
                coreImage(for: task).frame(width: 100, height: 100).background(darkGrayCard).cornerRadius(16)
                
                Text(viewModel.feedbackMessage)
                    .font(.system(size: state.fontSize(24), weight: .bold))
                    .foregroundColor(viewModel.feedbackMessage.contains("try") ? .gray : .green)
                    .frame(height: 60).multilineTextAlignment(.center).padding(.horizontal)
                    .onChange(of: viewModel.feedbackMessage) { oldValue, newValue in
                        if !newValue.isEmpty { state.speak(newValue) }
                    }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.testWords, id: \.self) { word in
                            Button(action: { viewModel.handleTap(word: word) }) {
                                Text(word)
                                    .font(.system(size: state.fontSize(24), weight: .bold))
                                    .frame(maxWidth: .infinity).frame(height: 80)
                                    .background(darkGrayCard).foregroundColor(.white).cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(viewModel.selectedWords.contains(word) ? Color.green : Color.clear, lineWidth: 6))
                                    .opacity(viewModel.selectedWords.contains(word) ? 0.6 : 1.0)
                            }
                            .disabled(viewModel.selectedWords.contains(word))
                        }
                    }.padding(.horizontal)
                }
            }
        }
    }
    
    var successPhaseView: some View {
        VStack(spacing: 40) {
            Image(systemName: "star.circle.fill").font(.system(size: 100)).foregroundColor(deepOrange)
            Text("Great session!").font(.system(size: state.fontSize(40), weight: .heavy)).foregroundColor(.white)
            Button(action: { viewModel.startSession() }) {
                Text("Play Again").font(.system(size: state.fontSize(28), weight: .bold)).frame(maxWidth: .infinity).padding().background(Color.green).foregroundColor(.white).cornerRadius(16)
            }.padding(.horizontal, 40)
        }
        .onAppear { 
            state.speak("Great session! You did wonderful work.")
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "progressWordLink") + 1, forKey: "progressWordLink")
        }
    }
    
    @ViewBuilder
    func coreImage(for task: WordAssociationTask) -> some View {
        if task.isSystemImage {
            Image(systemName: task.coreImage).resizable().scaledToFit().padding(20).foregroundColor(deepOrange)
        } else {
            Image(task.coreImage).resizable().scaledToFit().padding(10)
        }
    }
}
