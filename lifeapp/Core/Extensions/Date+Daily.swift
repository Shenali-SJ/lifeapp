import Foundation

extension Date {
    var startOfDayValue: Date {
        Calendar.current.startOfDay(for: self)
    }

    var dayKey: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: startOfDayValue)
    }
}
