import SwiftUI
import AVKit

struct AnimationConstants {
    static let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7)
    static let defaultRadius: CGFloat = 16
    static let cardSpacing: CGFloat = 20
}

struct BubbleView: View {
    @State private var isAnimating = false
    let color: Color
    let size: CGFloat
    let delay: Double

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 20)
            .offset(y: isAnimating ? 400 : -400)
            .opacity(0.3)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 5...8))
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    isAnimating = true
                }
            }
    }
}
struct NavigationBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
    }
}

extension NavigationStack {
    func withBackground() -> some View {
        self.modifier(NavigationBackground())
    }
}

struct BackgroundColorModifier: ViewModifier {
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .background(
                BackgroundView(backgroundColor: backgroundColor)
                    .ignoresSafeArea()
            )
    }
}

struct BackgroundView: UIViewControllerRepresentable {
    let backgroundColor: Color

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor(backgroundColor)
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        uiViewController.view.backgroundColor = UIColor(backgroundColor)
    }
}

extension View {
    func withBackground(color: Color) -> some View {
        self.modifier(BackgroundColorModifier(backgroundColor: color))
    }
}

struct LandingScreen: View {
    @State private var isLoading = true
    @State private var titleOffset: CGFloat = 1000
    @State private var subtitleOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.5
    @State private var showShine = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                BubbleView(color: .blue, size: 150, delay: 0).offset(x: -100)
                BubbleView(color: .purple, size: 100, delay: 2).offset(x: 100)
                BubbleView(color: .cyan, size: 120, delay: 4)

                VStack(spacing: 40) {
                    Spacer()

                    ZStack {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                                .frame(width: 100 + CGFloat(i * 20))
                                .scaleEffect(isLoading ? 1.2 : 0.8)
                                .opacity(isLoading ? 0.3 : 0.8)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(Double(i) * 0.2), value: isLoading)
                        }

                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(isLoading ? 360 : 0))
                            .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: isLoading)
                    }

                    Text("NeuroPath").font(.system(size: 44, weight: .bold, design: .rounded)).foregroundColor(.blue).offset(y: titleOffset).shadow(color: .blue.opacity(0.3), radius: 2)
                    Text("Let's start this magical journey\nto bloom your child.").font(.title2).multilineTextAlignment(.center).foregroundColor(.primary).opacity(subtitleOpacity).padding(.horizontal, 24)

                    Spacer()

                    NavigationLink(destination: MainTabView().navigationBarBackButtonHidden(true)) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: 240, height: 56).overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.3), lineWidth: 1)).shadow(color: .blue.opacity(0.3), radius: 8)

                            if showShine {
                                Rectangle().fill(LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.8), .clear]), startPoint: .leading, endPoint: .trailing)).frame(width: 40, height: 56).offset(x: showShine ? 240 : -240).mask(RoundedRectangle(cornerRadius: 25))
                            }

                            HStack(spacing: 12) {
                                Text("Begin Journey").font(.headline).foregroundColor(.white)
                                Image(systemName: "arrow.right").font(.headline).foregroundColor(.white).opacity(subtitleOpacity)
                            }
                        }.scaleEffect(buttonScale)
                    }.padding(.bottom, 60)
                }
            }.navigationBarHidden(true).onAppear {
                animateElements()
            }
        }
    }

    private func animateElements() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            titleOffset = 0
        }

        withAnimation(.easeIn(duration: 0.6).delay(0.4)) {
            subtitleOpacity = 1
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
            buttonScale = 1
        }

        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                showShine = true
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                PersonalInfoScreen()
            }.tabItem {
                Image(systemName: "person.fill")
                Text("My Info")
            }

            NavigationStack {
                ExercisesScreen()
            }.tabItem {
                Image(systemName: "figure.walk")
                Text("Exercises")
            }

            NavigationStack {
                LogsScreen()
            }.tabItem {
                Image(systemName: "list.bullet")
                Text("Logs")
            }
        }.accentColor(.blue)
    }
}

struct PersonalInfoScreen: View {
    @AppStorage("parentName") private var parentName = ""
    @AppStorage("childName") private var childName = ""
    @AppStorage("gender") private var gender = "Male"
    @AppStorage("age") private var age = 3

    let genders = ["Male", "Female"]
    let ages = Array(1...18)

    @State private var isEditing = false
    @State private var navigateToExercises = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack {
                    Text("Personal Information").font(.largeTitle).fontWeight(.bold).foregroundColor(.blue).padding(.top)
                    Form {
                        Section(header: Text("Parent/Caretaker Info")) {
                            CustomTextField(title: "Name", text: $parentName)
                            CustomTextField(title: "Child's Name", text: $childName)
                        }

                        Section(header: Text("Child's Details")) {
                            Picker("Gender", selection: $gender) {
                                ForEach(genders, id: \.self) { Text($0) }
                            }
                            Picker("Age", selection: $age) {
                                ForEach(ages, id: \.self) { Text("\($0)") }
                            }
                        }
                    }.padding(.top, -20)

                    HStack {
                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Text(isEditing ? "Save" : "Edit").font(.headline).foregroundColor(.white).padding(.horizontal, 20).padding(.vertical, 10).background(isEditing ? Color.blue : Color.green).cornerRadius(10)
                        }

                        Button(action: {
                            navigateToExercises = true
                        }) {
                            Text("Continue to Exercises").font(.headline).foregroundColor(.white).padding(.horizontal, 20).padding(.vertical, 10).background(Color.blue).cornerRadius(10).disabled(isEditing)
                        }
                    }.padding()

