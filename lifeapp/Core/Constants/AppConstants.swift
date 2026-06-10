import Foundation

enum AppConstants {
    static let appName = "ALIGN"
    static let splashTagline = "ROME WASN'T BUILT IN A DAY"
    static let supabaseURL = "SUPABASE_URL_PLACEHOLDER"
    static let supabaseAnonKey = "SUPABASE_ANON_KEY_PLACEHOLDER"

    static let wakeUpCloserTitle = "You're getting closer to your goal"
    static let wakeUpDriftingTitle = "You're drifting from your goal"

    static let brainGamesReminderTitle = "Brain game time"
    static let brainGamesReminderBody = "A short challenge keeps your mind sharp."

    static let plannerReminderTitle = "Plan tomorrow today"
    static let plannerReminderBody = "Set up your tomorrow plan this evening."

    static let genericErrorMessage = "Something went wrong. Please try again."

    enum Tab {
        static let home = 0
        static let plan = 1
        static let identity = 2
        static let atomics = 3
        static let more = 4
    }
}
