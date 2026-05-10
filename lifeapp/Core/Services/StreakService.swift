import Foundation

struct StreakService {
    func currentStreak(for days: [Date], today: Date = .now) -> Int {
        let sortedUnique = Array(Set(days.map(\.startOfDayValue))).sorted(by: >)
        guard !sortedUnique.isEmpty else { return 0 }

        var streak = 0
        var cursor = today.startOfDayValue
        for day in sortedUnique {
            if day == cursor {
                streak += 1
                cursor = Calendar.current.date(byAdding: .day, value: -1, to: cursor) ?? cursor
            } else if day > cursor {
                continue
            } else {
                break
            }
        }

        return streak
    }
}