                    NavigationLink("", destination: ExercisesScreen(), isActive: $navigateToExercises).hidden()
                }
            }.navigationBarHidden(true)
        }
    }
}

struct CustomTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            TextField(title, text: $text).textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}


struct ExercisesScreen: View {
    let exercises = [
        "Breathing Exercise",
        "Stretching Exercise",
        "Sensory Touch Exercise",
        "Eye Contact Exercise"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack {
                    Text("Exercises")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top)

                    List {
                        Section(header: Text("Exercises")) {
                            ForEach(exercises, id: \.self) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exerciseName: exercise)) {
                                    Text(exercise)
                                        .font(.headline)
                                }
                            }
                        }

                        Section(header: Text("Stress Release")) {
                            NavigationLink(destination: FlowerHapticGameView()) {
                                Text("Calming Flower Game")
                                    .font(.headline)
                            }
                        }
                    }
                    .padding(.top, -20)
                }
            }
            .navigationBarHidden(false)
            .navigationTitle("Exercises")
        }.withBackground(color: Color(.systemBackground))    }
}

struct FirecrackerView: View {
    @State private var isAnimating = false

    var body: some View {
        Image(systemName: "sparkles")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(.yellow)
            .scaleEffect(isAnimating ? 1.5 : 0.5)
            .opacity(isAnimating ? 0 : 1)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    isAnimating = true
                }
            }
    }
}

struct FlowerHapticGameView: View {
    @State private var tapCount = 0
    @AppStorage("flowerGameScores") private var flowerGameScoresData: Data = Data()
    @State private var gameScores: [String: Int] = [:]
    @State private var highScore = 0
    @State private var showFirecrackers = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack {
                Text("Calming Flower Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding()

                Text("Tap the flowers to reduce stress and relax!")
                    .font(.headline)
                    .padding()

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    ForEach(0..<6, id: \.self) { _ in
                        FlowerView(tapCount: $tapCount)
                    }
                }.padding()

                Text("Flowers Tapped: \(tapCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding()

                Text("Today's High Score: \(highScore)")
                    .font(.headline)
                    .foregroundColor(.purple)
                    .padding()

                Button(action: endGame) {
                    Text("End Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }.padding(.top, 20)

                Spacer()
            }.padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Stress Release")
            .onAppear {
                loadHighScore()
            }
            .onChange(of: tapCount) { newTapCount in
                if newTapCount > highScore {
                    highScore = newTapCount
                    showFirecrackers = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showFirecrackers = false
                    }
                }
            }

            if showFirecrackers {
                ForEach(0..<20, id: \.self) { _ in
                    FirecrackerView()
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                }
            }
        }
    }

    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func loadHighScore() {
        let scores = UserDefaults.standard.dictionary(forKey: "flowerGameScores") as? [String: Int] ?? [:]
        highScore = scores[formattedDate()] ?? 0
    }

    func saveHighScore() {
        let today = formattedDate()
        var scores = UserDefaults.standard.dictionary(forKey: "flowerGameScores") as? [String: Int] ?? [:]

        if tapCount > (scores[today] ?? 0) {
            scores[today] = tapCount
            UserDefaults.standard.set(scores, forKey: "flowerGameScores")
        }
    }

    func endGame() {
        saveHighScore()
        presentationMode.wrappedValue.dismiss()
    }
}

struct FlowerView: View {
    @Binding var tapCount: Int
    @State private var isBloomed = false

    var body: some View {
        Image("bloomed_flower")
            .resizable()
            .frame(width: isBloomed ? 120 : 100, height: isBloomed ? 120 : 100)
            .shadow(color: .pink.opacity(0.6), radius: isBloomed ? 15 : 5)
            .scaleEffect(isBloomed ? 1.3 : 1.0)
            .onTapGesture {
                tapCount += 1
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                withAnimation(.easeInOut(duration: 0.4)) {
                    isBloomed = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isBloomed = false
                    }
                }
            }
    }
}


struct ExerciseDetailView: View {
    let exerciseName: String
    @AppStorage("dailyLogs") private var dailyLogsData: Data = Data()
    @State private var isCompleted: Bool = false
    @State private var isImageFullScreen: Bool = false

