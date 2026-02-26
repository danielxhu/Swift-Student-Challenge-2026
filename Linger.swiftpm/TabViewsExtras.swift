import SwiftUI
import PhotosUI
import CoreData

// MARK: - 🌟 全模块临床高阶指标引擎 (Global Metrics Engine)
struct SessionMetric: Codable, Identifiable {
    var id = UUID()
    var time: Double
    var accuracy: Double
}

class MetricsStore: ObservableObject {
    static let shared = MetricsStore()
    
    @Published var history: [String: [SessionMetric]] = [:] {
        didSet {
            if let data = try? JSONEncoder().encode(history) {
                UserDefaults.standard.set(data, forKey: "allMetricsHistory")
            }
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "allMetricsHistory"),
           let decoded = try? JSONDecoder().decode([String: [SessionMetric]].self, from: data) {
            history = decoded
        }
    }
    
    func addSession(module: String, time: Double, accuracy: Double) {
        var metrics = history[module] ?? []
        metrics.append(SessionMetric(time: time, accuracy: accuracy))
        if metrics.count > 5 { metrics.removeFirst() } // 永远只保留最近5次
        history[module] = metrics
    }
    
    func resetMetrics() { history.removeAll() }
}

// MARK: - Tab 3: 家属区与成果追踪
struct FamilyProgressView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.managedObjectContext) var context
    @ObservedObject var metricsStore = MetricsStore.shared 
    
    @AppStorage("familyPIN") var familyPIN: String = "1234"
    @State private var isUnlocked: Bool = false
    @State private var enteredPIN: String = ""
    @State private var showError: Bool = false
    
    @AppStorage("progressItemRecall") var progressItemRecall: Int = 0
    @AppStorage("progressTaskSwitch") var progressTaskSwitch: Int = 0
    @AppStorage("progressWordLink") var progressWordLink: Int = 0
    @AppStorage("progressFamilyFaces") var progressFamilyFaces: Int = 0
    @AppStorage("progressSpatialMemory") var progressSpatialMemory: Int = 0
    @AppStorage("progressVisualSearch") var progressVisualSearch: Int = 0
    @AppStorage("progressMath") var progressMath: Int = 0
    @AppStorage("progressSmellTask") var progressSmellTask: Int = 0
    @AppStorage("progressSequenceTracking") var progressSequenceTracking: Int = 0
    @AppStorage("isErrorlessModeEnabled") var isErrorlessModeEnabled: Bool = false
    
    @FetchRequest(entity: NSEntityDescription.entity(forEntityName: "FamilyMember", in: CoreDataManager.shared.container.viewContext)!, sortDescriptors: []) var familyMembers: FetchedResults<NSManagedObject>
    @State private var showingAddSheet = false; @State private var showingChangePIN = false; @State private var newPIN = ""
    
    let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0)
    let darkGrayCard = Color(white: 0.15)
    
    // 我们要追踪并在看板显示的模块列表
    let trackableModules = [
        ("Math Fitness", "MathFitness"),
        ("Sequence Tracking", "SequenceTracking"),
        ("Spatial Memory", "SpatialMemory"),
        ("Visual Focus", "VisualFocus"),
        ("Family Faces", "FamilyFaces")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if !isUnlocked {
                    VStack(spacing: 30) {
                        Image(systemName: "lock.shield.fill").font(.system(size: 80)).foregroundColor(deepOrange)
                        Text("Family Access").font(.system(size: 32, weight: .heavy)).foregroundColor(.white)
                        SecureField("Enter PIN", text: $enteredPIN).font(.system(size: 30)).keyboardType(.numberPad).multilineTextAlignment(.center).foregroundColor(.white).frame(width: 200).padding().background(darkGrayCard).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(deepOrange, lineWidth: 2))
                        if showError { Text("Incorrect PIN.").foregroundColor(.red).font(.system(size: 18, weight: .bold)) }
                        Button(action: verifyPIN) { Text("Unlock").font(.system(size: 24, weight: .bold)).frame(width: 200).padding().background(deepOrange).foregroundColor(.white).cornerRadius(16) }
                    }
                } else {
                    List {
                        Section(header: Text("ADVANCED CARE SETTINGS").foregroundColor(deepOrange).font(.subheadline)) {
                            Toggle(isOn: $isErrorlessModeEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Errorless Learning Mode").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                                    Text("Correct answers gently glow after hesitating. Reduces frustration.").font(.system(size: 14)).foregroundColor(.gray)
                                }
                            }.tint(deepOrange)
                        }.listRowBackground(darkGrayCard)
                        
                        // 🌟 全模块最近5次性能面板
                        Section(header: Text("CLINICAL METRICS (LAST 5 SESSIONS)").foregroundColor(deepOrange).font(.subheadline)) {
                            if metricsStore.history.isEmpty {
                                Text("No advanced tracking data yet.").foregroundColor(.gray)
                            } else {
                                ForEach(trackableModules, id: \.1) { displayTitle, moduleKey in
                                    if let metrics = metricsStore.history[moduleKey], !metrics.isEmpty {
                                        DisclosureGroup {
                                            let avgAcc = metrics.map { $0.accuracy }.reduce(0, +) / Double(metrics.count)
                                            HStack { Text("Avg Accuracy").foregroundColor(.gray); Spacer(); Text("\(Int(avgAcc * 100))%").foregroundColor(deepOrange).fontWeight(.bold) }
                                            ForEach(Array(metrics.enumerated()), id: \.element.id) { index, metric in
                                                HStack {
                                                    Text("Session \(index + 1)").foregroundColor(.gray).font(.system(size: 14))
                                                    Spacer()
                                                    Text("\(String(format: "%.1f", metric.time))s").foregroundColor(.white).font(.system(size: 14))
                                                    Text("\(Int(metric.accuracy * 100))%").foregroundColor(metric.accuracy >= 0.8 ? .green : .orange).frame(width: 40, alignment: .trailing).font(.system(size: 14, weight: .bold))
                                                }
                                            }
                                        } label: {
                                            Text(displayTitle).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                                        }.tint(deepOrange)
                                    }
                                }
                                Button("Reset All Metrics") { metricsStore.resetMetrics() }.foregroundColor(.red).font(.system(size: 14))
                            }
                        }.listRowBackground(darkGrayCard)
                        
                        Section(header: Text("TOTAL SESSIONS COMPLETED").foregroundColor(deepOrange).font(.subheadline)) {
                            progressRow(title: "Daily Senses", count: progressSmellTask, icon: "nose.fill")
                            progressRow(title: "Sequence Tracking", count: progressSequenceTracking, icon: "sparkles.rectangle.stack.fill") 
                            progressRow(title: "Math Fitness", count: progressMath, icon: "plus.forwardslash.minus")
                            progressRow(title: "Item Memory", count: progressItemRecall, icon: "cube.box.fill")
                            progressRow(title: "Task Switch", count: progressTaskSwitch, icon: "arrow.triangle.2.circlepath.circle.fill")
                            progressRow(title: "Word Link", count: progressWordLink, icon: "text.bubble.fill")
                            progressRow(title: "Family Faces", count: progressFamilyFaces, icon: "person.2.circle.fill")
                            progressRow(title: "Spatial Memory", count: progressSpatialMemory, icon: "house.fill")
                            progressRow(title: "Visual Focus", count: progressVisualSearch, icon: "magnifyingglass.circle.fill")
                        }.listRowBackground(darkGrayCard)
                        
                        Section(header: Text("FAMILY MEMBERS").foregroundColor(deepOrange).font(.subheadline)) {
                            if familyMembers.isEmpty { Text("No members yet. Tap + to add.").foregroundColor(.gray) } 
                            else { ForEach(familyMembers, id: \.self) { member in HStack { if let photoData = member.value(forKey: "photoData") as? Data, let uiImage = UIImage(data: photoData) { Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 50, height: 50).clipShape(Circle()) }; VStack(alignment: .leading) { Text(member.value(forKey: "fullName") as? String ?? "").foregroundColor(.white).font(.headline); Text(member.value(forKey: "relationship") as? String ?? "").foregroundColor(.gray).font(.subheadline) } } }.onDelete(perform: deleteMembers) }
                        }.listRowBackground(darkGrayCard)
                    }
                    .scrollContentBackground(.hidden).navigationTitle("Dashboard")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) { HStack(spacing: 20) { Button("Lock") { isUnlocked = false }.foregroundColor(.red); EditButton().foregroundColor(deepOrange) } }
                        ToolbarItem(placement: .navigationBarTrailing) { HStack { Button(action: { showingChangePIN = true }) { Image(systemName: "key.fill") }; Button(action: { showingAddSheet = true }) { Image(systemName: "plus.circle.fill") } }.foregroundColor(deepOrange) }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) { AddFamilyMemberSheet() }
        .alert("New PIN", isPresented: $showingChangePIN) { TextField("New PIN", text: $newPIN).keyboardType(.numberPad); Button("Save") { familyPIN = newPIN }; Button("Cancel", role: .cancel) {} } message: { Text("Enter a new PIN for Family Access.") }
    }
    
    func progressRow(title: String, count: Int, icon: String) -> some View { HStack(spacing: 15) { Image(systemName: icon).font(.system(size: 20)).foregroundColor(deepOrange).frame(width: 30); Text(title).font(.system(size: 18, weight: .bold)).foregroundColor(.white); Spacer(); Text("\(count)").font(.system(size: 22, weight: .heavy)).foregroundColor(deepOrange).padding(.horizontal, 12).background(Color.black.opacity(0.3)).cornerRadius(8) }.padding(.vertical, 4) }
    func verifyPIN() { if enteredPIN == familyPIN { isUnlocked = true; showError = false; enteredPIN = "" } else { showError = true; enteredPIN = "" } }
    func deleteMembers(at offsets: IndexSet) { for index in offsets { context.delete(familyMembers[index]) }; try? context.save() }
}

