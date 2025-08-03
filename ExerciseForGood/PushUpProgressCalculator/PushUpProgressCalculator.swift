import Foundation

struct PushUpProgressCalculator {
    // MARK: - Properties
    let dailyTarget: Int
    let startHour: Int
    let endHour: Int
    
    // MARK: - Calculated Properties
    /// Total minutes in the active period (e.g., 8am to 11pm = 900 minutes)
    var totalMinutes: Int {
        (endHour - startHour) * 60
    }
    
    /// Push-ups needed per minute to reach target
    var pushUpsPerMinute: Double {
        Double(dailyTarget) / Double(totalMinutes)
    }
    
    // MARK: - Initializer
    init(dailyTarget: Int, startHour: Int = 8, endHour: Int = 21) {
        self.dailyTarget = dailyTarget
        self.startHour = startHour
        self.endHour = endHour
    }
    
    // MARK: - Methods
    
    /// Calculate how many push-ups should be completed by the given time
    /// - Parameter currentTime: The current time as a Date
    /// - Returns: Expected number of push-ups (rounded to nearest integer), or nil if outside active hours
    func expectedPushUps(at currentTime: Date) -> Int? {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        
        return expectedPushUps(atHour: hour, minute: minute)
    }
    
    /// Calculate how many push-ups should be completed by the given time
    /// - Parameters:
    ///   - hour: Hour in 24-hour format (0-23)
    ///   - minute: Minute (0-59)
    /// - Returns: Expected number of push-ups (rounded to nearest integer), or nil if outside active hours
    func expectedPushUps(atHour hour: Int, minute: Int) -> Int? {
        // Check if time is within active period
        guard hour >= startHour && hour < endHour else {
            if hour >= endHour {
                // After end time, should have completed full target
                return dailyTarget
            } else {
                // Before start time, should be at 0
                return 0
            }
        }
        
        let minutesPassed = (hour - startHour) * 60 + minute
        let expectedPushUps = Double(minutesPassed) * pushUpsPerMinute
        
        return Int(expectedPushUps.rounded())
    }
    
    /// Calculate progress percentage (0.0 to 1.0)
    /// - Parameters:
    ///   - completed: Number of push-ups completed so far
    ///   - currentTime: Current time
    /// - Returns: Progress as a percentage (0.0 = 0%, 1.0 = 100%), or nil if outside active hours
    func progressPercentage(completed: Int, at currentTime: Date) -> Double? {
        guard let expected = expectedPushUps(at: currentTime) else { return nil }
        guard expected > 0 else { return completed > 0 ? 1.0 : 0.0 }
        
        return min(Double(completed) / Double(expected), 1.0)
    }
    
    /// Check if user is on track to meet their daily target
    /// - Parameters:
    ///   - completed: Number of push-ups completed so far
    ///   - currentTime: Current time
    /// - Returns: True if on track or ahead, false if behind, nil if outside active hours
    func isOnTrack(completed: Int, at currentTime: Date) -> Bool? {
        guard let expected = expectedPushUps(at: currentTime) else { return nil }
        return completed >= expected
    }
}

// MARK: - Usage Examples
extension PushUpProgressCalculator {
    /// Get a user-friendly status string
    func statusString(completed: Int, at currentTime: Date) -> String {
        guard let expected = expectedPushUps(at: currentTime) else {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: currentTime)
            
            if hour < startHour {
                return "Workout starts at \(startHour):00"
            } else {
                return "Daily target: \(dailyTarget) (Complete!)"
            }
        }
        
        let difference = completed - expected
        if difference >= 0 {
            return "On track! (\(difference) ahead)"
        } else {
            return "Behind by \(-difference) push-ups"
        }
    }
}
