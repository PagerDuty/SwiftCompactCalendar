import UIKit

final class CompactCalendarModel: NSObject {

    static var defaultModel: CompactCalendarModel {
        return CompactCalendarModel(today: Date())
    }

    private(set) var dates = [Date]()
    private(set) var pastDays = 0
    private(set) var previousDays = 0
    private(set) var initiallySelectedDate: Date
    private(set) var today: Date
    private let calendar: Calendar
    private let timeZone: TimeZone

    init(today: Date, initiallySelectedDate: Date? = nil, calendar: Calendar = Calendar.current, timeZone: TimeZone = TimeZone.current) {
        self.today = DateHelpers.midnight(of: today, timeZone: timeZone, calendar: calendar)
        self.initiallySelectedDate = DateHelpers.midnight(of: (initiallySelectedDate ?? today), timeZone: timeZone, calendar: calendar)
        self.calendar = calendar
        self.timeZone = timeZone
    }

    /// Loads necessary dates into the model between today and the initial selected date.
    func loadDates() {
        let oneDay: Double = 60 * 60 * 24
        let extraDays = initiallySelectedDate.timeIntervalSince(today) / oneDay
        /// The number of extra pages to generate in case the initial selected day is in the next 2-week chunk
        let extraPages = Int(extraDays) / 14
        let daysToPopulate = (extraPages + 2) * 14 // the number in (extraPages + 2) is how many pages you want generated at start
        var weekday = Calendar.current.component(.weekday, from: today)
        if weekday == 1 && weekStartsOnMonday() {
            weekday = 8
        }

        let firstWeekday = weekStartsOnMonday() ? 1 : 0

        if weekday - (1 + firstWeekday) > 0 {
            for i in 1...weekday - (1 + firstWeekday) {
                dates.insert(DateHelpers.add(days: -i, to: today), at: 0)
            }
        }
        pastDays = dates.count

        for i in weekday...daysToPopulate + firstWeekday {
            let day = DateHelpers.add(days: i - weekday, to: today)
            previousDays += day < initiallySelectedDate ? 1 : 0
            dates.append(day)
        }
    }

    func weekStartsOnMonday() -> Bool {
        return calendar.firstWeekday == 2
    }

    /// Conditionally generates the next 14 days. Returns `nil` when you've already been forward, back, and then go forward again
    ///
    /// - Parameter from: The date to start generating dates from
    /// - Returns: The start and end index as a tuple
    func generateFutureDates(from: Int) -> (startIndex: Int, endIndex: Int)? {
        guard let lastDate = dates.last, dates.count <= from + 14 else {
            return nil
        }
        for i in 1 ... 14 {
            dates.append(DateHelpers.add(days: i, to: lastDate))
        }
        return (dates.count - 14, dates.count - 1)
    }

    /// Conditionally generates the previous 14 days. Returns `nil` when you've already been back, forward, and then go back again.
    ///
    /// - Parameter from: The date to start generating dates from
    /// - Returns: The start and end index as a tuple
    func generatePastDates(from: Int) -> (startIndex: Int, endIndex: Int)? {
        guard let firstDate = dates.first, from == 0 else {
            return nil
        }
        for i in 1 ... 14 {
            dates.insert(DateHelpers.add(days: -i, to: firstDate), at: 0)
        }
        pastDays += 14
        return (0, 13)
    }
}
