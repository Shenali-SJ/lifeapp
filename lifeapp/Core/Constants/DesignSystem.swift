import SwiftUI

enum DesignSystem {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        /// ~25% increase vs prior scale
        static let md: CGFloat = 15
        static let lg: CGFloat = 20
        static let xl: CGFloat = 30
        static let xxl: CGFloat = 32
        /// ~30% increase — main section rhythm
        static let section: CGFloat = 40
        static let screenHorizontal: CGFloat = 24
    }

    enum CornerRadius {
        static let button: CGFloat = 10
        static let card: CGFloat = 14
        static let hero: CGFloat = 16
    }

    /// Warm editorial palette: warm ground, forest green, gold emphasis, white cards.
    enum Colors {
        /// Cool off-white — legacy screens; prefer `warmCream` for app chrome.
        static let paletteBackground = Color(red: 247 / 255, green: 250 / 255, blue: 244 / 255)
        /// Root / scroll background `#F0E6D3`
        static let warmCream = Color(red: 0.941, green: 0.902, blue: 0.851)
        /// Reward / emphasis accent `#C9A84C`
        static let gold = Color(red: 0.788, green: 0.659, blue: 0.298)
        /// Primary forest green `#3A5A40`
        static let primary = Color(red: 0x3A / 255, green: 0x5A / 255, blue: 0x40 / 255)
        static let accent = primary
        /// Mint accent `#C6ECC8` — chips, subtle highlights
        static let mintAccent = Color(red: 0xC6 / 255, green: 0xEC / 255, blue: 0xC8 / 255)
        /// Slightly warmer mint for icon chips (organic, not tech)
        static let mintIconBackground = mintAccent
        /// Card surface — very light warm white (softer than `#FFFFFF` on `warmCream`)
        static let cardBackground = Color(red: 0.98, green: 0.97, blue: 0.96)
        static let secondaryText = Color(red: 88 / 255, green: 82 / 255, blue: 74 / 255)
        static let borderSubtle = primary.opacity(0.1)
        static let varianceLate = Color(red: 130 / 255, green: 52 / 255, blue: 48 / 255)
        static let success = primary
        static let warning = Color.orange
        /// Wake-up circle stroke — matches primary forest green
        static let wakeCircle = primary
    }

    /// Soft card shadow — `radius: 8`, low contrast (warm editorial).
    enum Shadow {
        static let cardRadius: CGFloat = 8
        static let cardOpacity: Double = 0.06
        static let cardY: CGFloat = 4
    }

    /// Georgia (system-bundled on iOS). Weights kept light for a magazine-style editorial voice — avoid Georgia-Bold.
    enum EditorialFont {
        static func georgia(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            Font.custom("Georgia", size: size).weight(weight)
        }

        static func georgiaItalic(_ size: CGFloat) -> Font {
            Font.custom("Georgia-Italic", size: size)
        }

        /// Small caps line — crisp but not loud
        static let dateCaps = georgia(12, weight: .semibold)
        /// Main hero greeting — magazine headline, not billboard
        static let greeting = georgia(38, weight: .semibold)
        static let affirmation = georgiaItalic(19)
        static let affirmationPrompt = georgiaItalic(19)
        /// Card headline (e.g. Wake-up Status) — refined, medium
        static let cardTitle = georgia(22, weight: .medium)
        static let cardSubtitle = georgiaItalic(15)
        static let dataLarge = Font.system(size: 44, weight: .medium, design: .default)
        static let dataLabel = Font.system(size: 11, weight: .medium, design: .default)
        static let rowLabel = georgia(17, weight: .regular)
        static let rowValue = Font.system(size: 17, weight: .medium, design: .default)
        static let identityQuote = georgia(28, weight: .semibold)
        static let identitySub = georgiaItalic(17)
        static let ctaCaps = Font.system(size: 13, weight: .medium, design: .default)
        static let featureTitle = georgia(20, weight: .medium)
        static let featureBody = georgiaItalic(16)
        static let deepWorkTitle = georgia(32, weight: .semibold)
        static let deepWorkBody = georgiaItalic(17)
        static let splashTitle = georgia(28, weight: .semibold)
        /// Splash — heavy serif wordmark, editorial gravitas
        static let splashBrand = Font.system(size: 56, weight: .heavy, design: .serif)
        /// Splash tagline — whisper-thin caps
        static let splashTagline = Font.system(size: 13, weight: .thin, design: .default)
        static let pullQuoteMark = georgia(36, weight: .medium)
    }
}

extension View {
    /// White card + very soft shadow, no stroke (editorial).
    func editorialCardSurface(cornerRadius: CGFloat = DesignSystem.CornerRadius.card) -> some View {
        background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: .black.opacity(DesignSystem.Shadow.cardOpacity),
                radius: DesignSystem.Shadow.cardRadius,
                x: 0,
                y: DesignSystem.Shadow.cardY
            )
    }
}