// AddFamilyMemberSheet 和 HelpCenterView
struct AddFamilyMemberSheet: View {
    @Environment(\.managedObjectContext) var context; @Environment(\.presentationMode) var presentationMode
    @State private var fullName: String = ""; @State private var relationship: String = ""; @State private var selectedPhotoItem: PhotosPickerItem? = nil; @State private var selectedPhotoData: Data? = nil
    var body: some View { NavigationStack { Form { Section(header: Text("Photo")) { HStack { Spacer(); PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) { if let selectedPhotoData, let uiImage = UIImage(data: selectedPhotoData) { Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 120, height: 120).clipShape(Circle()).overlay(Circle().stroke(Color(red: 0.85, green: 0.4, blue: 0.0), lineWidth: 3)) } else { VStack { Image(systemName: "photo.circle.fill").font(.system(size: 80)).foregroundColor(Color(red: 0.85, green: 0.4, blue: 0.0)); Text("Select Photo").font(.headline).foregroundColor(.white) } } }.onChange(of: selectedPhotoItem) { oldValue, newItem in Task { if let data = try? await newItem?.loadTransferable(type: Data.self) { selectedPhotoData = data } } }; Spacer() }.padding(.vertical) }.listRowBackground(Color(white: 0.15)); Section(header: Text("Details")) { TextField("Full Name", text: $fullName).font(.title2); TextField("Relationship", text: $relationship).font(.title2) }.listRowBackground(Color(white: 0.15)) }.scrollContentBackground(.hidden).background(Color.black.ignoresSafeArea()).navigationTitle("Add Family Member").navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }.foregroundColor(Color(red: 0.85, green: 0.4, blue: 0.0)), trailing: Button("Save") { saveToCoreData() }.disabled(fullName.isEmpty || relationship.isEmpty || selectedPhotoData == nil).foregroundColor(Color(red: 0.85, green: 0.4, blue: 0.0))) } }
    func saveToCoreData() { let newEntity = NSEntityDescription.insertNewObject(forEntityName: "FamilyMember", into: context); newEntity.setValue(UUID(), forKey: "id"); newEntity.setValue(fullName, forKey: "fullName"); newEntity.setValue(relationship, forKey: "relationship"); newEntity.setValue(selectedPhotoData, forKey: "photoData"); do { try context.save(); presentationMode.wrappedValue.dismiss() } catch { print("Error") } }
}

