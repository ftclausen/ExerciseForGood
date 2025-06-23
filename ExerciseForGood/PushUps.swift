//
//  PushUps.swift
//  ExerciseForGood
//
//  Created by Fred Clausen on 22/6/2025.
//

import Foundation
import SwiftData

@Model
final class PushUpDay {
    var date: Date
    var target: Int
    var completed: Int
    var isRestDay: Bool
    
    init(date: Date, target: Int = 0, completed: Int = 0, isRestDay: Bool = false) {
        self.date = date
        self.target = target
        self.completed = completed
        self.isRestDay = isRestDay
    }
    
    var progressPercentage: Double {
        guard target > 0 else { return 0 }
        return Double(completed) / Double(target)
    }
    
    var badgeLevel: BadgeLevel {
        let percentage = progressPercentage
        if percentage >= 1.0 { return .complete }
        else if percentage >= 0.75 { return .seventyFive }
        else if percentage >= 0.5 { return .fifty }
        else if percentage >= 0.25 { return .twentyFive }
        else { return .none }
    }
}

enum BadgeLevel: Int, CaseIterable {
    case none = 0
    case twentyFive = 25
    case fifty = 50
    case seventyFive = 75
    case complete = 100
    
    var displayText: String {
        switch self {
        case .none: return ""
        case .twentyFive: return "25%"
        case .fifty: return "50%"
        case .seventyFive: return "75%"
        case .complete: return "100%"
        }
    }
}

class PushUpManager: ObservableObject {
    @Published var todaysPushUps: PushUpDay?
    
    private let calendar = Calendar.current
    
    init() {
        // Initialize will be called from the main app
    }
    
    func getTodaysPushUps(modelContext: ModelContext) -> PushUpDay {
        let today = calendar.startOfDay(for: Date())
        
        // Try to find existing record for today
        let request = FetchDescriptor<PushUpDay>(
            predicate: #Predicate { $0.date == today }
        )
        
        if let existing = try? modelContext.fetch(request).first {
            return existing
        }
        
        // Create new record for today
        let isRestDay = calendar.component(.weekday, from: today) == 1 // Sunday
        let target = isRestDay ? 0 : Int.random(in: 70...230)
        
        let newDay = PushUpDay(date: today, target: target, isRestDay: isRestDay)
        modelContext.insert(newDay)
        
        return newDay
    }
    
    func addPushUps(_ count: Int, to day: PushUpDay) {
        day.completed = max(0, day.completed + count)
    }
}