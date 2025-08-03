//
//  TodayView.swift
//  ExerciseForGood
//
//  Created by Fred Clausen on 22/6/2025.
//

import SwiftUI
import SwiftData
import os.log

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var pushUpManager = PushUpManager()
    @State private var todaysPushUps: PushUpDay?
    @State private var currentDate = Date()

    @State private var lastLocation: CGPoint = .zero
    @State private var currentAngle: Double = 0
    @State private var lastAngle: Double = 0
    @State private var accumulatedRotation: Double = 0

    @State private var showConfetti: Bool = false
    @State private var confettiAlreadyShown: Bool = false

    private let logger = Logger(subsystem: "uk.derfcloud.ExerciseForGood", category: "TodayView")
    private var incrementAmount = 10

    @StateObject var overlayManager = VariableOverlayManager()

    // var pushUpSession: PushUpSessionTracker

    var body: some View {

        GeometryReader { geometry in
            VStack {
                Spacer()

                if let today = todaysPushUps {
                    if today.isRestDay {
                        RestDayView()
                    } else {
                        CircularProgressView(
                            pushUpDay: today,
                            size: min(geometry.size.width, geometry.size.height) * 0.6
                        ).padding(.top, 60)
                    }

                    BadgeRowView(badgeLevel: today.badgeLevel)
                        .padding(.top, 90)
                } else {
                    ProgressView()
                        .scaleEffect(2)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .overlay(
                TwoFingerTapView {
                    guard let today = todaysPushUps, !today.isRestDay else { return }
                    let oldCompleted = today.completed
                    today.completed = max(0, today.completed - incrementAmount)
                    let actualDecrease = oldCompleted - today.completed
                    PushUpSessionTracker.shared.soFar -= actualDecrease
                    overlayManager.updateVariable("\(PushUpSessionTracker.shared.soFar)")

                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            )
            .simultaneousGesture(
                // Single tap gesture to add 10 push-ups
                TapGesture()
                    .onEnded {
                        guard let today = todaysPushUps, !today.isRestDay else { return }
                        today.completed += incrementAmount
                        PushUpSessionTracker.shared.soFar += incrementAmount
                        overlayManager.updateVariable("+\(PushUpSessionTracker.shared.soFar)")

                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        showConfettiIfRequired(today: today)
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard let today = todaysPushUps, !today.isRestDay else { return }

                        let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
                        let location = CGPoint(
                            x: value.location.x - center.x,
                            y: value.location.y - center.y
                        )

                        // Calculate angle from center
                        currentAngle = atan2(location.y, location.x)

                        if lastLocation != .zero {
                            // Calculate angle difference
                            var angleDiff = currentAngle - lastAngle

                            // Handle angle wrapping around -π to π
                            if angleDiff > .pi {
                                angleDiff -= 2 * .pi
                            } else if angleDiff < -.pi {
                                angleDiff += 2 * .pi
                            }

                            accumulatedRotation += angleDiff

                            // Determine increment based on rotation speed
                            let rotationSpeed = abs(angleDiff)
                            var increment: Int
                            if rotationSpeed > 0.3 {
                                increment = 10
                            } else if rotationSpeed > 0.1 {
                                increment = 5
                            } else {
                                increment = 1
                            }

                            // Check for significant rotation to trigger action
                            if abs(accumulatedRotation) > 0.2 {
                                if accumulatedRotation > 0 { // Clockwise - add push-ups
                                    today.completed += increment

                                    PushUpSessionTracker.shared.soFar += increment
                                    overlayManager.updateVariable("+\(PushUpSessionTracker.shared.soFar)")
                                } else { // Counter-clockwise - subtract push-ups
                                    let oldCompleted = today.completed
                                    today.completed = max(0, today.completed - increment)
                                    let actualDecrease = oldCompleted - today.completed

                                    PushUpSessionTracker.shared.soFar -= actualDecrease
                                    overlayManager.updateVariable("\(PushUpSessionTracker.shared.soFar)")
                                }

                                // Reset accumulated rotation after action
                                accumulatedRotation = 0
                            }
                        }

                        lastLocation = location
                        lastAngle = currentAngle

                        showConfettiIfRequired(today: today)
                    }
                    .onEnded { _ in
                        guard let today = todaysPushUps, !today.isRestDay else { return }

                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()

                        // Reset all tracking variables
                        lastLocation = .zero
                        currentAngle = 0
                        lastAngle = 0
                        accumulatedRotation = 0
                    }
            )
            .displayConfetti(isActive: $showConfetti)
            .overlay(
                VariableOverlayView(manager: overlayManager)
            )
        }
        .onAppear {
            loadTodaysPushUps()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkForNewDay()
        }
    }

    private func loadTodaysPushUps() {
        todaysPushUps = pushUpManager.getTodaysPushUps(modelContext: modelContext)
        currentDate = Date()
        confettiAlreadyShown = false
        showConfetti = false
    }

    private func checkForNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastKnownDay = Calendar.current.startOfDay(for: currentDate)

        if today != lastKnownDay {
            loadTodaysPushUps()
        }
    }

    private func showConfettiIfRequired(today: PushUpDay) {
        if today.completed >= today.target && !confettiAlreadyShown {
            showConfetti = true
            confettiAlreadyShown = true
        }
    }
}

struct RestDayView: View {
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 250, height: 250)

                Text("Rest Day")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

struct CircularProgressView: View {
    @ObservedObject var pushUpDay: PushUpDay
    let size: CGFloat

    private var progressCalculator: PushUpProgressCalculator {
        PushUpProgressCalculator(dailyTarget: pushUpDay.target)
    }

    private var expectedProgress: Double {
        guard !pushUpDay.isRestDay,
              let expected = progressCalculator.expectedPushUps(at: Date()) else { return 0 }
        return Double(expected) / Double(pushUpDay.target)
    }

    private var isAheadOfSchedule: Bool {
        progressCalculator.isOnTrack(completed: pushUpDay.completed, at: Date()) ?? false
    }

    var body: some View {
        VStack {
            Text(getTodayDateString())
                .font(.title2)
                .foregroundColor(.white)
                .padding(.bottom, 20)

            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                    .frame(width: size, height: size)

                // Progress circle
                Circle()
                    .trim(from: 0, to: min(pushUpDay.progressPercentage, 1.0))
                    .stroke(
                        Color.orange,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: size, height: size)
                    .animation(.easeInOut(duration: 0.3), value: pushUpDay.progressPercentage)

                // Over-progress circle (for >100%)
                if pushUpDay.progressPercentage > 1.0 {
                    Circle()
                        .trim(from: 0, to: min(pushUpDay.progressPercentage - 1.0, 1.0))
                        .stroke(
                            Color.orange.opacity(0.6),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: size - 20, height: size - 20)
                        .animation(.easeInOut(duration: 0.3), value: pushUpDay.progressPercentage)
                }

                // Expected progress indicator dot
                if !pushUpDay.isRestDay && expectedProgress > 0 && expectedProgress <= 1.0 {
                    let angle = expectedProgress * 360 - 90 // Adjust for starting at top
                    let radius = size / 2
                    let dotX = radius * cos(angle * .pi / 180)
                    let dotY = radius * sin(angle * .pi / 180)

                    Circle()
                        .fill(isAheadOfSchedule ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                        .offset(x: dotX, y: dotY)
                        .animation(.easeInOut(duration: 0.3), value: expectedProgress)
                }

                // Center content
                VStack {
                    Text("\(pushUpDay.completed)")
                        .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Complete")
                        .font(.title3)
                        .foregroundColor(.orange)
                        .padding(.bottom, 8)

                    Text("Target: \(pushUpDay.target)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func getTodayDateString() -> String {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal
        let ordinalDay = ordinalFormatter.string(from: NSNumber(value: day)) ?? "\(day)"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let monthYear = dateFormatter.string(from: date)

        return "\(ordinalDay) \(monthYear)"
    }
}

struct BadgeRowView: View {
    let badgeLevel: BadgeLevel

    var body: some View {
        HStack(spacing: 20) {
            ForEach([BadgeLevel.twentyFive, .fifty, .seventyFive, .complete], id: \.rawValue) { level in
                BadgeView(
                    level: level,
                    isEarned: badgeLevel.rawValue >= level.rawValue
                )
            }
        }
    }
}

struct BadgeView: View {
    let level: BadgeLevel
    let isEarned: Bool

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isEarned ? Color.orange : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)

                Image(systemName: "shield.fill")
                    .font(.title2)
                    .foregroundColor(isEarned ? .black : .gray)
            }

            Text(level.displayText)
                .font(.caption)
                .foregroundColor(isEarned ? .orange : .gray)
        }
    }
}

struct TwoFingerTapView: UIViewRepresentable {
    let onTwoFingerTap: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear

        let twoFingerTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTwoFingerTap))
        twoFingerTap.numberOfTouchesRequired = 2
        twoFingerTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(twoFingerTap)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onTwoFingerTap: onTwoFingerTap)
    }

    class Coordinator: NSObject {
        let onTwoFingerTap: () -> Void

        init(onTwoFingerTap: @escaping () -> Void) {
            self.onTwoFingerTap = onTwoFingerTap
        }

        @objc func handleTwoFingerTap() {
            onTwoFingerTap()
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: PushUpDay.self, inMemory: true)
}
