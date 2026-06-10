//
//  lifeappTests.swift
//  lifeappTests
//
//  Created by Shenali Jayakody on 2026-04-28.
//

import Testing
@testable import lifeapp

struct lifeappTests {
    @Test func streakServiceCountsConsecutiveDays() {
        let service = StreakService()
        let today = Date().startOfDayValue
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let streak = service.currentStreak(for: [today, yesterday, twoDaysAgo])
        #expect(streak == 3)
    }

    @Test @MainActor
    func wakeUpTrendPrefersImprovingForEarlyWakeTimes() async {
        let vm = WakeUpViewModel()
        let base = Date().startOfDayValue
        let entries = (0..<3).map { offset in
            let day = Calendar.current.date(byAdding: .day, value: -offset, to: base)!
            let goal = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: day)!
            let actual = Calendar.current.date(bySettingHour: 6, minute: 45, second: 0, of: day)!
            return WakeUpEntry(day: day, actualWakeTime: actual, goalWakeTime: goal, trend: .stable)
        }
        #expect(vm.calculateTrend(entries: entries) == .improving)
    }

    @Test @MainActor
    func gratitudeViewModelLoadsStreak() async {
        let vm = GratitudeViewModel()
        let today = Date().startOfDayValue
        let entry = GratitudeEntry(day: today, text: "Thanks")
        await vm.load(entries: [entry])
        #expect(vm.streak == 1)
    }

    @Test @MainActor
    func goalsViewModelLoadsStreak() async {
        let vm = GoalsViewModel()
        let today = Date().startOfDayValue
        let entry = GoalIdentityEntry(day: today, goalsText: "Ship", identityText: "I am consistent.")
        await vm.load(entries: [entry])
        #expect(vm.streak == 1)
    }

    @Test @MainActor
    func brainGamesViewModelLoadsAcknowledgement() async {
        let vm = BrainGamesViewModel()
        let state = BrainGameReminderState(day: Date(), reminderTime: .now, acknowledged: true)
        await vm.load(entries: [state])
        #expect(vm.acknowledgedToday == true)
    }

    @Test @MainActor
    func dayPlannerComputesDailyCompletion() async {
        let vm = DayPlannerViewModel()
        let entry = DayPlanEntry(day: Date(), plannedText: "A\nB", didText: "A", tomorrowText: "C")
        await vm.load(entries: [entry])
        #expect(Int(vm.dailyCompletion) == 50)
    }

    @Test @MainActor
    func motivationViewModelUsesFallbackWhenMissingEntry() async {
        let vm = MotivationViewModel()
        await vm.load(entry: nil)
        #expect(vm.quote.isEmpty == false)
        #expect(vm.source.isEmpty == false)
    }

    @Test @MainActor
    func homeViewModelFormatsDateTitle() async {
        let vm = HomeViewModel()
        await vm.load()
        #expect(vm.dateTitle.isEmpty == false)
    }

    @Test @MainActor
    func identityViewModelSanitizesAndLimitsText() {
        let vm = IdentityViewModel()
        #expect(vm.sanitizedText("  I am calm.  ") == "I am calm.")
        let long = String(repeating: "a", count: 120)
        #expect(vm.sanitizedText(long)?.count == IdentityViewModel.characterLimit)
        #expect(vm.shouldShowRemainingCount(for: String(repeating: "a", count: 85)) == true)
        #expect(vm.shouldShowRemainingCount(for: "short") == false)
    }

    @Test @MainActor
    func identityViewModelDailyRotationIsStableWithinDay() {
        let a = IdentityStatement(text: "First", order: 0)
        let b = IdentityStatement(text: "Second", order: 1)
        let day = Date().startOfDayValue
        let first = IdentityViewModel.homeDisplayStatement(from: [a, b], on: day)
        let second = IdentityViewModel.homeDisplayStatement(from: [a, b], on: day)
        #expect(first?.text == second?.text)
    }

    @Test @MainActor
    func identityViewModelHomePlaceholderWhenEmpty() {
        #expect(IdentityViewModel.homeDisplayText(from: []) == "Who are you becoming?")
    }

    @Test
    func homeHeaderDateIncludesOrdinal() {
        let cal = Calendar.current
        guard let date = cal.date(from: DateComponents(year: 2026, month: 1, day: 1)) else {
            Issue.record("Could not build date")
            return
        }
        let title = HomeViewModel.formattedHeaderDate(for: date)
        #expect(title.contains("JANUARY"))
        #expect(title.contains("1ST"))
    }
}
