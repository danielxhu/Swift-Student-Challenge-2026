import SwiftUI
import CoreData

struct FamilyMemberItem: Identifiable, Hashable {
    let id: UUID
    let fullName: String
    let relationship: String
    let photoData: Data?
    var isMock: Bool = false
}

class FamilyFacesViewModel: ObservableObject {
    @Published var phase: Phase = .learn
    enum Phase { case learn, chooseTask, activeTask, success }
    
    @Published var familyMembers: [FamilyMemberItem] = []
    @Published var progressCount: Int = 0
    let maxProgress: Int = 5
    @Published var feedbackMessage: String = ""
    
    @Published var subTask: SubTaskType = .faceToName
    enum SubTaskType { case faceToName, nameToFace }
    
    @Published var currentTarget: FamilyMemberItem?
    @Published var options: [String] = []
    @Published var optionsItems: [FamilyMemberItem] = []
    
    var sessionStartTime = Date()
    var totalTaps = 0
    var correctTaps = 0
    
    func startSession() {
        progressCount = 0
        phase = .learn
        feedbackMessage = ""
        loadMembers()
    }
    
    func loadMembers() {
        let context = CoreDataManager.shared.container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "FamilyMember")
        do {
            let results = try context.fetch(request)
            var loaded = results.compactMap { obj -> FamilyMemberItem? in
                guard let id = obj.value(forKey: "id") as? UUID,
                      let name = obj.value(forKey: "fullName") as? String,
                      let rel = obj.value(forKey: "relationship") as? String else {
                    return nil
                }
                let data = obj.value(forKey: "photoData") as? Data
                return FamilyMemberItem(id: id, fullName: name, relationship: rel, photoData: data)
            }
            if loaded.isEmpty {
                loaded = [
                    FamilyMemberItem(id: UUID(), fullName: "Sarah", relationship: "Daughter", photoData: nil, isMock: true),
                    FamilyMemberItem(id: UUID(), fullName: "Mike", relationship: "Son", photoData: nil, isMock: true),
                    FamilyMemberItem(id: UUID(), fullName: "Emma", relationship: "Granddaughter", photoData: nil, isMock: true)
                ]
            }
            familyMembers = loaded
        } catch {
            print("Error loading members")
        }
    }
    
    func chooseTask(_ task: SubTaskType) {
        subTask = task
        totalTaps = 0
        correctTaps = 0
        sessionStartTime = Date()
        generateTask()
        phase = .activeTask
        feedbackMessage = "Let's go! Take your time."
    }
    
    func generateTask() {
        guard !familyMembers.isEmpty else { return }
        let target = familyMembers.randomElement()!
        currentTarget = target
        
        if subTask == .faceToName {
            var opts = Set([target.fullName])
            let fillers = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank"]
            let availableFillers = familyMembers.map { $0.fullName } + fillers
            while opts.count < 4 {
                opts.insert(availableFillers.randomElement()!)
            }
            options = Array(opts).shuffled()
        } else if subTask == .nameToFace {
            var opts = Set([target])
            let availableFillers = familyMembers.filter { $0.id != target.id }
            if availableFillers.count >= 3 {
                opts.formUnion(availableFillers.shuffled().prefix(3))
            } else {
                opts.formUnion(availableFillers)
                while opts.count < min(4, familyMembers.count) {
                    opts.insert(familyMembers.randomElement()!)
                }
            }
            optionsItems = Array(opts).shuffled()
        }
    }
    
    func handleTextTap(_ selectedName: String) {
        totalTaps += 1
        if selectedName == currentTarget?.fullName {
            correctTaps += 1
            progressOnSuccess()
        } else {
            feedbackMessage = "Let's try another one!"
        }
    }
    
    func handleImageTap(_ selectedItem: FamilyMemberItem) {
        totalTaps += 1
        if selectedItem.id == currentTarget?.id {
            correctTaps += 1
            progressOnSuccess()
        } else {
            feedbackMessage = "Let's try another one!"
        }
    }
    
    private func progressOnSuccess() {
        progressCount += 1
        feedbackMessage = ["Wonderful!", "Spot on!", "Exactly right!"].randomElement()!
        
        if progressCount >= maxProgress {
            let safeTotal = max(1, totalTaps)
            MetricsStore.shared.addSession(
                module: "FamilyFaces",
                time: Date().timeIntervalSince(sessionStartTime),
                accuracy: Double(correctTaps) / Double(safeTotal)
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.phase = .success
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.feedbackMessage = ""
                self.generateTask()
            }
        }
    }
}

