import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState
    @State private var currentStep = 1
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() 
            
            VStack(spacing: 40) {

                HStack {
                    Circle()
                        .fill(currentStep == 1 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(currentStep == 2 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 15, height: 15)
                }
                .padding(.top, 20)
                
                if currentStep == 1 {
                    textSizeStep
                } else {
                    voiceStep
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    var textSizeStep: some View {
        VStack(spacing: 30) {
            Text("Welcome!")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.black)
            
            Text("Let's set up your screen.")
                .font(.system(size: 30))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            

            VStack {
                Text("This is how text will look.")
                    .font(.system(size: state.fontSize(24))) 
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            

            VStack(spacing: 20) {
                sizeButton(label: "Large Text", adjustment: 0)
                sizeButton(label: "Extra Large", adjustment: 4)
                sizeButton(label: "XX-Large (Best)", adjustment: 8)
            }
            
            Spacer()
            
            Button(action: { currentStep = 2 }) {
                Text("Next Step")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
        }
    }
    
    var voiceStep: some View {
        VStack(spacing: 30) {
            Text("Voice Guidance")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.black)
            
            Text("Would you like me to read instructions aloud?")
                .font(.system(size: state.fontSize(24)))
                .multilineTextAlignment(.center)
                .padding()

            Button(action: { state.isVoiceEnabled.toggle() }) {
                HStack {
                    Text(state.isVoiceEnabled ? "Voice is ON" : "Voice is OFF")
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                    Image(systemName: state.isVoiceEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                        .font(.system(size: 30))
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(state.isVoiceEnabled ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(state.isVoiceEnabled ? Color.green : Color.gray, lineWidth: 3)
                )
            }
            .foregroundColor(.black)
            

            if state.isVoiceEnabled {
                Button(action: { state.speak("Hello! I am ready to help you train.") }) {
                    Label("Tap to Test Voice", systemImage: "play.circle.fill")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            

            Button(action: {

                state.hasCompletedOnboarding = true 
            }) {
                Text("Start Training!")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
        }
    }
    

    func sizeButton(label: String, adjustment: Double) -> some View {
        Button(action: { state.textSizeAdjustment = adjustment }) {
            HStack {
                Text(label)
                    .font(.system(size: 24 + adjustment)) 
                Spacer()
                if state.textSizeAdjustment == adjustment {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(state.textSizeAdjustment == adjustment ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
        .foregroundColor(.black)
    }
}
