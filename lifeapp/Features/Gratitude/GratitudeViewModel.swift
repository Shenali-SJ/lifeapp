import Foundation
import Observation
import os

@MainActor
@Observable
final class GratitudeViewModel {
    var draft = ""
    var streak = 0
    var errorMessage: String?

    private let streakService = StreakService()
    private let logger = Logger(subsystem: AppConstants.appName, category: "GratitudeViewModel")

    func load(entries: [GratitudeEntry]) async {
        do {
            streak = streakService.currentStreak(for: entries.map(\.day))
        } catch {
            logger.error("Failed loading gratitude entries: \(error.localizedDescription)")
            errorMessage = AppConstants.genericErrorMessage
        }
    }
}
