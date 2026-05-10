import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestPermissionIfNeeded() async throws -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func scheduleWakeUpFeedback(for day: Date, gapMinutes: Int) async throws {
        _ = try await requestPermissionIfNeeded()
        let title = gapMinutes <= 0 ? AppConstants.wakeUpCloserTitle : AppConstants.wakeUpDriftingTitle
        let body = gapMinutes <= 0 ? "Keep going, your routine is improving." : "Small evening adjustments can help tomorrow."
        try await scheduleNotification(
            id: "wakeup-\(day.dayKey)",
            title: title,
            body: body,
            hour: 20,
            minute: 0
        )
    }

    func scheduleBrainGamesReminder(time: Date) async throws {
        _ = try await requestPermissionIfNeeded()
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        try await scheduleNotification(
            id: "brain-games-daily",
            title: AppConstants.brainGamesReminderTitle,
            body: AppConstants.brainGamesReminderBody,
            hour: comps.hour ?? 18,
            minute: comps.minute ?? 0
        )
    }

    func schedulePlannerReminder(time: Date) async throws {
        _ = try await requestPermissionIfNeeded()
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        try await scheduleNotification(
            id: "planner-evening",
            title: AppConstants.plannerReminderTitle,
            body: AppConstants.plannerReminderBody,
            hour: comps.hour ?? 20,
            minute: comps.minute ?? 30
        )
    }

    private func scheduleNotification(id: String, title: String, body: String, hour: Int, minute: Int) async throws {
        await center.removePendingNotificationRequests(withIdentifiers: [id])
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }
}
