import SwiftUI

// MARK: - Observable class to manage overlay state

class VariableOverlayManager: ObservableObject {
    @Published var isVisible = false
    @Published var text = ""
    @Published var shouldFlash = false

    private var dismissTimer: Timer?
    private let dismissDelay: TimeInterval = 0.7

    func updateVariable(_ newText: String) {
        // Update text
        text = newText

        // Reset timer
        dismissTimer?.invalidate()
        startDismissTimer()

        // If already visible, flash to indicate update
        if isVisible {
            withAnimation(.easeInOut(duration: 0.1)) {
                shouldFlash = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.shouldFlash = false
                }
            }
        } else {
            // Show if hidden
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }

    func hideOverlay() {
        dismissTimer?.invalidate()
        dismissTimer = nil

        withAnimation(.easeInOut(duration: 0.3)) {
            isVisible = false

        }
    }

    private func startDismissTimer() {
        dismissTimer = Timer.scheduledTimer(
            withTimeInterval: dismissDelay,
            repeats: false
        ) { [weak self] _ in
            DispatchQueue.main.async {
                PushUpSessionTracker.shared.soFar = 0
                self?.hideOverlay()
            }
        }
    }

    deinit {
        dismissTimer?.invalidate()
    }
}

// MARK: - Overlay View

struct VariableOverlayView: View {
    @ObservedObject var manager: VariableOverlayManager

    var body: some View {
        VStack {
            if manager.isVisible {
                Text(manager.text)
                    .font(.system(size: 120, weight: .medium))
                    .foregroundColor(.orange)

                    .opacity(manager.shouldFlash ? 0.7 : 1.0)
                    .scaleEffect(manager.isVisible ? 1.0 : 0.8)
                    .transition(
                        .asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        )
                    )
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.7),
                        value: manager.isVisible
                    )
                    .animation(
                        .easeInOut(duration: 0.1),
                        value: manager.shouldFlash
                    )
            }

            Spacer()
        }
        .padding(.top, 25)
        .allowsHitTesting(false)  // Allow touches to pass through
    }
}

// MARK: - Main Content View with Overlay

/*
struct ContentViewWithOverlay<Content: View>: View {
    let content: Content
    @StateObject private var overlayManager = VariableOverlayManager()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .environmentObject(overlayManager)

            VariableOverlayView(manager: overlayManager)
        }
    }
}
 */

/*
// MARK: - Usage Examples

struct FitnessAppView: View {
    @EnvironmentObject var overlayManager: VariableOverlayManager
    @State private var heartRate = 0
    @State private var speed = 0.0
    @State private var workoutTimer: Timer?

    var body: some View {
        VStack(spacing: 30) {
            Text("Fitness Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 20) {
                Button("Show/Update Heart Rate") {
                    overlayManager.updateVariable("Heart Rate: 142 BPM")
                }
                .buttonStyle(FitnessButtonStyle())

                Button("Update Heart Rate (Random)") {
                    let randomHeartRate = Int.random(in: 60...180)
                    overlayManager.updateVariable(
                        "Heart Rate: \(randomHeartRate) BPM"
                    )
                }
                .buttonStyle(FitnessButtonStyle())

                Button("Show/Update Speed") {
                    overlayManager.updateVariable("Speed: 8.5 mph")
                }
                .buttonStyle(FitnessButtonStyle())

                Button("Start Workout Simulation") {
                    startWorkoutSimulation()
                }
                .buttonStyle(FitnessButtonStyle(color: .green))

                Button("Stop Simulation") {
                    stopWorkoutSimulation()
                }
                .buttonStyle(FitnessButtonStyle(color: .red))

                Button("Hide Overlay") {
                    overlayManager.hideOverlay()
                }
                .buttonStyle(FitnessButtonStyle(color: .gray))
            }

            Spacer()
        }
        .padding()
    }

    private func startWorkoutSimulation() {
        stopWorkoutSimulation()  // Stop any existing timer

        workoutTimer = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: true
        ) { _ in
            let newHeartRate = Int.random(in: 120...180)
            let newSpeed = Double.random(in: 5.0...12.0)

            // Randomly update either heart rate or speed
            if Bool.random() {
                overlayManager.updateVariable("Heart Rate: \(newHeartRate) BPM")
            } else {
                overlayManager.updateVariable(
                    "Speed: \(String(format: "%.1f", newSpeed)) mph"
                )
            }
        }
    }

    private func stopWorkoutSimulation() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
}

// MARK: - Custom Button Style

struct FitnessButtonStyle: ButtonStyle {
    var color: Color = .blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(color)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(
                .easeInOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

// MARK: - Environment Object Access Helper

extension View {
    func showVariable(_ text: String) {
        // This would need to be called from within a view that has access to the environment object
        // Example usage is shown in the FitnessAppView above
    }
}

// MARK: - Alternative: Direct Usage Pattern

struct DirectUsageExample: View {
    @StateObject private var overlayManager = VariableOverlayManager()

    var body: some View {
        ZStack {
            VStack {
                Text("My Fitness App")
                    .font(.title)

                Button("Show/Update Distance") {
                    overlayManager.updateVariable("Distance: 2.5 miles")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            VariableOverlayView(manager: overlayManager)
        }
    }
}

// MARK: - App Entry Point

struct VariableOverlayApp: App {
    var body: some Scene {
        WindowGroup {
            ContentViewWithOverlay {
                FitnessAppView()
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewWithOverlay {
            FitnessAppView()
        }
    }
}
*/
