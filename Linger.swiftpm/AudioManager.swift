import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    var bgmPlayer: AVAudioPlayer?
    
    func startBGM() {
        guard let url = Bundle.main.url(forResource: "bgm", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = (-1)
            bgmPlayer?.volume = 0.3
            bgmPlayer?.play()
        } catch { }
    }
    
    func stopBGM() {
        bgmPlayer?.stop()
    }
}
