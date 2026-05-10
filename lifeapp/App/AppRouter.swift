import SwiftUI

enum AppRoute: Hashable {
    case wakeUp
    case gratitude
    case goals
    case brainGames
    case dayPlanner
    case motivation
}

struct AppRouter: View {
    @State private var homePath = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack(path: $homePath) {
                HomeView(path: $homePath)
                    .tint(DesignSystem.Colors.primary)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .wakeUp: WakeUpView()
                        case .gratitude: GratitudeView()
                        case .goals: GoalsView()
                        case .brainGames: BrainGamesView()
                        case .dayPlanner: DayPlannerView()
                        case .motivation: MotivationView()
                        }
                    }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                DayPlannerView()
                    .tint(DesignSystem.Colors.primary)
            }
            .tabItem { Label("Plan", systemImage: "calendar") }

            NavigationStack {
                GoalsView()
                    .tint(DesignSystem.Colors.primary)
            }
            .tabItem { Label("Identity", systemImage: "person.fill") }

            NavigationStack {
                BrainGamesView()
                    .tint(DesignSystem.Colors.primary)
            }
            .tabItem { Label("Atomics", systemImage: "bolt.fill") }

            NavigationStack {
                MorePlaceholderView()
                    .tint(DesignSystem.Colors.primary)
            }
            .tabItem { Label("More", systemImage: "ellipsis") }
        }
    }
}
