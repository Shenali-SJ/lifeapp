import SwiftData
import SwiftUI

struct GratitudeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\GratitudeEntry.day, order: .reverse)]) private var entries: [GratitudeEntry]
    @State private var viewModel = GratitudeViewModel()

    var body: some View {
        Form {
            Text("Current streak: \(viewModel.streak)")
            TextField("What are you grateful for today?", text: $viewModel.draft, axis: .vertical)
                .lineLimit(3...6)
                .accessibilityLabel("Gratitude entry input")
            Button("Save Today", action: saveToday)
                .disabled(hasTodayEntry || viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Save gratitude entry")
        }
        .navigationTitle("Gratitude")
        .task { await viewModel.load(entries: entries) }
    }

    private var hasTodayEntry: Bool {
        entries.contains(where: { $0.day == Date().startOfDayValue })
    }

    private func saveToday() {
        let entry = GratitudeEntry(day: Date(), text: viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(entry)
        viewModel.draft = ""
        Task { await viewModel.load(entries: entries + [entry]) }
    }
}
