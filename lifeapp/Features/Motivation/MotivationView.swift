import SwiftData
import SwiftUI

struct MotivationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\DailyMotivationEntry.day, order: .reverse)]) private var entries: [DailyMotivationEntry]
    @State private var viewModel = MotivationViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text(viewModel.quote)
                .font(.title3)
            Text("— \(viewModel.source)")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("Motivation")
        .task {
            await viewModel.load(entry: todayEntry)
            ensureTodayEntry()
        }
    }

    private var todayEntry: DailyMotivationEntry? {
        entries.first(where: { $0.day == Date().startOfDayValue })
    }

    private func ensureTodayEntry() {
        guard todayEntry == nil, !viewModel.quote.isEmpty else { return }
        modelContext.insert(DailyMotivationEntry(day: Date(), quote: viewModel.quote, source: viewModel.source))
    }
}
