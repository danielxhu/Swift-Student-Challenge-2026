import SwiftUI


struct ContentView: View {
    @State private var hasEntered: Bool = false
    

    @StateObject private var state = AppState()
    
    let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if hasEntered {

                TabView {
                    NavigationView {
                        TrainHubView() 
                    }
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text("Train Hub")
                    }
                    
                    NavigationView {
                        FamilyProgressView() 
                    }
                    .tabItem {
                        Image(systemName: "chart.bar.doc.horizontal")
                        Text("Dashboard")
                    }
                }
                .accentColor(deepOrange)
                .preferredColorScheme(.dark)
                .environmentObject(state)
                
            } else {
                VStack(spacing: 50) {
                    Spacer()
                    
                    ZStack {
                        Image(systemName: "hourglass")
                            .font(.system(size: 100, weight: .ultraLight))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 35))
                            .foregroundColor(deepOrange)
                            .offset(y: 25)
                            .shadow(color: deepOrange.opacity(0.8), radius: 10)
                    }
                    
                    VStack(spacing: 15) {
                        Text("Linger")
                            .font(.system(size: 56, weight: .heavy, design: .serif))
                            .foregroundColor(.white)
                            .tracking(2)
                        
                        Text("Hold onto time, gently.")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        AudioManager.shared.startBGM()
                        hasEntered = true
                    }) {
                        Text("Enter")
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 200)
                            .padding(.vertical, 16)
                            .background(deepOrange)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .padding(.bottom, 80)
                }
            }
        }
    }
}


struct GameCard: View {
    let title: String
    let icon: String
    let destination: AnyView
    
    let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0)
    let darkGrayCard = Color(white: 0.15)
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 45))
                    .foregroundColor(deepOrange)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(darkGrayCard)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}