struct FamilyFacesView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = FamilyFacesViewModel()
    
    @AppStorage("isErrorlessModeEnabled") var isErrorlessModeEnabled: Bool = false
    @State private var showHint = false
    @State private var hintTask: DispatchWorkItem? = nil
    
    let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0)
    let darkGrayCard = Color(white: 0.15)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                topNavBar
                
                if viewModel.phase == .learn {
                    learnPhaseView
                } else if viewModel.phase == .chooseTask {
                    chooseTaskPhaseView
                } else if viewModel.phase == .activeTask {
                    activeTaskPhaseView
                } else {
                    successPhaseView
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startSession()
            state.speak("Review your family members.")
        }
        .onDisappear {
            hintTask?.cancel()
        }
    }
    
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
            Button(action: { state.speak("This app works fully offline!") }) {
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
    
    var learnPhaseView: some View {
        VStack(spacing: 20) {
            Text("Your Family")
                .font(.system(size: state.fontSize(32), weight: .heavy))
                .foregroundColor(.white)
            
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(viewModel.familyMembers) { member in
                        VStack {
                            memberImage(for: member, size: 150, shouldGlow: false)
                            Text(member.fullName)
                                .font(.system(size: state.fontSize(28), weight: .bold))
                                .foregroundColor(.white)
                            Text(member.relationship)
                                .font(.system(size: state.fontSize(22), weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(darkGrayCard)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                }
            }
            
            Button(action: {
                viewModel.phase = .chooseTask
                state.speak("Choose a training mode.")
            }) {
                Text("I'm Ready!")
                    .font(.system(size: state.fontSize(32), weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(deepOrange)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding()
            }
        }
    }
    
    var chooseTaskPhaseView: some View {
        VStack(spacing: 30) {
            Text("Select Training")
                .font(.system(size: state.fontSize(32), weight: .heavy))
                .foregroundColor(.white)
            
            taskButton(title: "Face → Name", icon: "person.crop.circle.badge.questionmark", task: .faceToName)
            taskButton(title: "Name → Face", icon: "text.bubble.fill", task: .nameToFace)
        }
        .padding(.horizontal)
    }
    
    func taskButton(title: String, icon: String, task: FamilyFacesViewModel.SubTaskType) -> some View {
        Button(action: {
            viewModel.chooseTask(task)
            startHintTimer()
        }) {
            HStack(spacing: 20) {
                Image(systemName: icon).font(.system(size: 40)).foregroundColor(deepOrange)
                Text(title).font(.system(size: state.fontSize(28), weight: .bold)).foregroundColor(.white)
                Spacer()
            }
            .padding(30).frame(maxWidth: .infinity).background(darkGrayCard).cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(deepOrange.opacity(0.5), lineWidth: 2))
        }
    }
    
    var activeTaskPhaseView: some View {
        VStack(spacing: 20) {
            Text("Progress: \(viewModel.progressCount) / \(viewModel.maxProgress)")
                .font(.system(size: state.fontSize(22), weight: .bold))
                .foregroundColor(.gray)
            
            Text(viewModel.feedbackMessage)
                .font(.system(size: state.fontSize(24), weight: .bold))
                .foregroundColor(viewModel.feedbackMessage.contains("try") ? .gray : .green)
                .frame(height: 60)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .onChange(of: viewModel.feedbackMessage) { oldValue, newValue in
                    if !newValue.isEmpty { state.speak(newValue) }
                    if newValue.isEmpty || newValue == "Let's try another one!" {
                        startHintTimer()
                    }
                }
            
            if let target = viewModel.currentTarget {
                if viewModel.subTask == .faceToName {
                    Text("Who is this?").font(.system(size: state.fontSize(32), weight: .heavy)).foregroundColor(.white)
                        .onAppear { state.speak("Who is this?") }
                    memberImage(for: target, size: 180, shouldGlow: false)
                    VStack(spacing: 15) {
                        ForEach(viewModel.options, id: \.self) { opt in
                            let isCorrect = (opt == target.fullName)
                            let shouldGlow = isErrorlessModeEnabled && showHint && isCorrect
                            textOptionButton(text: opt, shouldGlow: shouldGlow) {
                                showHint = false
                                hintTask?.cancel()
                                viewModel.handleTextTap(opt)
                            }
                        }
                    }.padding(.horizontal)
                    
                } else if viewModel.subTask == .nameToFace {
                    Text("Tap \(target.fullName)!").font(.system(size: state.fontSize(32), weight: .heavy)).foregroundColor(.white)
                        .onAppear { state.speak("Tap \(target.fullName)!") }
                    Text(target.relationship).font(.system(size: state.fontSize(24))).foregroundColor(.gray)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)]) {
                        ForEach(viewModel.optionsItems) { optItem in
                            let isCorrect = (optItem.id == target.id)
                            let shouldGlow = isErrorlessModeEnabled && showHint && isCorrect
                            Button(action: {
                                showHint = false
                                hintTask?.cancel()
                                viewModel.handleImageTap(optItem)
                            }) {
                                memberImage(for: optItem, size: 130, shouldGlow: shouldGlow)
                            }
                        }
                    }.padding()
                }
            }
        }
    }
    
    var successPhaseView: some View {
        VStack(spacing: 40) {
            Image(systemName: "star.circle.fill").font(.system(size: 100)).foregroundColor(deepOrange)
            Text("Great session!").font(.system(size: state.fontSize(40), weight: .heavy)).foregroundColor(.white)
            VStack(spacing: 20) {
                Button(action: {
                    viewModel.phase = .chooseTask
                    viewModel.feedbackMessage = ""
                }) {
                    Text("Play Again").font(.system(size: state.fontSize(28), weight: .bold)).frame(maxWidth: .infinity).padding().background(Color.green).foregroundColor(.white).cornerRadius(16)
                }
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Back to Train Hub").font(.system(size: state.fontSize(28), weight: .bold)).frame(maxWidth: .infinity).padding().background(darkGrayCard).foregroundColor(.white).cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(deepOrange, lineWidth: 2))
                }
            }.padding(.horizontal, 40)
        }
        .onAppear {
            state.speak("Great session! You did wonderful work.")
            let currentProgress = UserDefaults.standard.integer(forKey: "progressFamilyFaces")
            UserDefaults.standard.set(currentProgress + 1, forKey: "progressFamilyFaces")
        }
    }
    
    func startHintTimer() {
        guard isErrorlessModeEnabled else { return }
        showHint = false
        hintTask?.cancel()
        
        let task = DispatchWorkItem { showHint = true }
        hintTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: task)
    }
    
    @ViewBuilder
    func memberImage(for member: FamilyMemberItem, size: CGFloat, shouldGlow: Bool) -> some View {
        Group {
            if member.isMock || member.photoData == nil {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().scaledToFit().frame(width: size, height: size).foregroundColor(deepOrange)
                    .background(shouldGlow ? deepOrange.opacity(0.4) : darkGrayCard).clipShape(Circle())
            } else if let photoData = member.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage).resizable().scaledToFill().frame(width: size, height: size).clipShape(Circle())
            }
        }
        .overlay(Circle().stroke(shouldGlow ? Color.green : Color.clear, lineWidth: shouldGlow ? 6 : 0))
        .shadow(color: shouldGlow ? Color.green.opacity(0.6) : Color.clear, radius: 15)
        .scaleEffect(shouldGlow ? 1.05 : 1.0)
        .animation(shouldGlow ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: shouldGlow)
    }
    
    func textOptionButton(text: String, shouldGlow: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text).font(.system(size: state.fontSize(28), weight: .bold)).frame(maxWidth: .infinity).padding()
                .background(shouldGlow ? deepOrange.opacity(0.4) : darkGrayCard)
                .foregroundColor(.white).cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(shouldGlow ? Color.green : Color.clear, lineWidth: shouldGlow ? 4 : 0))
                .shadow(color: shouldGlow ? Color.green.opacity(0.6) : Color.clear, radius: 10)
        }
        .scaleEffect(shouldGlow ? 1.05 : 1.0)
        .animation(shouldGlow ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: shouldGlow)
    }
}
