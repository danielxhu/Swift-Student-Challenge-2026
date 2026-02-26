import SwiftUI

struct TrainHubView: View {
    @EnvironmentObject var state: AppState
    let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea() 
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Daily Brain Fitness")
                            .font(.system(size: state.fontSize(32), weight: .heavy))
                            .foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.top, 10)
                        
                        NavigationLink(destination: DailySmellTaskView()) { TrainingCard(title: "Daily Senses", subtitle: "Wake up your sense of smell", iconName: "nose.fill", accentColor: deepOrange) }
                        
                        // 🌟 换成了全新的 Sequence Tracking (循迹追踪)
                        NavigationLink(destination: SequentialMemoryView()) { TrainingCard(title: "Sequence Tracking", subtitle: "Follow the flashing order", iconName: "sparkles.rectangle.stack.fill", accentColor: deepOrange) }
                        
                        NavigationLink(destination: MathFitnessView()) { TrainingCard(title: "Math Fitness", subtitle: "Keep your mind sharp with numbers", iconName: "plus.forwardslash.minus", accentColor: deepOrange) }
                        NavigationLink(destination: ItemRecallView()) { TrainingCard(title: "Item Memory", subtitle: "Remember everyday objects", iconName: "cube.box.fill", accentColor: deepOrange) }
                        NavigationLink(destination: ObjectTaskSwitchView()) { TrainingCard(title: "Task Switch", subtitle: "Sort and name objects", iconName: "arrow.triangle.2.circlepath.circle.fill", accentColor: deepOrange) }
                        NavigationLink(destination: WordAssociationView()) { TrainingCard(title: "Word Link", subtitle: "Connect related words", iconName: "text.bubble.fill", accentColor: deepOrange) }
                        NavigationLink(destination: FamilyFacesView()) { TrainingCard(title: "Family Faces", subtitle: "Recognize your loved ones", iconName: "person.2.circle.fill", accentColor: deepOrange) }
                        NavigationLink(destination: SpatialMemoryView()) { TrainingCard(title: "Spatial Memory", subtitle: "Recall object locations", iconName: "house.fill", accentColor: deepOrange) }
                        NavigationLink(destination: VisualSearchView()) { TrainingCard(title: "Visual Focus", subtitle: "Find the hidden target", iconName: "magnifyingglass.circle.fill", accentColor: deepOrange) }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Train Hub")
            .navigationBarHidden(true) 
            .onAppear { AudioManager.shared.startBGM() }
        }
    }
}

struct TrainingCard: View {
    @EnvironmentObject var state: AppState
    let title: String; let subtitle: String; let iconName: String; let accentColor: Color
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: iconName).font(.system(size: 50)).foregroundColor(accentColor).frame(width: 80, height: 80).background(Color.black).clipShape(Circle()).overlay(Circle().stroke(accentColor.opacity(0.5), lineWidth: 2))
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.system(size: state.fontSize(28), weight: .bold)).foregroundColor(.white)
                Text(subtitle).font(.system(size: state.fontSize(20), weight: .medium)).foregroundColor(.gray) 
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 30, weight: .bold)).foregroundColor(accentColor.opacity(0.8))
        }.padding(20).frame(maxWidth: .infinity).background(Color(white: 0.12)).cornerRadius(20).shadow(color: accentColor.opacity(0.15), radius: 10, x: 0, y: 5).padding(.horizontal)
    }
}
