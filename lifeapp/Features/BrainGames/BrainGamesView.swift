import SwiftData
import SwiftUI

struct BrainGamesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\BrainGameReminderState.day, order: .reverse)]) private var entries: [BrainGameReminderState]
    @State private var viewModel = BrainGamesViewModel()

    var body: some View {
        Form {
            DatePicker("Reminder time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                .accessibilityLabel("Brain games reminder time")
            Toggle("Acknowledged today", isOn: $viewModel.acknowledgedToday)
                .accessibilityLabel("Acknowledged brain games reminder")
            Button("Save Preferences", action: saveState)
                .accessibilityLabel("Save brain games preferences")
        }
        .navigationTitle("Brain Games")
        .task { await viewModel.load(entries: entries) }
    }

    private func saveState() {
        let today = Date().startOfDayValue
        let state = entries.first(where: { $0.day == today }) ?? BrainGameReminderState(day: today, reminderTime: viewModel.reminderTime)
        state.reminderTime = viewModel.reminderTime
        state.acknowledged = viewModel.acknowledgedToday
        if !entries.contains(where: { $0.day == today }) {
            modelContext.insert(state)
        }

        Task {
            try? await NotificationService.shared.scheduleBrainGamesReminder(time: viewModel.reminderTime)
        }
    }
}
