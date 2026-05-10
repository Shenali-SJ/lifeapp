import Foundation
import Observation
import os

@MainActor
@Observable
final class DayPlannerViewModel {
    var plannedText = ""
    var didText = ""
    var tomorrowText = ""
    var dailyCompletion: Double = 0
    var weeklyCompletion: Double = 0
    var monthlyCompletion: Double = 0
    var errorMessage: String?

    private let logger = Logger(subsystem: AppConstants.appName, category: "DayPlannerViewModel")

    func load(entries: [DayPlanEntry]) async {
        do {
            let today = Date().startOfDayValue
            if let todayEntry = entries.first(where: { $0.day == today }) {
                plannedText = todayEntry.plannedText
                didText = todayEntry.didText
                tomorrowText = todayEntry.tomorrowText
            } else if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                      let yesterdayEntry = entries.first(where: { $0.day == yesterday.startOfDayValue }) {
                plannedText = yesterdayEntry.tomorrowText
            }
            calculateCompletion(entries: entries)
        } catch {
            logger.error("Failed loading planner entries: \(error.localizedDescription)")
            errorMessage = AppConstants.genericErrorMessage
        }
    }

    func calculateCompletion(entries: [DayPlanEntry]) {
        let sorted = entries.sorted(by: { $0.day > $1.day })
        dailyCompletion = completion(for: sorted.first)

        let recentWeek = Array(sorted.prefix(7))
        weeklyCompletion = averageCompletion(for: recentWeek)

        let recentMonth = Array(sorted.prefix(30))
        let grouped = Dictionary(grouping: recentMonth) { entry in
            Calendar.current.component(.weekOfYear, from: entry.day)
        }
        let weeklyAverages = grouped.values.map(averageCompletion)
        monthlyCompletion = weeklyAverages.isEmpty ? 0 : weeklyAverages.reduce(0, +) / Double(weeklyAverages.count)
    }

    private func completion(for entry: DayPlanEntry?) -> Double {
        guard let entry else { return 0 }
        let planned = Double(entry.plannedItems.count)
        guard planned > 0 else { return 0 }
        return (Double(entry.didItems.count) / planned) * 100
    }

    private func averageCompletion(for entries: [DayPlanEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0.0) { partial, entry in
            partial + completion(for: entry)
        }
        return total / Double(entries.count)
    }
}
