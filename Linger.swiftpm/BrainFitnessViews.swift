import SwiftUI

let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0)
let darkGrayCard = Color(white: 0.15)

// MARK: - 1. 空间记忆 (Spatial Memory)
struct SpatialMemoryView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    
    enum Phase {
        case memorize
        case recall
        case success
    }
    
    @State private var phase: Phase = .memorize
    @State private var targetIndex: Int = Int.random(in: 0..<6)
    @State private var selectedIndex: Int? = nil
    @State private var feedback: String = ""
    
    @AppStorage("progressSpatialMemory") var progress: Int = 0
    
    @State private var sessionStartTime = Date()
    @State private var totalTaps = 0
    @State private var correctTaps = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                topBar(title: "Spatial Memory")
                
                if phase == .success {
                    successView(nextAction: resetTask)
                } else {
                    Text(phase == .memorize ? "Remember where the keys are" : "Where were the keys?")
                        .font(.system(size: state.fontSize(28), weight: .heavy))
                        .foregroundColor(.white)
                    
                    Text(feedback)
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                        .frame(height: 30)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(0..<6, id: \.self) { index in
                            Button(action: {
                                handleTap(index)
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(darkGrayCard)
                                        .frame(height: 120)
                                    
                                    if phase == .memorize && index == targetIndex {
                                        Image(systemName: "key.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(deepOrange)
                                    } else if phase == .recall && selectedIndex == index {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 40))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .disabled(phase == .memorize)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    if phase == .memorize {
                        Button("Hide Keys") {
                            phase = .recall
                            feedback = ""
                            sessionStartTime = Date()
                        }
                        .font(.system(size: state.fontSize(24), weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(deepOrange)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 40)
                    }
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    func resetTask() {
        targetIndex = Int.random(in: 0..<6)
        phase = .memorize
        selectedIndex = nil
        totalTaps = 0
        correctTaps = 0
    }
    
    func handleTap(_ index: Int) {
        totalTaps += 1
        if index == targetIndex {
            correctTaps += 1
            let safeTotal = max(1, totalTaps)
            MetricsStore.shared.addSession(
                module: "SpatialMemory",
                time: Date().timeIntervalSince(sessionStartTime),
                accuracy: Double(correctTaps) / Double(safeTotal)
            )
            state.speak("Excellent spatial memory!")
            progress += 1
            phase = .success
        } else {
            selectedIndex = index
            feedback = "Not quite, try another spot."
        }
    }
}

// MARK: - 2. 视觉搜索 (Visual Focus)
struct VisualSearchView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var items: [String] = []
    @State private var targetItem: String = ""
    @State private var isSuccess = false
    
    @AppStorage("progressVisualSearch") var progress: Int = 0
    
    @State private var sessionStartTime = Date()
    @State private var totalTaps = 0
    @State private var correctTaps = 0
    
    let allSymbols = [
        "cup.and.saucer.fill",
        "eyeglasses",
        "tv.fill",
        "book.closed.fill",
        "clock.fill",
        "comb.fill",
        "scissors",
        "fork.knife"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                topBar(title: "Visual Focus")
                
                if isSuccess {
                    successView(nextAction: setupGame)
                } else {
                    Text("Find this item:")
                        .font(.system(size: state.fontSize(28), weight: .heavy))
                        .foregroundColor(.white)
                    
                    Image(systemName: targetItem)
                        .font(.system(size: 60))
                        .foregroundColor(deepOrange)
                        .padding()
                        .background(darkGrayCard)
                        .cornerRadius(16)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                        ForEach(0..<items.count, id: \.self) { i in
                            Button(action: {
                                checkTap(items[i])
                            }) {
                                Image(systemName: items[i])
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 100)
                                    .background(darkGrayCard)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: setupGame)
    }
    
    func setupGame() {
        isSuccess = false
        totalTaps = 0
        correctTaps = 0
        sessionStartTime = Date()
        
        let shuffled = allSymbols.shuffled()
        targetItem = shuffled[0]
        var grid = Array(shuffled.prefix(8))
        grid.append(targetItem)
        items = grid.shuffled()
    }
    
    func checkTap(_ item: String) {
        totalTaps += 1
        if item == targetItem {
            correctTaps += 1
            let safeTotal = max(1, totalTaps)
            MetricsStore.shared.addSession(
                module: "VisualFocus",
                time: Date().timeIntervalSince(sessionStartTime),
                accuracy: Double(correctTaps) / Double(safeTotal)
            )
            state.speak("Sharp eyes! Well done.")
            progress += 1
            isSuccess = true
        } else {
            state.speak("Keep looking.")
        }
    }
}

// MARK: - 3. 数学健脑 (Math Fitness)
struct MathFitnessView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var num1 = 0
    @State private var num2 = 0
    @State private var options: [Int] = []
    
    @State private var isSuccess = false
    @State private var showHint = false
    
    @State private var sessionStartTime = Date()
    @State private var totalTaps = 0
    @State private var correctTaps = 0
    
    @AppStorage("progressMath") var progress: Int = 0
    @AppStorage("isErrorlessModeEnabled") var isErrorlessModeEnabled: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                topBar(title: "Math Fitness")
                
                if isSuccess {
                    successView(nextAction: generateMath)
                } else {
                    Text("Keep Your Mind Sharp")
                        .font(.system(size: state.fontSize(28), weight: .heavy))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        Text("\(num1)").font(.system(size: 60, weight: .bold)).foregroundColor(.white)
                        Text("+").font(.system(size: 50)).foregroundColor(deepOrange)
                        Text("\(num2)").font(.system(size: 60, weight: .bold)).foregroundColor(.white)
                        Text("=").font(.system(size: 50)).foregroundColor(deepOrange)
                        Text("?").font(.system(size: 60, weight: .bold)).foregroundColor(.gray)
                    }
                    .padding(40)
                    .background(darkGrayCard)
                    .cornerRadius(20)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(options, id: \.self) { opt in
                            let isCorrectAnswer = (opt == num1 + num2)
                            let shouldGlow = isErrorlessModeEnabled && showHint && isCorrectAnswer
                            
                            Button(action: {
                                checkAnswer(opt)
                            }) {
                                Text("\(opt)")
                                    .font(.system(size: 40, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 30)
                                    .background(shouldGlow ? deepOrange.opacity(0.4) : darkGrayCard)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(shouldGlow ? Color.green : deepOrange.opacity(0.3), lineWidth: shouldGlow ? 4 : 2)
                                    )
                                    .shadow(color: shouldGlow ? Color.green.opacity(0.5) : Color.clear, radius: 10)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: generateMath)
    }
    
    func generateMath() {
        isSuccess = false
        showHint = false
        totalTaps = 0
        correctTaps = 0
        sessionStartTime = Date()
        
        num1 = Int.random(in: 1...20)
        num2 = Int.random(in: 1...20)
        let answer = num1 + num2
        
        var opts = Set([answer])
        while opts.count < 4 {
            opts.insert(answer + Int.random(in: -5...5))
        }
        options = Array(opts).shuffled()
        
        if isErrorlessModeEnabled {
            // 🌟 这里的等待时间已设定为精准的 10 秒
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                if !self.isSuccess {
                    self.showHint = true
                }
            }
        }
    }
    
    func checkAnswer(_ opt: Int) {
        let isCorrect = (opt == num1 + num2)
        totalTaps += 1
        
        if isCorrect {
            correctTaps += 1
            let safeTotal = max(1, totalTaps)
            MetricsStore.shared.addSession(
                module: "MathFitness",
                time: Date().timeIntervalSince(sessionStartTime),
                accuracy: Double(correctTaps) / Double(safeTotal)
            )
            state.speak("Perfect calculation!")
            progress += 1
            isSuccess = true
        } else {
            if isErrorlessModeEnabled {
                if let idx = options.firstIndex(of: opt) {
                    options.remove(at: idx)
                }
            }
            state.speak("Let's try again.")
        }
    }
}

// MARK: - 4. 每日嗅觉小任务 (Daily Senses)
struct DailySmellTaskView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSuccess = false
    @AppStorage("progressSmellTask") var progress: Int = 0
    
    @AppStorage("lastSmellDate") var lastSmellDate: String = ""
    @AppStorage("currentSmellTaskIndex") var currentSmellTaskIndex: Int = 0
    
    let taskPool = [
        ("Coffee or Tea", "cup.and.saucer.fill", "Go to the kitchen. Smell some coffee beans or a fresh teabag."),
        ("Fresh Fruit", "apple.logo", "Find an orange or lemon. Gently scratch the skin and smell the citrus."),
        ("Bath Soap", "bubbles.and.sparkles", "Go to the bathroom and open your favorite soap or shampoo. Take a deep breath."),
        ("Spices", "leaf.fill", "Open your spice cabinet. Try to find cinnamon, vanilla, or mint."),
        ("Fresh Air", "wind", "Open a window or step outside for a moment. Take a deep breath of the air.")
    ]
    
    @State private var currentTask: (title: String, icon: String, desc: String) = ("", "", "")
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                topBar(title: "Daily Senses")
                
                if isSuccess {
                    successView(nextAction: { 
                        presentationMode.wrappedValue.dismiss() 
                    })
                } else {
                    Text("Today's Sensory Task")
                        .font(.system(size: state.fontSize(32), weight: .heavy))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        Image(systemName: currentTask.icon)
                            .font(.system(size: 80))
                            .foregroundColor(deepOrange)
                        Text(currentTask.title)
                            .font(.system(size: state.fontSize(28), weight: .bold))
                            .foregroundColor(deepOrange)
                        Text(currentTask.desc)
                            .font(.system(size: state.fontSize(22), weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .background(darkGrayCard)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    Text("How did it smell?")
                        .font(.system(size: state.fontSize(24), weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                    
                    HStack(spacing: 20) {
                        Button(action: recordTask) {
                            VStack {
                                Image(systemName: "face.smiling.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.green)
                                Text("Smells Great")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(darkGrayCard)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.3), lineWidth: 2))
                        }
                        
                        Button(action: recordTask) {
                            VStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Not Much Smell")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(darkGrayCard)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3), lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
            if lastSmellDate != today {
                lastSmellDate = today
                currentSmellTaskIndex = Int.random(in: 0..<taskPool.count)
            }
            currentTask = taskPool[currentSmellTaskIndex]
            state.speak("Today's task. \(currentTask.title).")
        }
    }
    
    func recordTask() {
        state.speak("Wonderful! Paying attention to your senses is great for your brain.")
        progress += 1
        isSuccess = true
    }
}

// MARK: - 5. 循迹追踪 (Sequential Working Memory)
struct SequentialMemoryView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    
    enum Phase {
        case memorize
        case recall
        case success
    }
    
    @State private var phase: Phase = .memorize
    
    @AppStorage("progressSequenceTracking") var progress: Int = 0
    @AppStorage("isErrorlessModeEnabled") var isErrorlessModeEnabled: Bool = false
    
    let allItems = [
        ("Cup", "cup.and.saucer.fill"),
        ("Keys", "key.fill"),
        ("Glasses", "eyeglasses"),
        ("Book", "book.closed.fill"),
        ("Clock", "clock.fill"),
        ("Comb", "comb.fill")
    ]
    
    @State private var currentItems: [(String, String)] = []
    @State private var sequence: [Int] = []
    
    @State private var userProgressIndex: Int = 0
    @State private var activeFlashIndex: Int? = nil 
    @State private var tappedIndices: Set<Int> = []
    @State private var hintTask: DispatchWorkItem? = nil 
    @State private var isSuccess = false
    
    @State private var sessionStartTime = Date()
    @State private var totalTaps = 0
    @State private var correctTaps = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                topBar(title: "Sequence Tracking")
                
                if phase == .success {
                    successView(nextAction: setupGame)
                } else {
                    Text(phase == .memorize ? "Watch the sequence closely" : "Tap them in the order they flashed")
                        .font(.system(size: state.fontSize(28), weight: .heavy))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 20) {
                        ForEach(0..<currentItems.count, id: \.self) { i in
                            let isTapped = tappedIndices.contains(i)
                            let isFlashing = (activeFlashIndex == i)
                            
                            Button(action: {
                                handleTap(index: i)
                            }) {
                                VStack(spacing: 15) {
                                    Image(systemName: currentItems[i].1)
                                        .font(.system(size: 50))
                                        .foregroundColor(isTapped ? .gray : (isFlashing ? deepOrange : .white))
                                    Text(currentItems[i].0)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(isTapped ? .gray : (isFlashing ? deepOrange : .white))
                                }
                                .frame(width: 140, height: 140)
                                .background(darkGrayCard)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isFlashing ? deepOrange : (isTapped ? .gray.opacity(0.3) : .clear), lineWidth: isFlashing ? 4 : 2)
                                )
                                .shadow(color: isFlashing ? deepOrange.opacity(0.6) : .clear, radius: 15)
                                .scaleEffect(isFlashing ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 0.5), value: isFlashing)
                            }
                            .disabled(phase == .memorize || isTapped)
                        }
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: setupGame)
        .onDisappear {
            hintTask?.cancel()
        }
    }
    
    func setupGame() {
        phase = .memorize
        isSuccess = false
        userProgressIndex = 0
        tappedIndices.removeAll()
        activeFlashIndex = nil
        hintTask?.cancel()
        
        currentItems = Array(allItems.shuffled().prefix(3))
        sequence = [0, 1, 2].shuffled() 
        
        totalTaps = 0
        correctTaps = 0
        
        state.speak("Watch the sequence closely.")
        playSequence()
    }
    
    func playSequence() {
        var delay = 1.0
        for index in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                activeFlashIndex = index
            }
            delay += 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                activeFlashIndex = nil
            }
            delay += 0.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            phase = .recall
            sessionStartTime = Date()
            state.speak("Now, tap them in the same order.")
            startHintTimer() 
        }
    }
    
    func handleTap(index: Int) {
        hintTask?.cancel() 
        activeFlashIndex = nil
        totalTaps += 1
        
        let targetIndex = sequence[userProgressIndex]
        
        if index == targetIndex {
            tappedIndices.insert(index)
            correctTaps += 1
            userProgressIndex += 1
            
            if userProgressIndex == sequence.count {
                let safeTotal = max(1, totalTaps)
                MetricsStore.shared.addSession(
                    module: "SequenceTracking",
                    time: Date().timeIntervalSince(sessionStartTime),
                    accuracy: Double(correctTaps) / Double(safeTotal)
                )
                state.speak("Perfect memory!")
                progress += 1
                phase = .success
            } else {
                startHintTimer() 
            }
        } else {
            state.speak("Let's try another one.")
            if isErrorlessModeEnabled {
                startHintTimer() 
            }
        }
    }
    
    func startHintTimer() {
        guard isErrorlessModeEnabled else { return }
        hintTask?.cancel()
        
        let task = DispatchWorkItem {
            if phase == .recall && userProgressIndex < sequence.count {
                activeFlashIndex = sequence[userProgressIndex] 
            }
        }
        hintTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: task)
    }
}

// MARK: - 共用组件
@ViewBuilder 
func topBar(title: String) -> some View {
    HStack {
        DismissButton()
        Spacer()
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(deepOrange)
    }
    .padding()
}

struct DismissButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: { 
            presentationMode.wrappedValue.dismiss() 
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(deepOrange)
            .padding()
            .background(darkGrayCard)
            .cornerRadius(12)
        }
    }
}

@ViewBuilder 
func successView(nextAction: @escaping () -> Void) -> some View {
    VStack(spacing: 40) {
        Image(systemName: "star.circle.fill")
            .font(.system(size: 100))
            .foregroundColor(deepOrange)
        
        Text("Great session!")
            .font(.system(size: 40, weight: .heavy))
            .foregroundColor(.white)
        
        Button(action: nextAction) {
            Text("Play Again")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(16)
        }
        .padding(.horizontal, 40)
    }
}
