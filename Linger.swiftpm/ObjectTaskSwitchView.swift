import SwiftUI

enum ItemCategory: String, CaseIterable {
    case kitchen = "Kitchen"
    case food = "Food"
    case bedroom = "Bedroom"
}

struct CategorizedItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: ItemCategory
    let imageName: String
    let isSystemImage: Bool
}

class ObjectTaskSwitchViewModel: ObservableObject {
    let allItems: [CategorizedItem] = [
        CategorizedItem(name: "Fork", category: .kitchen, imageName: "fork.knife", isSystemImage: true),
        CategorizedItem(name: "Frying Pan", category: .kitchen, imageName: "frying.pan.fill", isSystemImage: true),
        CategorizedItem(name: "Cup", category: .kitchen, imageName: "cup.and.saucer.fill", isSystemImage: true),
        CategorizedItem(name: "Apple", category: .food, imageName: "apple.logo", isSystemImage: true),
        CategorizedItem(name: "Carrot", category: .food, imageName: "carrot.fill", isSystemImage: true),
        CategorizedItem(name: "Cake", category: .food, imageName: "birthday.cake.fill", isSystemImage: true),
        CategorizedItem(name: "Bed", category: .bedroom, imageName: "bed.double.fill", isSystemImage: true),
        CategorizedItem(name: "Lamp", category: .bedroom, imageName: "lamp.desk.fill", isSystemImage: true),
        CategorizedItem(name: "Alarm Clock", category: .bedroom, imageName: "alarm.fill", isSystemImage: true)
    ]
    
    @Published var phase: TrainingPhase = .learn
    enum TrainingPhase { case learn, taskA, taskB, success }
    
    @Published var progressCount: Int = 0
    let maxProgress: Int = 10
    @Published var feedbackMessage: String = ""
    
    @Published var taskAItem: CategorizedItem?
    @Published var taskAOptions: [String] = []
    
    @Published var taskBTargetCategory: ItemCategory = .kitchen
    @Published var taskBGridItems: [CategorizedItem] = []
    @Published var taskBSelectedIDs: Set<UUID> = []
    @Published var taskBTargetCount: Int = 0
    
    func startSession() {
        progressCount = 0
        phase = .learn
        feedbackMessage = ""
    }
    
    func beginTraining() {
        generateTaskA()
        generateTaskB()
        phase = .taskA 
        feedbackMessage = "Let's begin! Take your time."
    }
    
    func switchTask() {
        feedbackMessage = ""
        phase = (phase == .taskA) ? .taskB : .taskA
    }
    
    func generateTaskA() {
        let target = allItems.randomElement()!
        taskAItem = target
        
        var options = Set([target.name])
        while options.count < 4 { 
            options.insert(allItems.randomElement()!.name)
        }
        taskAOptions = Array(options).shuffled()
    }
    
    func generateTaskB() {
        taskBTargetCategory = ItemCategory.allCases.randomElement()!
        taskBSelectedIDs.removeAll()
        
        let targets = allItems.filter { $0.category == taskBTargetCategory }.shuffled().prefix(3)
        let distractors = allItems.filter { $0.category != taskBTargetCategory }.shuffled().prefix(3)
        
        taskBTargetCount = targets.count
        taskBGridItems = (Array(targets) + Array(distractors)).shuffled()
    }
    
    func handleTaskATap(selectedName: String) {
        if selectedName == taskAItem?.name {
            progressOnSuccess()
            if phase != .success { generateTaskA() } 
        } else {
            feedbackMessage = "Let's try another choice! Take all the time you need."
        }
    }
    
    func handleTaskBTap(item: CategorizedItem) {
        if item.category == taskBTargetCategory {
            taskBSelectedIDs.insert(item.id)
            feedbackMessage = ["Well done!", "Great job!", "Perfect!"].randomElement()!
            
            if taskBSelectedIDs.count == taskBTargetCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.progressOnSuccess()
                    if self.phase != .success { self.generateTaskB() } 
                }
            }
        } else {
            feedbackMessage = "Let's try another choice! Take all the time you need."
        }
    }
    
    private func progressOnSuccess() {
        progressCount += 1
        feedbackMessage = ["Wonderful work!", "You got it!"].randomElement()!
        if progressCount >= maxProgress {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.phase = .success
            }
        }
    }
}

