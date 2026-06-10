import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var dateTitle = ""
    var affirmationText = ""
    let userName = "Shenali"
    var errorMessage: String?

    func load() async {
        dateTitle = Self.formattedHeaderDate(for: Date())
    }

    /// e.g. `MONDAY, OCTOBER 23RD` — matches mockup date line.
    static func formattedHeaderDate(for date: Date) -> String {
        let cal = Calendar.current
        let day = cal.component(.day, from: date)
        let weekday = DateFormatter()
        weekday.locale = Locale(identifier: "en_US_POSIX")
        weekday.dateFormat = "EEEE"
        let month = DateFormatter()
        month.locale = Locale(identifier: "en_US_POSIX")
        month.dateFormat = "MMMM"
        let ord = ordinalSuffix(day)
        return "\(weekday.string(from: date).uppercased()), \(month.string(from: date).uppercased()) \(day)\(ord)"
    }

    private static func ordinalSuffix(_ n: Int) -> String {
        let tens = (n / 10) % 10
        let ones = n % 10
        if tens == 1 { return "TH" }
        switch ones {
        case 1: return "ST"
        case 2: return "ND"
        case 3: return "RD"
        default: return "TH"
        }
    }

    func formatTime(_ date: Date?) -> String {
        guard let date else { return "--:--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func formatGoalTime(_ date: Date?) -> String {
        guard let date else { return "--:--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        return formatter.string(from: date)
    }

    /// Compares wall-clock times on `referenceDay` so carry-forward goals still compare correctly to today's actual.
    func varianceDisplay(actual: Date?, goal: Date?, referenceDay: Date) -> (label: String, value: String) {
        guard let actual, let goal else { return ("", "--") }
        let cal = Calendar.current
        let base = referenceDay.startOfDayValue
        let goalHM = cal.dateComponents([.hour, .minute], from: goal)
        let actualHM = cal.dateComponents([.hour, .minute], from: actual)
        guard let goalOnDay = cal.date(bySettingHour: goalHM.hour ?? 0, minute: goalHM.minute ?? 0, second: 0, of: base),
              let actualOnDay = cal.date(bySettingHour: actualHM.hour ?? 0, minute: actualHM.minute ?? 0, second: 0, of: base)
        else { return ("", "--") }
        let diff = cal.dateComponents([.minute], from: goalOnDay, to: actualOnDay).minute ?? 0
        if diff == 0 {
            return ("", "Right on time ✓")
        } else if diff > 0 {
            return ("Behind goal by", formattedVariance(diff))
        } else {
            return ("Ahead of goal by", formattedVariance(abs(diff)))
        }
    }

    private func formattedVariance(_ minutes: Int) -> String {
        if minutes <= 59 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let remainder = minutes % 60
        if remainder == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(remainder)m"
    }

    func atomicHabits(brainGamesStreak: Int) -> [AtomicHabit] {
        [
            AtomicHabit(name: "Brain Games", streak: brainGamesStreak),
            AtomicHabit(name: "Hydration", streak: 0),
            AtomicHabit(name: "Reading", streak: 0)
        ]
    }
}

struct AtomicHabit: Identifiable {
    let id = UUID()
    let name: String
    let streak: Int
}