    let exerciseDetails: [String: (description: String, steps: [String], imageName: String)] = [
        "Breathing Exercise": (
            "A calming exercise to reduce stress and improve focus.",
            [
                "Find a quiet space.",
                "Sit or lie down comfortably.",
                "Close your eyes.",
                "Breathe in deeply through your nose for 4 seconds.",
                "Hold your breath for 4 seconds.",
                "Exhale slowly through your mouth for 6 seconds.",
                "Repeat for 5-10 minutes."
            ],
            "breathing"
        ),
        "Stretching Exercise": (
            "Improves flexibility and reduces muscle tension.",
            [
                "Stand with feet shoulder-width apart.",
                "Reach your arms overhead.",
                "Bend forward from your hips.",
                "Try to touch your toes (or as far as comfortable).",
                "Hold for 15-30 seconds.",
                "Repeat 2-3 times."
            ],
            "stretch3"
        ),
        "Sensory Touch Exercise": (
            "Enhances sensory awareness and exploration.",
            [
                "Gather objects with different textures (soft, rough, smooth).",
                "Close your eyes.",
                "Feel each object and describe its texture.",
                "Focus on the sensations.",
                "Repeat with each object."
            ],
            "sens"
        ),
        "Eye Contact Exercise": (
            "Improves eye contact and social interaction.",
            [
                "Sit facing a partner.",
                "Gently make eye contact.",
                "Hold eye contact for a few seconds.",
                "Take breaks and repeat.",
                "Gradually increase the duration."
            ],
            "eye"
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(exerciseName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal)

                        if let details = exerciseDetails[exerciseName] {
                            Text(details.description)
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)

                            HStack {
                                Spacer()
                                Image(details.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 5)
                                    .onTapGesture {
                                        isImageFullScreen = true
                                    }
                                Spacer()
                            }.fullScreenCover(isPresented: $isImageFullScreen) {
                                FullScreenImageView(imageName: details.imageName, isPresented: $isImageFullScreen)
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Steps:")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(details.steps, id: \.self) { step in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text(step)
                                            .padding(.leading)
                                    }
                                }
                            }.padding(.vertical)

                            Toggle(isOn: $isCompleted) {
                                Text("Mark as Completed")
                                    .font(.headline)
                            }.padding()
                            .onChange(of: isCompleted) { newValue in
                                updateExerciseCompletion(exerciseName: exerciseName, isCompleted: newValue)
                            }
                        }

                        Spacer()
                    }.padding(.top)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(exerciseName)
            .navigationBarHidden(false)
            .onAppear {
                loadCompletionStatus()
            }
        }.withBackground(color: Color(.systemBackground))
    }

    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func updateExerciseCompletion(exerciseName: String, isCompleted: Bool) {
        var logs = loadLogs()
        let today = formattedDate()

        if logs[today] == nil {
            logs[today] = [:]
        }
        logs[today]?[exerciseName] = isCompleted

        if let encoded = try? JSONEncoder().encode(logs) {
            dailyLogsData = encoded
        }
    }

    func loadCompletionStatus() {
        let logs = loadLogs()
        let today = formattedDate()
        isCompleted = logs[today]?[exerciseName] ?? false
    }

    func loadLogs() -> [String: [String: Bool]] {
        if let decoded = try? JSONDecoder().decode([String: [String: Bool]].self, from: dailyLogsData) {
            return decoded
        }
        return [:]
    }
}


struct FullScreenImageView: View {
    let imageName: String
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                Spacer()
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}




import SwiftUI

struct LogsScreen: View {
    @State private var selectedDate = Date()
    @State private var dailyLogs: [String: [String: Bool]] = [:]
    @State private var gameScores: [String: Int] = [:]

    let exercises = [
        "Breathing Exercise",
        "Stretching Exercise",
        "Sensory Touch Exercise",
        "Eye Contact Exercise"
    ]

    var body: some View {
        NavigationStack {
            VStack {
                Text("Logs & Progress")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top)

                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(.horizontal)

                List {
                    Section(header: Text("Exercise Completion")) {
                        let dateKey = formattedDate(for: selectedDate)
                        if let dayLogs = dailyLogs[dateKey] {
                            ForEach(exercises, id: \.self) { exercise in
                                HStack {
                                    Text(exercise)
                                    Spacer()
                                    Image(systemName: dayLogs[exercise] == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(dayLogs[exercise] == true ? .green : .red)
                                }
                            }
                        } else {
                            Text("No exercises logged for \(dateKey).")
                                .foregroundColor(.gray)
                        }
                    }

                    Section(header: Text("Flower Game High Score")) {
                        let dateKey = formattedDate(for: selectedDate)
                        let score = gameScores[dateKey] ?? 0

                        if score > 0 {
                            Text("High Score: \(score)")
                                .foregroundColor(.purple)
                        } else {
                            Text("No game score logged.")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Logs & Progress")
            .onAppear {
                loadLogs()
                loadGameScores()
            }
            .onChange(of: selectedDate) { _ in
                loadGameScores()
            }
        }
    }


    func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: "dailyLogs"),
           let decoded = try? JSONDecoder().decode([String: [String: Bool]].self, from: data) {
            dailyLogs = decoded
        } else {
            dailyLogs = [:]
        }
    }


    func loadGameScores() {
        if let scores = UserDefaults.standard.dictionary(forKey: "flowerGameScores") as? [String: Int] {
            gameScores = scores
        } else {
            gameScores = [:]
        }
    }

}

struct ContentView: View {
    var body: some View {
        LandingScreen()
    }
}

struct Previews_ContentView: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

