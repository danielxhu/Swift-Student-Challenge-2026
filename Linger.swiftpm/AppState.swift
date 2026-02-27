import SwiftUI
import AVFoundation

class AppState: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("textSizeAdjustment") var textSizeAdjustment: Double = 0 
    @AppStorage("isVoiceEnabled") var isVoiceEnabled: Bool = true
    
    @AppStorage("unlockedLevels") var unlockedLevelsData: Data = Data()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    func fontSize(_ base: CGFloat) -> CGFloat {
        return base + textSizeAdjustment
    }
    
    func speak(_ text: String) {
        guard isVoiceEnabled else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45 
        synthesizer.speak(utterance)
    }
}
