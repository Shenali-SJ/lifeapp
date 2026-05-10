import Foundation
import SwiftData

enum WakeUpTrend: String, Codable, CaseIterable {
    case improving
    case declining
    case stable
}

@Model
final class WakeUpEntry {
    var day: Date
    var actualWakeTime: Date?
    var goalWakeTime: Date?
    var trendRaw: String
    var notificationsEnabled: Bool

    init(
        day: Date,
        actualWakeTime: Date? = nil,
        goalWakeTime: Date? = nil,
        trend: WakeUpTrend = .stable,
        notificationsEnabled: Bool = false
    ) {
        self.day = day.startOfDayValue
        self.actualWakeTime = actualWakeTime
        self.goalWakeTime = goalWakeTime
        self.trendRaw = trend.rawValue
        self.notificationsEnabled = notificationsEnabled
    }

    var trend: WakeUpTrend {
        get { WakeUpTrend(rawValue: trendRaw) ?? .stable }
        set { trendRaw = newValue.rawValue }
    }

    var description: String {
        "WakeUpEntry(\(day.dayKey), trend: \(trendRaw))"
    }
}

@Model
final class GratitudeEntry {
    var day: Date
    var text: String

    init(day: Date, text: String) {
        self.day = day.startOfDayValue
        self.text = text
    }

    var description: String { "GratitudeEntry(\(day.dayKey))" }
}

@Model
final class GoalIdentityEntry {
    var day: Date
    var goalsText: String
    var identityText: String

    init(day: Date, goalsText: String, identityText: String) {
        self.day = day.startOfDayValue
        self.goalsText = goalsText
        self.identityText = identityText
    }

    var description: String { "GoalIdentityEntry(\(day.dayKey))" }
}

@Model
final class BrainGameReminderState {
    var day: Date
    var reminderTime: Date
    var acknowledged: Bool

    init(day: Date, reminderTime: Date, acknowledged: Bool = false) {
        self.day = day.startOfDayValue
        self.reminderTime = reminderTime
        self.acknowledged = acknowledged
    }

    var description: String { "BrainGameReminderState(\(day.dayKey), ack: \(acknowledged))" }
}

@Model
final class DayPlanEntry {
    var day: Date
    var plannedText: String
    var didText: String
    var tomorrowText: String

    init(day: Date, plannedText: String = "", didText: String = "", tomorrowText: String = "") {
        self.day = day.startOfDayValue
        self.plannedText = plannedText
        self.didText = didText
        self.tomorrowText = tomorrowText
    }

    var plannedItems: [String] { plannedText.lines }
    var didItems: [String] { didText.lines }
    var tomorrowItems: [String] { tomorrowText.lines }

    var description: String { "DayPlanEntry(\(day.dayKey))" }
}

@Model
final class DailyMotivationEntry {
    var day: Date
    var quote: String
    var source: String

    init(day: Date, quote: String, source: String) {
        self.day = day.startOfDayValue
        self.quote = quote
        self.source = source
    }

    var description: String { "DailyMotivationEntry(\(day.dayKey))" }
}

private extension String {
    var lines: [String] {
        split(separator: "\n").map { String($0) }.filter { !$0.isEmpty }
    }
}
