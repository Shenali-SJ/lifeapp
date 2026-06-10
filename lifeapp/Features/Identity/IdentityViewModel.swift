import Foundation
import Observation

@MainActor
@Observable
final class IdentityViewModel {
    static let maxStatements = 10
    static let characterLimit = 100
    static let characterWarningThreshold = 20

    var draftText = ""
    var errorMessage: String?

    func remainingCharacters(for text: String) -> Int {
        Self.characterLimit - text.count
    }

    func shouldShowRemainingCount(for text: String) -> Bool {
        remainingCharacters(for: text) < Self.characterWarningThreshold
    }

    func sanitizedText(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return String(trimmed.prefix(Self.characterLimit))
    }

    func canSave(raw: String) -> Bool {
        sanitizedText(raw) != nil
    }

    func nextOrder(in statements: [IdentityStatement]) -> Int {
        (statements.map(\.order).max() ?? -1) + 1
    }

    static func homeDisplayText(from statements: [IdentityStatement], on date: Date = Date()) -> String {
        guard let statement = homeDisplayStatement(from: statements, on: date) else {
            return "Who are you becoming?"
        }
        return statement.text
    }

    static func homeDisplayStatement(
        from statements: [IdentityStatement],
        on date: Date = Date()
    ) -> IdentityStatement? {
        guard !statements.isEmpty else { return nil }
        let sorted = statements.sorted { $0.order < $1.order }
        if sorted.count == 1 { return sorted[0] }
        let seed = UInt64(date.startOfDayValue.timeIntervalSince1970)
        var generator = SeededRandomNumberGenerator(seed: seed)
        let index = Int.random(in: 0..<sorted.count, using: &generator)
        return sorted[index]
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1
        return state
    }
}
