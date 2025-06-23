//
//  ProgressView.swift
//  ExerciseForGood
//
//  Created by Fred Clausen on 22/6/2025.
//

import SwiftUI
import SwiftData

struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentMonth = Date()
    @State private var monthlyData: [PushUpDay] = []
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack {
                // Month navigation header
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                    .disabled(isCurrentOrFutureMonth)
                }
                .padding()
                
                // Table header
                HStack {
                    Text("Day")
                        .frame(width: 60, alignment: .leading)
                    Text("Target")
                        .frame(width: 80, alignment: .center)
                    Text("Banked")
                        .frame(width: 80, alignment: .center)
                    Text("Badge")
                        .frame(width: 60, alignment: .center)
                }
                .font(.headline)
                .foregroundColor(.orange)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Divider()
                    .background(Color.gray)
                
                // Table content
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(monthlyData.sorted(by: { $0.date < $1.date }), id: \.date) { day in
                            MonthlyRowView(pushUpDay: day)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
            .background(Color.black)
            .navigationBarHidden(true)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        previousMonth()
                    } else if value.translation.height < -100 {
                        if !isCurrentOrFutureMonth {
                            nextMonth()
                        }
                    }
                }
        )
        .onAppear {
            loadMonthlyData()
        }
        .onChange(of: currentMonth) { _ in
            loadMonthlyData()
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var isCurrentOrFutureMonth: Bool {
        let currentMonthComponents = calendar.dateComponents([.year, .month], from: Date())
        let selectedMonthComponents = calendar.dateComponents([.year, .month], from: currentMonth)
        
        guard let currentDate = calendar.date(from: currentMonthComponents),
              let selectedDate = calendar.date(from: selectedMonthComponents) else {
            return true
        }
        
        return selectedDate >= currentDate
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        guard !isCurrentOrFutureMonth else { return }
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func loadMonthlyData() {
        let monthComponents = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let startOfMonth = calendar.date(from: monthComponents),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return
        }
        
        let request = FetchDescriptor<PushUpDay>(
            predicate: #Predicate { pushUpDay in
                pushUpDay.date >= startOfMonth && pushUpDay.date <= endOfMonth
            }
        )
        
        do {
            monthlyData = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch monthly data: \(error)")
            monthlyData = []
        }
    }
}

struct MonthlyRowView: View {
    let pushUpDay: PushUpDay
    
    private var dayNumber: String {
        String(Calendar.current.component(.day, from: pushUpDay.date))
    }
    
    var body: some View {
        HStack {
            // Day
            Text(dayNumber)
                .frame(width: 60, alignment: .leading)
                .foregroundColor(.white)
            
            // Target
            Text(pushUpDay.isRestDay ? "Rest" : "\(pushUpDay.target)")
                .frame(width: 80, alignment: .center)
                .foregroundColor(pushUpDay.isRestDay ? .gray : .white)
            
            // Completed (Banked)
            Text(pushUpDay.isRestDay ? "-" : "\(pushUpDay.completed)")
                .frame(width: 80, alignment: .center)
                .foregroundColor(pushUpDay.isRestDay ? .gray : .white)
            
            // Badge
            if pushUpDay.isRestDay {
                Text("-")
                    .frame(width: 60, alignment: .center)
                    .foregroundColor(.gray)
            } else {
                BadgeIndicatorView(badgeLevel: pushUpDay.badgeLevel)
                    .frame(width: 60, alignment: .center)
            }
        }
        .padding(.horizontal)
        .background(
            Rectangle()
                .fill(Color.clear)
                .background(
                    // Subtle row separator
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
}

struct BadgeIndicatorView: View {
    let badgeLevel: BadgeLevel
    
    var body: some View {
        if badgeLevel != .none {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 30, height: 30)
                
                Text(badgeLevel.displayText)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
        } else {
            Text("-")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ProgressView()
        .modelContainer(for: PushUpDay.self, inMemory: true)
}
