import Foundation

class DateHelpers {

    static var monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    static var monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static func midnight(of date: Date, timeZone: TimeZone, calendar: Calendar = Calendar.current) -> Date {
        var components = calendar.dateComponents(in: timeZone, from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        return components.date!
    }

    static func add(days: Int, to date: Date, calendar: Calendar = Calendar.current) -> Date {
        return calendar.date(byAdding: .day, value: days, to: date)!
    }

    static func dayComponent(of date: Date, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(.day, from: date)
    }

    static func monthComponent(of date: Date, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(.month, from: date)
    }

}
