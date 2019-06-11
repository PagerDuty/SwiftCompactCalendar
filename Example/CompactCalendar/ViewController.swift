import UIKit
import CompactCalendar

class ViewController: UIViewController {

    private let oneDay: Double = 86400

    @IBOutlet weak var compactCalendar: CompactCalendar!
    @IBOutlet weak var dateLabel: UILabel!

    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Compact Calendar

        compactCalendar.delegate = self

        /**
         Customize Model

        let customSelectedDate = Date().addingTimeInterval(oneDay) // Tomorrow
        let customToday = Date().addingTimeInterval(-oneDay) // Yesterday
        let customDaysOfTheWeekText = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        let customCalendar = Calendar(identifier: .gregorian)
        let customTimeZone = TimeZone(identifier: "America/Los_Angeles")

        // Tomorrow is initially selected
        compactCalendar.configure(selectedDate: customSelectedDate)


        // Yesterday is displayed as today
        compactCalendar.configure(today: customToday)

        // Days of the week bar text is set to the given values
        compactCalendar.configure(daysOfTheWeekText: customDaysOfTheWeekText)

        // Custom calendar
        compactCalendar.configure(calendar: customCalendar)

        // Custom TimeZone
        if let customTimeZone = customTimeZone {
            compactCalendar.configure(timeZone: customTimeZone)
        }

        // Custom everything
        compactCalendar.configure(selectedDate: customSelectedDate, today: customToday, daysOfTheWeekText: customDaysOfTheWeekText, calendar: customCalendar, timeZone: customTimeZone ?? TimeZone.current)

        // Customize Views

        // Background Color
        compactCalendar.setBackground(forConfigurableView: .monthBar, to: .white)
        compactCalendar.setBackground(forConfigurableView: .daysOfTheWeekBar, to: .white)
        compactCalendar.setBackground(forConfigurableView: .datesView, to: .white)
        // The three lines above are the same as the line below this comment
        compactCalendar.setBackground(forConfigurableView: .all, to: .white)

        compactCalendar.setBackground(forConfigurableView: .selectedDateView, to: .red)

        // Foreground Color
        compactCalendar.setForeground(forConfigurableView: .monthBar, to: .purple)
        compactCalendar.setForeground(forConfigurableView: .monthBarButtons, to: .red)
        compactCalendar.setForeground(forConfigurableView: .daysOfTheWeekBar, to: .red)
        compactCalendar.setForeground(forConfigurableView: .datesView, to: .purple)
        compactCalendar.setForeground(forConfigurableView: .selectedDateView, to: .white)

        // Font
        compactCalendar.setFont(forConfigurableView: .monthBar, to: .systemFont(ofSize: 17))
        compactCalendar.setFont(forConfigurableView: .daysOfTheWeekBar, to: .systemFont(ofSize: 13))
        compactCalendar.setFont(forConfigurableView: .datesView, to: .systemFont(ofSize: 16))

        */
    }

    @IBAction func todayButtonPressed(_ sender: Any) {
        compactCalendar.setDateToToday()
    }

}

extension ViewController: CompactCalendarDelegate {

    func compactCalendar(_ compactCalendar: CompactCalendar, didSelectCalendarCellWith date: Date, isAlreadySelected: Bool) {
        let dateString = dateFormatter.string(from: date)
        print(dateString)
        dateLabel.text = dateString
    }

    func didGoToNextPage(_ compactCalendar: CompactCalendar, weeksAhead: Int) {
        print("Going to next page")
    }

    func didGoToPreviousPage(_ compactCalendar: CompactCalendar, weeksAhead: Int) {
        print("Going to previous page")
    }


}

