import SwiftData
import SwiftUI

enum IdentityEditorMode: Equatable {
    case add
    case edit(IdentityStatement)

    var title: String {
        switch self {
        case .add: "Add to your identity"
        case .edit: "Add to your identity"
        }
    }
}

struct IdentityView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\IdentityStatement.order)]) private var statements: [IdentityStatement]

    @State private var viewModel = IdentityViewModel()
    @State private var isShowingEditor = false
    @State private var editorMode: IdentityEditorMode = .add
    @State private var actionTarget: IdentityStatement?
    @State private var isShowingStatementActions = false
    @State private var isShowingDeleteConfirmation = false
    @State private var cardsAppeared = false

    var body: some View {
        Group {
            if statements.isEmpty {
                emptyState
            } else {
                statementsList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.warmCream)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DesignSystem.Colors.warmCream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Identity")
                    .font(DesignSystem.EditorialFont.georgiaItalic(20))
                    .foregroundStyle(DesignSystem.Colors.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                if statements.count < IdentityViewModel.maxStatements, !statements.isEmpty {
                    Button {
                        openEditor(mode: .add)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.primary)
                    }
                    .accessibilityLabel("Add identity statement")
                }
            }
        }
        .sheet(isPresented: $isShowingEditor) {
            IdentityEditorSheet(
                mode: editorMode,
                draftText: $viewModel.draftText,
                viewModel: viewModel,
                onCancel: { isShowingEditor = false },
                onSave: saveFromEditor
            )
        }
        .confirmationDialog(
            "Options",
            isPresented: $isShowingStatementActions,
            titleVisibility: .hidden,
            presenting: actionTarget
        ) { statement in
            Button("Edit") {
                openEditor(mode: .edit(statement))
            }
            Button("Delete", role: .destructive) {
                actionTarget = statement
                isShowingDeleteConfirmation = true
            }
        }
        .confirmationDialog(
            "Let this one go?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible,
            presenting: actionTarget
        ) { statement in
            Button("Let go", role: .destructive) {
                delete(statement)
            }
            Button("Keep", role: .cancel) {}
        } message: { _ in
            Text("You can always add a new one later.")
        }
        .onChange(of: statements.isEmpty) { _, isEmpty in
            if isEmpty { cardsAppeared = false }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            Text("Who are you becoming?")
                .font(DesignSystem.EditorialFont.georgiaItalic(28))
                .foregroundStyle(DesignSystem.Colors.primary)
                .multilineTextAlignment(.center)

            Text("Start with one thing. Just one.")
                .font(DesignSystem.EditorialFont.georgiaItalic(15))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)

            identityTextField(
                text: $viewModel.draftText,
                centered: true
            )
            .padding(.top, DesignSystem.Spacing.lg)

            primaryButton(title: "This is me") {
                saveFirstStatement()
            }
            .padding(.top, DesignSystem.Spacing.md)

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
    }

    // MARK: - Statements list

    private var statementsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("I AM...")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(DesignSystem.Colors.primary.opacity(0.5))
                    .padding(.top, 8)
                    .allowsHitTesting(false)
                    

                ForEach(statements) { statement in
                    statementCard(statement)
                        .padding(.top, statement.id == statements.first?.id ? 4 : 0)
                        .opacity(cardsAppeared ? 1 : 0)
                }

                if statements.count >= IdentityViewModel.maxStatements {
                    Text("You have defined your identity. Live it.")
                        .font(DesignSystem.EditorialFont.georgiaItalic(13))
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(maxWidth: .infinity)
                        .padding(.top, DesignSystem.Spacing.sm)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
            .padding(.bottom, DesignSystem.Spacing.section)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                cardsAppeared = true
            }
        }
    }

    private func statementCard(_ statement: IdentityStatement) -> some View {
        Text(statement.text)
            .font(DesignSystem.EditorialFont.georgia(17))
            .foregroundStyle(DesignSystem.Colors.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card))
            .shadow(
                color: .black.opacity(DesignSystem.Shadow.cardOpacity * 0.5),
                radius: 4,
                x: 0,
                y: 2
            )
            .onLongPressGesture(minimumDuration: 0.5) {
                actionTarget = statement
                isShowingStatementActions = true
            }
            .accessibilityLabel(statement.text)
            .accessibilityHint("Long press to edit or delete")
    }

    // MARK: - Shared input

    private func identityTextField(text: Binding<String>, centered: Bool) -> some View {
        TextField(
            "",
            text: text,
            prompt: Text("I am someone who...")
                .font(DesignSystem.EditorialFont.georgiaItalic(16))
                .foregroundStyle(Color(.secondaryLabel))
        )
        .font(DesignSystem.EditorialFont.georgiaItalic(16))
        .foregroundStyle(DesignSystem.Colors.primary)
        .multilineTextAlignment(centered ? .center : .leading)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card))
        .accessibilityLabel("Identity statement")
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.EditorialFont.georgia(15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.lg)
                .background(DesignSystem.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!viewModel.canSave(raw: viewModel.draftText))
        .opacity(viewModel.canSave(raw: viewModel.draftText) ? 1 : 0.5)
        .accessibilityLabel(title)
    }

    // MARK: - Actions

    private func openEditor(mode: IdentityEditorMode) {
        editorMode = mode
        switch mode {
        case .add:
            viewModel.draftText = ""
        case .edit(let statement):
            viewModel.draftText = statement.text
        }
        isShowingEditor = true
    }

    private func saveFirstStatement() {
        guard let text = viewModel.sanitizedText(viewModel.draftText) else { return }
        let statement = IdentityStatement(text: text, order: 0)
        modelContext.insert(statement)
        viewModel.draftText = ""
    }

    private func saveFromEditor() {
        guard let text = viewModel.sanitizedText(viewModel.draftText) else { return }
        switch editorMode {
        case .add:
            guard statements.count < IdentityViewModel.maxStatements else { return }
            let statement = IdentityStatement(
                text: text,
                order: viewModel.nextOrder(in: statements)
            )
            modelContext.insert(statement)
        case .edit(let statement):
            statement.text = text
        }
        viewModel.draftText = ""
        isShowingEditor = false
    }

    private func delete(_ statement: IdentityStatement) {
        modelContext.delete(statement)
        actionTarget = nil
    }
}

