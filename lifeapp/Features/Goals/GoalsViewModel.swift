import Foundation
import Observation
import os

@MainActor
@Observable
final class GoalsViewModel {
    var goalsDraft = ""
    var identityDraft = ""
    var streak = 0
    var errorMessage: String?

    private let streakService = StreakService()
    private let logger = Logger(subsystem: AppConstants.appName, category: "GoalsViewModel")

    func load(entries: [GoalIdentityEntry]) async {
        do {
            streak = streakService.currentStreak(for: entries.map(\.day))
        } catch {
            logger.error("Failed loading goals entries: \(error.localizedDescription)")
            errorMessage = AppConstants.genericErrorMessage
        }
    }
}
