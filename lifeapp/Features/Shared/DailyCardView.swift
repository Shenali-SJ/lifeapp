import SwiftUI

struct DailyCardView: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(DesignSystem.EditorialFont.georgia(17, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.primary)
            Text(subtitle)
                .font(DesignSystem.EditorialFont.georgiaItalic(15))
                .foregroundStyle(DesignSystem.Colors.secondaryText)
            Button(buttonTitle, action: action)
                .tint(DesignSystem.Colors.primary)
                .frame(minHeight: 44)
                .accessibilityLabel(buttonTitle)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .editorialCardSurface()
    }
}
