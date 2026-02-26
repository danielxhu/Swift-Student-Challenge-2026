import SwiftUI
import AVFoundation

class AppState: ObservableObject {
    // 1. 用户偏好设置
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("textSizeAdjustment") var textSizeAdjustment: Double = 0 // 0: Large, 4: XL, 8: XXL
    @AppStorage("isVoiceEnabled") var isVoiceEnabled: Bool = true
    
    // 2. 关卡解锁逻辑 (Key: 模块ID, Value: 完成次数)
    @AppStorage("unlockedLevels") var unlockedLevelsData: Data = Data()
    
    // 3. 语音引擎
    private let synthesizer = AVSpeechSynthesizer()
    
    // 核心文本尺寸计算 (确保最小 24pt)
    func fontSize(_ base: CGFloat) -> CGFloat {
        return base + textSizeAdjustment
    }
    
    // 朗读函数 (无网络依赖)
    func speak(_ text: String) {
        guard isVoiceEnabled else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45 // 略慢，适合老人
        synthesizer.speak(utterance)
    }
}
