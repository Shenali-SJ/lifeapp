import UIKit

enum NavigationBarAppearance {
    static func configure() {
        let warmCream = UIColor(red: 0.941, green: 0.902, blue: 0.851, alpha: 1)
        let forest = UIColor(red: 58 / 255, green: 90 / 255, blue: 64 / 255, alpha: 1)
        let hairline = forest.withAlphaComponent(0.15)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = warmCream
        appearance.backgroundEffect = nil
        appearance.shadowColor = hairline

        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.compactScrollEdgeAppearance = appearance
        navBar.tintColor = forest
        navBar.isTranslucent = false
    }
}
