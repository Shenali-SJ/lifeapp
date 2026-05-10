import SwiftData
import SwiftUI

struct DayPlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\DayPlanEntry.day, order: .reverse)]) private var entries: [DayPlanEntry]
    @State private var viewModel = DayPlannerViewModel()

    var body: some View {
        Form {
            Section("Planned") {
                TextEditor(text: $viewModel.plannedText)
                    .frame(minHeight: 90)
                    .accessibilityLabel("Planned tasks")
            }
            Section("Did") {
                TextEditor(text: $viewModel.didText)
                    .frame(minHeight: 90)
                    .accessibilityLabel("Completed tasks")
            }
            Section("Plan for Tomorrow") {
                TextEditor(text: $viewModel.tomorrowText)
                    .frame(minHeight: 90)
                    .accessibilityLabel("Plan for tomorrow tasks")
            }
            Section("Completion") {
                Text("Today: \(Int(viewModel.dailyCompletion))%")
                Text("Week avg: \(Int(viewModel.weeklyCompletion))%")
                Text("Month avg: \(Int(viewModel.monthlyCompletion))%")
            }
            Button("Save Today Plan", action: saveToday)
                .accessibilityLabel("Save today plan")
        }
        .navigationTitle("Day Planner")
        .task { await viewModel.load(entries: entries) }
    }

    private func saveToday() {
        let today = Date().startOfDayValue
        let entry = entries.first(where: { $0.day == today }) ?? DayPlanEntry(day: today)
        entry.plannedText = viewModel.plannedText
        entry.didText = viewModel.didText
        entry.tomorrowText = viewModel.tomorrowText
        if !entries.contains(where: { $0.day == today }) {
            modelContext.insert(entry)
        }
        viewModel.calculateCompletion(entries: entries)

        Task {
            try? await NotificationService.shared.schedulePlannerReminder(time: Date())
        }
    }
}
