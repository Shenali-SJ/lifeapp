import SwiftUI

struct SplashView: View {
    var onSequenceComplete: () -> Void

    @State private var titleVisible = false
    @State private var taglineVisible = false

    private enum Timing {
        static let initialBlank: Duration = .milliseconds(300)
        static let titleSettle: TimeInterval = 0.88
        static let afterTitleVisible: TimeInterval = 0.6
        static let taglineFade: TimeInterval = 0.72
        static let finalHold: TimeInterval = 1.0
    }

    var body: some View {
        VStack(spacing: 22) {
            Text(AppConstants.appName)
                .font(DesignSystem.EditorialFont.splashBrand)
                .foregroundStyle(DesignSystem.Colors.primary)
                .kerning(8)
                .textCase(.uppercase)
                .opacity(titleVisible ? 1 : 0)
                .offset(y: titleVisible ? 0 : 16)
                .accessibilityLabel(AppConstants.appName)

            Text(AppConstants.splashTagline)
                .font(DesignSystem.EditorialFont.splashTagline)
                .foregroundStyle(DesignSystem.Colors.secondaryText)
                .kerning(4)
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
                .opacity(taglineVisible ? 1 : 0)
                .accessibilityLabel(AppConstants.splashTagline)
        }
        .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.paletteBackground)
        .task {
            await runSequence()
        }
    }

    private func runSequence() async {
        try? await Task.sleep(for: Timing.initialBlank)
        guard !Task.isCancelled else { return }

        await MainActor.run {
            withAnimation(.easeOut(duration: Timing.titleSettle)) {
                titleVisible = true
            }
        }

        try? await Task.sleep(for: .seconds(Timing.titleSettle + Timing.afterTitleVisible))
        guard !Task.isCancelled else { return }

        await MainActor.run {
            withAnimation(.easeInOut(duration: Timing.taglineFade)) {
                taglineVisible = true
            }
        }

        try? await Task.sleep(for: .seconds(Timing.taglineFade + Timing.finalHold))
        guard !Task.isCancelled else { return }

        await MainActor.run {
            onSequenceComplete()
        }
    }
}

#Preview {
    SplashView(onSequenceComplete: {})
}
