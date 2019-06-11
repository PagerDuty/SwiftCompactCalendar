import Foundation

public protocol CompactCalendarDelegate: AnyObject {

    /// Called when a date on the Compact Calendar is selected
    ///
    /// - Parameters:
    ///   - compactCalendar: The CompactCalendar that the selection applied to
    ///   - date: The date that was selected
    ///   - isAlreadySelected: true if the new selected item was already selected
    func compactCalendar(_ compactCalendar: CompactCalendar, didSelectCalendarCellWith date: Date, isAlreadySelected: Bool)

    /// Called when the next page button is pressed or the calendar scrolls to the next page
    ///
    /// - Parameters:
    ///   - compactCalendar: The CompactCalendar that the action applied to
    ///   - weeksAhead: The number of weeks the new page is ahead of the previous state (negative if previous page)
    func didGoToNextPage(_ compactCalendar: CompactCalendar, weeksAhead: Int)

    /// Called when the previous page button is pressed or the calendar scrolls to the previous page
    ///
    /// - Parameters:
    ///   - compactCalendar: The CompactCalendar that the action applied to
    ///   - weeksAhead: The number of weeks the new page is ahead of the previous state (negative if previous page)
    func didGoToPreviousPage(_ compactCalendar: CompactCalendar, weeksAhead: Int)

}
