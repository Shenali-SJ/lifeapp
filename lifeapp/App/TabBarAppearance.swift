import UIKit

enum TabBarAppearance {
    static func configure() {
        let bg = UIColor(red: 247 / 255, green: 250 / 255, blue: 244 / 255, alpha: 0.96)
        let primary = UIColor(red: 0x42 / 255, green: 0x64 / 255, blue: 0x47 / 255, alpha: 1)
        let muted = UIColor(red: 88 / 255, green: 82 / 255, blue: 74 / 255, alpha: 0.7)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bg
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.08)

        let item = UITabBarItemAppearance()
        item.normal.iconColor = muted
        item.normal.titleTextAttributes = [.foregroundColor: muted]
        item.selected.iconColor = primary
        item.selected.titleTextAttributes = [.foregroundColor: primary]
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().tintColor = primary
        UITabBar.appearance().unselectedItemTintColor = muted
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
