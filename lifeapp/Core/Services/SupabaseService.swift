import Foundation

final class SupabaseService {
    static let shared = SupabaseService()

    private init() {}

    // TODO: Wire supabase-swift client with Config/Secrets for remote sync.
    func fetchDailyMotivation(for day: Date) async throws -> (quote: String, source: String)? {
        _ = day
        return nil
    }
}
