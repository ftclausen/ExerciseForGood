//
//  TodayView.swift
//  ExerciseForGood
//
//  Created by Fred Clausen on 22/6/2025.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var pushUpManager = PushUpManager()
    @State private var todaysPushUps: PushUpDay?
    
    @State private var lastLocation: CGPoint = .zero
    @State private var currentAngle: Double = 0
    @State private var lastAngle: Double = 0
    @State private var accumulatedRotation: Double = 0
    
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
                        )
                    }
                    
                    BadgeRowView(badgeLevel: today.badgeLevel)
                        .padding(.top, 40)
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
                    today.completed = max(0, today.completed - 10)
                    
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            )
            .simultaneousGesture(
                // Single tap gesture to add 10 push-ups
                TapGesture()
                    .onEnded {
                        guard let today = todaysPushUps, !today.isRestDay else { return }
                        today.completed += 10
                        
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
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
                                } else { // Counter-clockwise - subtract push-ups
                                    today.completed = max(0, today.completed - increment)
                                }
                                
                                // Reset accumulated rotation after action
                                accumulatedRotation = 0
                            }
                        }
                        
                        lastLocation = location
                        lastAngle = currentAngle
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
        }
        .onAppear {
            loadTodaysPushUps()
        }
    }
    
    private func loadTodaysPushUps() {
        todaysPushUps = pushUpManager.getTodaysPushUps(modelContext: modelContext)
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
    
    var body: some View {
        VStack {
            Text("Day \(Calendar.current.component(.day, from: pushUpDay.date))")
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
