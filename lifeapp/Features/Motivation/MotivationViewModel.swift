import Foundation
import Observation
import os

@MainActor
@Observable
final class MotivationViewModel {
    var quote = ""
    var source = ""
    var errorMessage: String?

    private let logger = Logger(subsystem: AppConstants.appName, category: "MotivationViewModel")
    private let fallbackQuotes: [(String, String)] = [
        ("Small progress every day compounds into big results.", "ALIGN"),
        ("Discipline is a vote for your future self.", "ALIGN"),
        ("Consistency beats intensity over the long run.", "ALIGN")
    ]

    func load(entry: DailyMotivationEntry?) async {
        do {
            if let entry {
                quote = entry.quote
                source = entry.source
            } else {
                let pick = fallbackQuotes.randomElement() ?? fallbackQuotes[0]
                quote = pick.0
                source = pick.1
            }
        } catch {
            logger.error("Failed loading motivation entry: \(error.localizedDescription)")
            errorMessage = AppConstants.genericErrorMessage
        }
    }
}
