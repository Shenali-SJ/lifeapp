import SwiftUI
import UIKit

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
    @State private var selectedTab = AppConstants.Tab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView(path: $homePath, selectedTab: $selectedTab)
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
            .tag(AppConstants.Tab.home)

            NavigationStack {
                DayPlannerView()
            }
            .tabItem { Label("Plan", systemImage: "calendar") }
            .tag(AppConstants.Tab.plan)

            NavigationStack {
                IdentityView()
            }
            .tabItem { Label("Identity", systemImage: "person.fill") }
            .tag(AppConstants.Tab.identity)

            NavigationStack {
                BrainGamesView()
            }
            .tabItem { Label("Atomics", systemImage: "bolt.fill") }
            .tag(AppConstants.Tab.atomics)

            NavigationStack {
                MorePlaceholderView()
            }
            .tabItem { Label("More", systemImage: "ellipsis") }
            .tag(AppConstants.Tab.more)
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 0.941, green: 0.902, blue: 0.851, alpha: 1.0)

            // Active tab — gold
            let activeColor = UIColor(red: 0.788, green: 0.659, blue: 0.298, alpha: 1.0)
            // Inactive tab — forest green at 45% opacity
            let inactiveColor = UIColor(red: 0.227, green: 0.353, blue: 0.251, alpha: 1.0)

            appearance.stackedLayoutAppearance.selected.iconColor = activeColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: activeColor]
            appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: inactiveColor]

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