// MARK: - Editor sheet

private struct IdentityEditorSheet: View {
    let mode: IdentityEditorMode
    @Binding var draftText: String
    let viewModel: IdentityViewModel
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                TextField(
                    "",
                    text: $draftText,
                    prompt: Text("I am someone who...")
                        .font(DesignSystem.EditorialFont.georgiaItalic(16))
                        .foregroundStyle(Color(.secondaryLabel))
                )
                .font(DesignSystem.EditorialFont.georgiaItalic(16))
                .foregroundStyle(DesignSystem.Colors.primary)
                .onChange(of: draftText) { _, newValue in
                    if newValue.count > IdentityViewModel.characterLimit {
                        draftText = String(newValue.prefix(IdentityViewModel.characterLimit))
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.lg)
                .padding(.horizontal, 20)
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card))
                .accessibilityLabel("Identity statement")

                if viewModel.shouldShowRemainingCount(for: draftText) {
                    Text("\(viewModel.remainingCharacters(for: draftText)) left")
                        .font(DesignSystem.EditorialFont.georgia(13))
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .padding(DesignSystem.Spacing.screenHorizontal)
            .padding(.top, 24)
            .background(DesignSystem.Colors.warmCream)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                        .font(DesignSystem.EditorialFont.georgia(15))
                        .foregroundStyle(Color(.secondaryLabel))
                        .accessibilityLabel("Cancel")
                }
                ToolbarItem(placement: .principal) {
                    Text(mode.title)
                        .font(DesignSystem.EditorialFont.georgiaItalic(18))
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: onSave)
                        .font(DesignSystem.EditorialFont.georgia(16))
                        .foregroundStyle(DesignSystem.Colors.primary)
                        .disabled(!viewModel.canSave(raw: draftText))
                        .accessibilityLabel("Save identity statement")
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
