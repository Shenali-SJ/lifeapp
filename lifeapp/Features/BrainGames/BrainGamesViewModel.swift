import Foundation
import Observation
import os

@MainActor
@Observable
final class BrainGamesViewModel {
    var reminderTime = Date()
    var acknowledgedToday = false
    var errorMessage: String?

    private let logger = Logger(subsystem: AppConstants.appName, category: "BrainGamesViewModel")

    func load(entries: [BrainGameReminderState]) async {
        do {
            if let today = entries.first(where: { $0.day == Date().startOfDayValue }) {
                reminderTime = today.reminderTime
                acknowledgedToday = today.acknowledged
            }
        } catch {
            logger.error("Failed loading brain games state: \(error.localizedDescription)")
            errorMessage = AppConstants.genericErrorMessage
        }
    }
}
