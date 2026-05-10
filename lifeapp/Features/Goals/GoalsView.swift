import SwiftData
import SwiftUI

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\GoalIdentityEntry.day, order: .reverse)]) private var entries: [GoalIdentityEntry]
    @State private var viewModel = GoalsViewModel()

    var body: some View {
        Form {
            Text("Current streak: \(viewModel.streak)")
            TextField("Today's goals", text: $viewModel.goalsDraft, axis: .vertical)
                .lineLimit(2...5)
                .accessibilityLabel("Goals input")
            TextField("Identity reinforcement", text: $viewModel.identityDraft, axis: .vertical)
                .lineLimit(2...5)
                .accessibilityLabel("Identity statement input")
            Button("Save Today", action: saveToday)
                .disabled(!canSave)
                .accessibilityLabel("Save goals and identity")
        }
        .navigationTitle("Goals & Identity")
        .task { await viewModel.load(entries: entries) }
    }

    private var canSave: Bool {
        let todayMissing = !entries.contains(where: { $0.day == Date().startOfDayValue })
        return todayMissing &&
            !viewModel.goalsDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !viewModel.identityDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveToday() {
        let entry = GoalIdentityEntry(
            day: Date(),
            goalsText: viewModel.goalsDraft.trimmingCharacters(in: .whitespacesAndNewlines),
            identityText: viewModel.identityDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(entry)
        viewModel.goalsDraft = ""
        viewModel.identityDraft = ""
        Task { await viewModel.load(entries: entries + [entry]) }
    }
}
