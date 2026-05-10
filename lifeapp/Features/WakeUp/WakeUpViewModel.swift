import Foundation
import Observation
import os

@MainActor
@Observable
final class WakeUpViewModel {
    var selectedActualTime = Date()
    var selectedGoalTime = Date()
    var notificationsEnabled = false
    var trend: WakeUpTrend = .stable
    var errorMessage: String?

    private let logger = Logger(subsystem: AppConstants.appName, category: "WakeUpViewModel")

    func load(from entries: [WakeUpEntry]) async {
        do {
            if let todayEntry = entries.first(where: { $0.day == Date().startOfDayValue }) {
                selectedActualTime = todayEntry.actualWakeTime ?? selectedActualTime
                selectedGoalTime = todayEntry.goalWakeTime ?? selectedGoalTime
                notificationsEnabled = todayEntry.notificationsEnabled
            }
            trend = calculateTrend(entries: entries)
        } catch {
            logger.error("Failed loading wake-up data: \(error.localizedDescription)")
            errorMessage = AppConstants.genericErrorMessage
        }
    }

    func calculateTrend(entries: [WakeUpEntry]) -> WakeUpTrend {
        let recent = entries
            .sorted(by: { $0.day > $1.day })
            .prefix(7)
            .compactMap { entry -> Int? in
                guard let actual = entry.actualWakeTime, let goal = entry.goalWakeTime else { return nil }
                return Calendar.current.dateComponents([.minute], from: goal, to: actual).minute
            }

        guard recent.count >= 3 else { return .stable }
        let avg = Double(recent.reduce(0, +)) / Double(recent.count)
        if avg <= -5 { return .improving }
        if avg >= 5 { return .declining }
        return .stable
    }
}