struct ObjectTaskSwitchView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ObjectTaskSwitchViewModel()
    
    let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0)
    let darkGrayCard = Color(white: 0.15)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                topNavBar
                
                if viewModel.phase == .learn {
                    learnPhaseView
                } else if viewModel.phase == .success {
                    successPhaseView
                } else {
                    trainingPhaseView
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startSession()
            state.speak("Review the items and their categories.")
        }
    }
    
    var topNavBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack { Image(systemName: "chevron.left"); Text("Back") }
                    .font(.system(size: state.fontSize(24), weight: .bold))
                    .foregroundColor(deepOrange).padding().background(darkGrayCard).cornerRadius(12)
            }
            Spacer()
            Button(action: { state.speak("This app works fully offline! Ask a family member for help if needed.") }) {
                HStack { Image(systemName: "questionmark.circle.fill"); Text("Help") }
                    .font(.system(size: state.fontSize(24), weight: .bold))
                    .foregroundColor(deepOrange).padding().background(darkGrayCard).cornerRadius(12)
            }
        }
        .padding()
    }
    
    var learnPhaseView: some View {
        VStack(spacing: 20) {
            Text("Review Categories")
                .font(.system(size: state.fontSize(32), weight: .heavy)).foregroundColor(.white)
            
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(ItemCategory.allCases, id: \.self) { category in
                        VStack(alignment: .leading) {
                            Text(category.rawValue)
                                .font(.system(size: state.fontSize(28), weight: .bold))
                                .foregroundColor(deepOrange) 
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    let items = viewModel.allItems.filter { $0.category == category }
                                    ForEach(items) { item in
                                        VStack {
                                            itemImage(for: item)
                                                .frame(width: 100, height: 100)
                                                .background(darkGrayCard).cornerRadius(16) 
                                            Text(item.name)
                                                .font(.system(size: state.fontSize(22), weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            
            Button(action: {
                viewModel.beginTraining()
                state.speak("Let's begin! You can switch tasks at any time.")
            }) {
                Text("I'm Ready!")
                    .font(.system(size: state.fontSize(32), weight: .bold))
                    .frame(maxWidth: .infinity).padding()
                    .background(deepOrange).foregroundColor(.white).cornerRadius(16)
                    .padding()
            }
        }
    }

    var trainingPhaseView: some View {
        VStack(spacing: 20) {
            Button(action: {
                viewModel.switchTask()
                state.speak("Task switched.")
            }) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    Text("Switch Task")
                }
                .font(.system(size: state.fontSize(28), weight: .heavy))
                .frame(maxWidth: .infinity).padding()
                .background(darkGrayCard)
                .foregroundColor(deepOrange)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(deepOrange, lineWidth: 3)) 
                .padding(.horizontal)
            }
            
            Text("Progress: \(viewModel.progressCount) / \(viewModel.maxProgress)")
                .font(.system(size: state.fontSize(22), weight: .bold)).foregroundColor(.gray)
            
            Text(viewModel.feedbackMessage)
                .font(.system(size: state.fontSize(24), weight: .bold))
                .foregroundColor(viewModel.feedbackMessage.contains("try") ? .gray : .green)
                .frame(height: 60).multilineTextAlignment(.center).padding(.horizontal)
                .onChange(of: viewModel.feedbackMessage) { oldValue, newValue in
                    if !newValue.isEmpty { state.speak(newValue) }
                }
            
            if viewModel.phase == .taskA { taskAView } else { taskBView }
        }
    }
    
    var taskAView: some View {
        VStack(spacing: 30) {
            Text("What is this object?")
                .font(.system(size: state.fontSize(32), weight: .heavy)).foregroundColor(.white)
                .onAppear { state.speak("What is this object?") }
            
            if let item = viewModel.taskAItem {
                itemImage(for: item)
                    .frame(width: 180, height: 180)
                    .background(darkGrayCard).cornerRadius(20)
            }
            
            VStack(spacing: 15) {
                ForEach(viewModel.taskAOptions, id: \.self) { option in
                    Button(action: { viewModel.handleTaskATap(selectedName: option) }) {
                        Text(option)
                            .font(.system(size: state.fontSize(28), weight: .bold))
                            .frame(maxWidth: .infinity).padding()
                            .background(darkGrayCard).foregroundColor(.white).cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var taskBView: some View {
        VStack(spacing: 20) {
            Text("Tap all the \(viewModel.taskBTargetCategory.rawValue)!")
                .font(.system(size: state.fontSize(32), weight: .heavy)).foregroundColor(.white)
                .multilineTextAlignment(.center)
                .onAppear { state.speak("Tap all the \(viewModel.taskBTargetCategory.rawValue)!") }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)], spacing: 20) {
                ForEach(viewModel.taskBGridItems) { item in
                    Button(action: { viewModel.handleTaskBTap(item: item) }) {
                        itemImage(for: item)
                            .frame(width: 120, height: 120)
                            .background(darkGrayCard).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(viewModel.taskBSelectedIDs.contains(item.id) ? Color.green : Color.clear, lineWidth: 8))
                            .opacity(viewModel.taskBSelectedIDs.contains(item.id) ? 0.6 : 1.0)
                    }
                    .disabled(viewModel.taskBSelectedIDs.contains(item.id))
                }
            }
            .padding(.horizontal)
        }
    }
    
    var successPhaseView: some View {
        VStack(spacing: 40) {
            Image(systemName: "star.circle.fill").font(.system(size: 100)).foregroundColor(deepOrange)
            Text("Great session!").font(.system(size: state.fontSize(40), weight: .heavy)).foregroundColor(.white)
            
            Button(action: { viewModel.startSession() }) {
                Text("Play Again").font(.system(size: state.fontSize(28), weight: .bold))
                    .frame(maxWidth: .infinity).padding().background(Color.green).foregroundColor(.white).cornerRadius(16)
            }.padding(.horizontal, 40)
        }
        .onAppear { 
            state.speak("Great session! You did wonderful work.")
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "progressTaskSwitch") + 1, forKey: "progressTaskSwitch")
        }
    }
    
    @ViewBuilder
    func itemImage(for item: CategorizedItem) -> some View {
        if item.isSystemImage {
            Image(systemName: item.imageName).resizable().scaledToFit().padding(20).foregroundColor(deepOrange)
        } else {
            Image(item.imageName).resizable().scaledToFit().padding(10)
        }
    }
}
