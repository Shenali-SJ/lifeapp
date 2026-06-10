import SwiftData
import SwiftUI

@main
struct AppEntry: App {
    init() {
        NavigationBarAppearance.configure()
    }

    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingSplash = true
    @State private var hasBootstrapped = false

    private var container: ModelContainer = {
        let schema = Schema([
            WakeUpEntry.self,
            GratitudeEntry.self,
            GoalIdentityEntry.self,
            IdentityStatement.self,
            BrainGameReminderState.self,
            DayPlanEntry.self,
            DailyMotivationEntry.self
        ])

        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let storeURL = appSupportURL.appendingPathComponent("default.store")
            let configuration = ModelConfiguration(schema: schema, url: storeURL)
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            do {
                // Fallback prevents launch failure if simulator file system is temporarily inconsistent.
                let inMemoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: [inMemoryConfiguration])
            } catch {
                fatalError("Failed to create model container: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppRouter()
                    .opacity(isShowingSplash ? 0 : 1)

                if isShowingSplash {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isShowingSplash = false
                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isShowingSplash)
            .onAppear {
                guard !hasBootstrapped else { return }
                hasBootstrapped = true
                isShowingSplash = true
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active, hasBootstrapped, !isShowingSplash {
                    isShowingSplash = true
                }
            }
        }
        .modelContainer(container)
    }
}
