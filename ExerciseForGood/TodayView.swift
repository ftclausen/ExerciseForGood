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
    
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    
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
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dragDistance = value.translation.height - lastDragValue
                        let dragSpeed = abs(dragDistance)
                        
                        var increment: Int
                        if dragSpeed > 20 {
                            increment = 10
                        } else if dragSpeed > 5 {
                            increment = 5
                        } else {
                            increment = 1
                        }
                        
                        if dragDistance < -2 { // Drag up - add push-ups
                            pushUpDay.completed += increment
                            lastDragValue = value.translation.height
                            
                            // Haptic feedback
                            // let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            // impactFeedback.impactOccurred()
                        } else if dragDistance > 2 { // Drag down - subtract push-ups
                            pushUpDay.completed = max(0, pushUpDay.completed - increment)
                            lastDragValue = value.translation.height
                            
                            // Haptic feedback
                            // let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            // impactFeedback.impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        lastDragValue = 0
                    }
            )
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

#Preview {
    TodayView()
        .modelContainer(for: PushUpDay.self, inMemory: true)
}
