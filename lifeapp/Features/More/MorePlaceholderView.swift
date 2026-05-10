import SwiftUI

struct MorePlaceholderView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("More")
                .font(DesignSystem.EditorialFont.splashTitle)
                .foregroundStyle(DesignSystem.Colors.primary)
            Text("Additional settings and tools will live here.")
                .font(DesignSystem.EditorialFont.georgiaItalic(17))
                .foregroundStyle(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.paletteBackground)
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.inline)
    }
}