struct HelpCenterView: View {
    @EnvironmentObject var state: AppState
    let deepOrange = Color(red: 0.85, green: 0.4, blue: 0.0); let darkGrayCard = Color(white: 0.15)
    var body: some View { NavigationStack { ZStack { Color.black.ignoresSafeArea(); ScrollView { VStack(spacing: 20) { Text("Caregiver Guide").font(.system(size: state.fontSize(32), weight: .heavy)).foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal); Text("Professional tips to support your loved one's daily life and maintain a positive environment.").font(.system(size: state.fontSize(18))).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal); HStack { Image(systemName: "bubble.left.and.bubble.right.fill").foregroundColor(deepOrange); Text("Communication Tips").font(.system(size: 24, weight: .bold)).foregroundColor(.white); Spacer() }.padding(.horizontal).padding(.top, 10); helpCard(title: "Avoid Arguing or Correcting", desc: "Never argue. If they say something incorrect, validate their feelings and gently redirect the conversation.", icon: "heart.fill"); helpCard(title: "Keep Choices Simple", desc: "Avoid open-ended questions. Ask yes/no questions or offer only two clear choices at a time.", icon: "hand.point.up.left.fill"); HStack { Image(systemName: "house.fill").foregroundColor(deepOrange); Text("Home Environment").font(.system(size: 24, weight: .bold)).foregroundColor(.white); Spacer() }.padding(.horizontal).padding(.top, 20); helpCard(title: "Improve Lighting", desc: "Ensure rooms are brightly lit to reduce shadows, which can cause confusion, illusions, or fear.", icon: "lightbulb.fill"); helpCard(title: "Prevent Falls", desc: "Remove loose rugs, keep walkways clear of clutter, and add grab bars in the bathroom.", icon: "figure.walk"); helpCard(title: "Label Drawers", desc: "Place pictures or large-text labels on cabinets and doors to help them find things easily without asking.", icon: "tag.fill") }.padding(.bottom, 30) } }.navigationTitle("Guide") } }
    func helpCard(title: String, desc: String, icon: String) -> some View { HStack(spacing: 20) { Image(systemName: icon).font(.system(size: 40)).foregroundColor(deepOrange).frame(width: 60); VStack(alignment: .leading, spacing: 8) { Text(title).font(.system(size: state.fontSize(22), weight: .bold)).foregroundColor(.white); Text(desc).font(.system(size: state.fontSize(18))).foregroundColor(.gray) }; Spacer() }.padding().background(darkGrayCard).cornerRadius(16).padding(.horizontal) }
}
