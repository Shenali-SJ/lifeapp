import SwiftData
import SwiftUI

struct WakeUpView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\WakeUpEntry.day, order: .reverse)]) private var entries: [WakeUpEntry]
    @State private var viewModel = WakeUpViewModel()

    var body: some View {
        Form {
            DatePicker("Actual Wake-Up", selection: $viewModel.selectedActualTime, displayedComponents: .hourAndMinute)
                .accessibilityLabel("Actual wake up time")
            DatePicker("Goal Wake-Up", selection: $viewModel.selectedGoalTime, displayedComponents: .hourAndMinute)
                .accessibilityLabel("Goal wake up time")
            Toggle("Daily wake-up feedback notification", isOn: $viewModel.notificationsEnabled)
                .accessibilityLabel("Wake up feedback notification toggle")
            Text("Trend: \(viewModel.trend.rawValue.capitalized)")
            Button("Save Today", action: saveToday)
                .accessibilityLabel("Save wake up entry")
        }
        .navigationTitle("Wake Up")
        .task { await viewModel.load(from: entries) }
    }

    private func saveToday() {
        let today = Date().startOfDayValue
        let entry = entries.first(where: { $0.day == today }) ?? WakeUpEntry(day: today)
        entry.actualWakeTime = viewModel.selectedActualTime
        entry.goalWakeTime = viewModel.selectedGoalTime
        entry.notificationsEnabled = viewModel.notificationsEnabled
        entry.trend = viewModel.calculateTrend(entries: entries)
        if !entries.contains(where: { $0.day == today }) {
            modelContext.insert(entry)
        }

        if viewModel.notificationsEnabled {
            let gap = Calendar.current.dateComponents([.minute], from: viewModel.selectedGoalTime, to: viewModel.selectedActualTime).minute ?? 0
            Task {
                try? await NotificationService.shared.scheduleWakeUpFeedback(for: today, gapMinutes: gap)
            }
        }
    }
}
