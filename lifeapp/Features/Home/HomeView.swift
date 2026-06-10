import SwiftData
import SwiftUI
import UIKit

struct HomeView: View {
    @Binding var path: NavigationPath
    @Binding var selectedTab: Int
    @State private var viewModel = HomeViewModel()
    @State private var isShowingTimePicker = false
    @State private var wakePickerTime = Date()
    @State private var isShowingGoalPicker = false
    @State private var goalPickerTime = Date()
    @FocusState private var isAffirmationFocused: Bool

    @Environment(\.modelContext) private var modelContext

    @Query private var gratitudeEntries: [GratitudeEntry]
    @Query private var todayWakeEntries: [WakeUpEntry]
    @Query(sort: [SortDescriptor(\WakeUpEntry.day, order: .reverse)]) private var wakeEntriesByDay: [WakeUpEntry]
    @Query private var brainGameEntries: [BrainGameReminderState]
    @Query(sort: [SortDescriptor(\IdentityStatement.order)]) private var identityStatements: [IdentityStatement]

    init(path: Binding<NavigationPath>, selectedTab: Binding<Int>) {
        _path = path
        _selectedTab = selectedTab
        _viewModel = State(initialValue: HomeViewModel())
        _isShowingTimePicker = State(initialValue: false)
        _wakePickerTime = State(initialValue: Date())
        _isShowingGoalPicker = State(initialValue: false)
        _goalPickerTime = State(initialValue: Date())
        _isAffirmationFocused = FocusState()
        let today = Date().startOfDayValue
        _todayWakeEntries = Query(filter: #Predicate<WakeUpEntry> { entry in entry.day == today })
        _wakeEntriesByDay = Query(sort: [SortDescriptor(\WakeUpEntry.day, order: .reverse)])
        _gratitudeEntries = Query()
        _brainGameEntries = Query()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.section) {
                greetingSection
                wakeUpStatusSection
                identityCard
                quickSections
                deepWorkSection
            }
            .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
            .padding(.top, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.section)
        }
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.warmCream)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DesignSystem.Colors.warmCream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // Menu placeholder — design parity with mockup
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
                .accessibilityLabel("Menu")
            }
            ToolbarItem(placement: .principal) {
                Text("Align")
                    .font(.custom("Georgia", size: 20))
                    .fontWeight(.semibold)
                    .italic()
                    .foregroundStyle(DesignSystem.Colors.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(DesignSystem.Colors.primary)
                    .accessibilityLabel("Profile")
            }
        }
        .task {
            await viewModel.load()
            try? await Task.sleep(for: .seconds(0.6))
            isAffirmationFocused = true
        }
        .sheet(isPresented: $isShowingTimePicker) {
            wakeUpTimePickerSheet
        }
        .sheet(isPresented: $isShowingGoalPicker) {
            wakeUpGoalPickerSheet
        }
        .onChange(of: isShowingTimePicker) { _, isPresented in
            if isPresented {
                let entry = todayWakeEntry
                wakePickerTime = entry?.actualWakeTime ?? Date()
            }
        }
        .onChange(of: isShowingGoalPicker) { _, isPresented in
            if isPresented {
                if let goal = effectiveGoalWakeTime {
                    goalPickerTime = Self.wakeDate(fromPicker: goal, on: Date().startOfDayValue)
                } else {
                    goalPickerTime = Date()
                }
            }
        }
    }

    private var todayWakeEntry: WakeUpEntry? {
        todayWakeEntries.first
    }

    private var carriedForwardGoalWakeTime: Date? {
        let today = Date().startOfDayValue
        for entry in wakeEntriesByDay where entry.day < today {
            if let goal = entry.goalWakeTime { return goal }
        }
        return nil
    }

    private var effectiveGoalWakeTime: Date? {
        todayWakeEntry?.goalWakeTime ?? carriedForwardGoalWakeTime
    }

    private var wakeUpTimePickerSheet: some View {
        NavigationStack {
            DatePicker(
                "",
                selection: $wakePickerTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .navigationTitle("Log Wake-up Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingTimePicker = false
                    }
                    .accessibilityLabel("Cancel wake-up time")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWakeUpTime()
                        isShowingTimePicker = false
                    }
                    .fontWeight(.semibold)
                    .accessibilityLabel("Save wake-up time")
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var wakeUpGoalPickerSheet: some View {
        NavigationStack {
            DatePicker(
                "",
                selection: $goalPickerTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .navigationTitle("Set Wake-up Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingGoalPicker = false
                    }
                    .accessibilityLabel("Cancel wake-up goal")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoalWakeTime()
                        isShowingGoalPicker = false
                    }
                    .fontWeight(.semibold)
                    .accessibilityLabel("Save wake-up goal")
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func saveGoalWakeTime() {
        let day = Date().startOfDayValue
        let merged = Self.wakeDate(fromPicker: goalPickerTime, on: day)
        if let existing = todayWakeEntry {
            existing.goalWakeTime = merged
        } else {
            modelContext.insert(WakeUpEntry(day: day, goalWakeTime: merged))
        }
        try? modelContext.save()
    }

    private func saveWakeUpTime() {
        let day = Date().startOfDayValue
        let merged = Self.wakeDate(fromPicker: wakePickerTime, on: day)
        if let existing = todayWakeEntry {
            existing.actualWakeTime = merged
        } else {
            modelContext.insert(WakeUpEntry(day: day, actualWakeTime: merged))
        }
        try? modelContext.save()
    }

    private static func wakeDate(fromPicker pickerTime: Date, on day: Date) -> Date {
        let cal = Calendar.current
        let parts = cal.dateComponents([.hour, .minute], from: pickerTime)
        let base = day.startOfDayValue
        return cal.date(bySettingHour: parts.hour ?? 0, minute: parts.minute ?? 0, second: 0, of: base) ?? base
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            Text(viewModel.dateTitle)
                .font(.custom("NotoSerif-Regular", size: 12))
                .tracking(2)
                .foregroundStyle(DesignSystem.Colors.secondaryText)

            Text("Good morning,\n\(viewModel.userName).")
                .font(.custom("Georgia", size: 40))
                .fontWeight(.regular)
                .foregroundStyle(DesignSystem.Colors.primary)
                 .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            TextField(
                "",
                text: $viewModel.affirmationText,
                prompt: Text("Type your affirmation for the day...")
                    .font(DesignSystem.EditorialFont.georgiaItalic(16))
                    .foregroundStyle(DesignSystem.Colors.secondaryText.opacity(0.75))
            )
            .font(DesignSystem.EditorialFont.georgiaItalic(16))
            .foregroundStyle(DesignSystem.Colors.gold)
            .tint(DesignSystem.Colors.gold)
            .textFieldStyle(.plain)
            .background(Color.clear)
            .focused($isAffirmationFocused)
            .padding(.top, DesignSystem.Spacing.sm)
            .accessibilityLabel("Daily affirmation input")
        }
    }

    private var wakeUpStatusSection: some View {
        let entry = todayWakeEntry
        let today = Date().startOfDayValue
        let variance = viewModel.varianceDisplay(
            actual: entry?.actualWakeTime,
            goal: effectiveGoalWakeTime,
            referenceDay: today
        )

        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Wake-up Status")
                        .font(.custom("NotoSerif-Regular", size: 20))
                        .fontWeight(.medium)
                        .foregroundStyle(DesignSystem.Colors.primary)
                    Text("Intentional start to your day")
                        .font(.custom("NotoSerif-Italic", size: 14))
                        .italic()
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                        .lineSpacing(3)
                }
                Spacer(minLength: DesignSystem.Spacing.lg)
                Image(systemName: "sun.max")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(DesignSystem.Colors.primary)
            }

            Button {
                isShowingTimePicker = true
            } label: {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.cardBackground)
                        .frame(width: 160, height: 160)
                    Circle()
                        .stroke(DesignSystem.Colors.wakeCircle, lineWidth: 3.5)
                        .frame(width: 160, height: 160)
                        .shadow(color: .black.opacity(0.06), radius: 1, x: 0, y: 1)
                    Group {
                        if let actual = entry?.actualWakeTime {
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                Text(viewModel.formatTime(actual))
                                    .font(.custom("Georgia", size: 28))
                                    .fontWeight(.regular)
                                    .foregroundStyle(Color(uiColor: UIColor.label))
                                    .monospacedDigit()
                                Text("ACTUAL")
                                    .font(.custom("Georgia", size: 10))
                                    .tracking(2)
                                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                            }
                        } else {
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "sunrise")
                                    .font(.system(size: 28, weight: .regular))
                                    .foregroundStyle(DesignSystem.Colors.primary.opacity(0.5))
                                    .accessibilityHidden(true)
                                Text("Log your rise")
                                    .font(.custom("Georgia", size: 12))
                                    .italic()
                                    .foregroundStyle(DesignSystem.Colors.primary.opacity(0.5))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
            }
            .buttonStyle(WakeUpCircleButtonStyle())
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .accessibilityLabel("Log wake-up time")

            VStack(spacing: 0) {
                dailyGoalRow(displayedGoal: viewModel.formatGoalTime(effectiveGoalWakeTime))

                Divider()
                    .background(DesignSystem.Colors.primary.opacity(0.08))
                    .padding(.vertical, DesignSystem.Spacing.md)

                varianceRow(label: variance.label, value: variance.value)
            }
        }
        .padding(DesignSystem.Spacing.xl)
         .editorialCardSurface()
    }

    private var identityCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text(IdentityViewModel.homeDisplayText(from: identityStatements))
                .font(DesignSystem.EditorialFont.georgiaItalic(16))
                .foregroundStyle(DesignSystem.Colors.primary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                selectedTab = AppConstants.Tab.identity
            } label: {
                Text("Reaffirm")
                    .font(DesignSystem.EditorialFont.georgia(13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.primary)
                    .clipShape(Capsule())
            }
            .accessibilityLabel("Reaffirm identity")
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .editorialCardSurface()
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignSystem.Colors.primary)
                .frame(width: 3)
        }
    }

    private var quickSections: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            simpleSectionCard(
                icon: "calendar",
                title: "Plan",
                action: nil
            ) {
                Text("Start planning your day now, never too late.")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }
            simpleSectionCard(
                icon: "heart.fill",
                title: "Gratitude",
                action: { path.append(AppRoute.gratitude) }
            ) {
                gratitudeSubtitleText
            }
            simpleSectionCard(
                icon: "bolt.fill",
                title: "Atomics",
                action: { path.append(AppRoute.brainGames) }
            ) {
                atomicsSubtitleText
            }
        }
    }

    private var deepWorkSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.hero)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 72 / 255, green: 58 / 255, blue: 48 / 255).opacity(0.5),
                            Color(red: 120 / 255, green: 98 / 255, blue: 72 / 255).opacity(0.32),
                            DesignSystem.Colors.warmCream.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Image(systemName: "lamp.desk.fill")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(.white.opacity(0.92))
                )
                .frame(height: 188)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.hero))

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                Text("Deep Work Session")
                    .font(.custom("Inter-Regular", size: 32))
                    .foregroundStyle(DesignSystem.Colors.primary)

                Text("Ready to transition into your first block of intentional productivity? Align helps you silence the noise.")
                    .font(.custom("NotoSerif-Regular", size: 16))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                Button("ENTER FOCUS MODE") {}
                    .font(.custom("NotoSerif-Regular", size: 14))
                    .tracking(1.4)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(DesignSystem.Colors.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button))
                    .accessibilityLabel("Enter focus mode")
            }
            .padding(.top, DesignSystem.Spacing.xs)
        }
    }

    private func simpleSectionCard<Subtitle: View>(
        icon: String,
        title: String,
        action: (() -> Void)?,
        @ViewBuilder subtitle: () -> Subtitle
    ) -> some View {
        Button(action: { action?() }) {
            HStack(alignment: .center, spacing: DesignSystem.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.mintIconBackground)
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text(title)
                        .font(.custom("NotoSerif-Regular", size: 20))
                        .foregroundStyle(DesignSystem.Colors.primary)
                    subtitle()
                        .font(.custom("NotoSerif-Italic", size: 16))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, DesignSystem.Spacing.xl)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .editorialCardSurface()
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .accessibilityLabel(title)
    }

    private func dailyGoalRow(displayedGoal: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Daily Goal")
                .font(.custom("NotoSerif-Regular", size: 16))
                .foregroundStyle(DesignSystem.Colors.primary)
            Spacer(minLength: DesignSystem.Spacing.lg)
            Button {
                isShowingGoalPicker = true
            } label: {
                Text(displayedGoal)
                    .font(.custom("NotoSerif-Regular", size: 20))
                    .foregroundStyle(DesignSystem.Colors.gold)
                    .multilineTextAlignment(.trailing)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Set daily wake-up goal")
        }
    }

    @ViewBuilder
    private func varianceRow(label: String, value: String) -> some View {
        let forestGreen = Color(red: 0.227, green: 0.353, blue: 0.251)
        let aheadGold = Color(red: 0.788, green: 0.659, blue: 0.298)
        let accent: Color = {
            if label == "Behind goal by" { return DesignSystem.Colors.varianceLate }
            if label == "Ahead of goal by" { return aheadGold }
            return .gray
        }()

        if value == "Right on time ✓" {
            Text(value)
                .font(.custom("Georgia", size: 15))
                .foregroundStyle(forestGreen)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        } else {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.custom("Georgia", size: 15))
                    .foregroundStyle(accent)
                Spacer(minLength: DesignSystem.Spacing.lg)
                Text(value)
                    .font(.custom("Georgia", size: 15))
                    .foregroundStyle(accent)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private var gratitudeStreak: Int {
        StreakService().currentStreak(for: gratitudeEntries.map(\.day))
    }

    private var gratitudeSubtitleText: Text {
        let name = viewModel.userName
        let body = Text("What are you grateful for \(name)?")
            .foregroundStyle(DesignSystem.Colors.secondaryText)
        if gratitudeStreak > 1 {
            return body
                + Text(" Streak: ")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                + Text("\(gratitudeStreak)")
                    .foregroundStyle(DesignSystem.Colors.gold)
                + Text(" days.")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
        }
        return body
    }

    private var atomicsSubtitleText: Text {
        let brainGamesDays = brainGameEntries
            .filter(\.acknowledged)
            .map(\.day)
        let brainGamesStreak = StreakService().currentStreak(for: brainGamesDays)
        let habits = viewModel.atomicHabits(brainGamesStreak: brainGamesStreak)
        guard let first = habits.first else {
            return Text("")
                .foregroundStyle(DesignSystem.Colors.secondaryText)
        }
        var combined = atomicsHabitText(first)
        for habit in habits.dropFirst() {
            combined = combined
                + Text("  •  ")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                + atomicsHabitText(habit)
        }
        return combined
    }

    private func atomicsHabitText(_ habit: AtomicHabit) -> Text {
        Text("\(habit.name): ")
            .foregroundStyle(DesignSystem.Colors.secondaryText)
            + Text("\(habit.streak)d")
            .foregroundStyle(DesignSystem.Colors.gold)
    }
}

// MARK: - Wake-up circle

private struct WakeUpCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
