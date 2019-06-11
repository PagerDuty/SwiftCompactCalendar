import UIKit

public class CompactCalendar: UIView {

    // MARK: - Private Constants

    public enum ConfigurableView {
        case monthBar
        case daysOfTheWeekBar
        case datesView
        case selectedDateView
        case monthBarButtons
        case all
    }

    private let calendarCellReuseIdentifier = "CalendarCell"
    private let collectionViewAccessibilityLabel = "2 week calendar view"

    // MARK: - Public Constants

    public static let suggestedHeight = 165
    public static let defaultDaysOfWeekText = ["S", "M", "T", "W", "T", "F", "S"]

    // MARK: - IBOutlets

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var daysOfWeekStackView: UIStackView!
    @IBOutlet weak var monthBar: UIView!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var previousPageButton: UIButton!

    // MARK: - Private Variables

    private var collectionViewContentWidth: CGFloat {
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    private lazy var weeksAhead: Int = 0
    private var isScrolling = false
    private var selectedIndexPath: IndexPath?
    private var loadToday = false
    private var scrollOnAppear = true
    private var fetchOnAppear = true
    private var model: CompactCalendarModel

    private var selectedDateBackgroundColor: UIColor? {
        didSet {
            guard let collectionView = collectionView else {
                return
            }
            collectionView.reloadData()
        }
    }

    private var selectedDateForegroundColor: UIColor? {
        didSet {
            guard let collectionView = collectionView else {
                return
            }
            collectionView.reloadData()
        }
    }

    private var datesViewForegroundColor: UIColor? {
        didSet {
            guard let collectionView = collectionView else {
                return
            }
            collectionView.reloadData()
        }
    }

    private var datesViewFont: UIFont? {
        didSet {
            guard let collectionView = collectionView else {
                return
            }
            collectionView.reloadData()
        }
    }


    // MARK: - Public Variables

    public weak var delegate: CompactCalendarDelegate?

    // MARK: - Initializers

    override init(frame: CGRect) {
        self.model = CompactCalendarModel(today: Date(), initiallySelectedDate: Date(), calendar: Calendar.current, timeZone: TimeZone.current)
        super.init(frame: frame)
        setUpNib()
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        self.model = CompactCalendarModel(today: Date(), initiallySelectedDate: Date(), calendar: Calendar.current, timeZone: TimeZone.current)
        super.init(coder: aDecoder)
        setUpNib()
        configure()
    }

    // MARK: - Overridden Methods

    override public func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(CompactCalendarCell.self, forCellWithReuseIdentifier: calendarCellReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.accessibilityLabel = collectionViewAccessibilityLabel

        nextPageButton.setImage(tintedImage(named: "chevronRightGrey"), for: .normal)
        previousPageButton.setImage(tintedImage(named: "chevronLeftGrey"), for: .normal)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        setupCollectionView()
    }

    private func setUpNib() {
        let bundle = Bundle(for: CompactCalendar.self)
        bundle.loadNibNamed("CompactCalendar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    // MARK: - Public Methods

    /**
     Sets up the Compact Calendar for the specified date selected, current date (today), days of week labels, calendar and timeZone

     - Parameters:
         - selectedDate: The date that is selected and showing on the Compact Calendar (Set to current date by default)
         - today: The date that shows as today on the CompactCalendar and is selected upon calling `setDateToToday()` (Set to current date by default)
         - daysOfTheWeekText: The array of strings containing the text for labels for the days of the week from left to right ([S,M,T,W,T,F,S] by default)
         - calendar: Calendar to be used for managing dates (`Calendar.current` by default)
         - timeZone: TimeZone to be used for managing dates (`TimeZone.current` by default)

     - Precondition: `textForLabels` and `daysOfWeekStackView.arrangedSubviews` are of equal length

    */
    public func configure(selectedDate: Date = Date(), today: Date = Date(), daysOfTheWeekText: [String] = CompactCalendar.defaultDaysOfWeekText, calendar: Calendar = Calendar.current, timeZone: TimeZone = TimeZone.current) {
        self.model = CompactCalendarModel(today: today, initiallySelectedDate: selectedDate, calendar: calendar, timeZone: timeZone)
        self.model.loadDates()
        // these two lines are necessary to get the collection view to size its content view
        // according to how many dates there are.
        collectionView.reloadData()
        DispatchQueue.main.async { [weak self] in
            self?.setupCollectionView()
        }
        collectionView.collectionViewLayout.invalidateLayout()

        if model.weekStartsOnMonday() {
            shuffleWeekdayHeaders()
        }

        let initialDateCount = model.pastDays + model.previousDays
        selectedIndexPath = IndexPath(row: initialDateCount, section: 0)

        updateMonthLabel(for: model.initiallySelectedDate)

        setDaysOfWeekLabels(withValues: daysOfTheWeekText)

        delegate?.compactCalendar(self, didSelectCalendarCellWith: selectedDate, isAlreadySelected: false)
    }

    /**
     Selects and scrolls to today's date on the Compact Calendar

     - Precondition: configure() has been invoked on the instance

    */
    public func setDateToToday() {
        let contentOffset = collectionView.contentOffset

        let whichPage = model.pastDays / 14 // integer arithmetic on purpose; don't want a remainder.
        let newOffset = CGFloat(whichPage) * collectionViewContentWidth
        // If we need to scroll back to today, do so and ask it to load today when it's done
        // otherwise, we're on the right calendar page, just select today.
        if contentOffset.x != newOffset {
            isScrolling = true
            collectionView.setContentOffset(CGPoint(x: newOffset, y: contentOffset.y), animated: true)
            loadToday = true
        } else {
            selectToday()
        }
    }

    /**
     Sets the background color of the specified view to the specified color

     Reloads collectionView if changes are made to `selectedDateView` or `datesView`

     - Parameters:
         - view: The ConfigurableView who's background will be changed
         - color: The Color that the ConfigurableView's background should be set to
    */
    public func setBackground(forConfigurableView view: ConfigurableView, to color: UIColor) {
        switch view {
        case .monthBar:
            monthBar.backgroundColor = color
        case .monthBarButtons:
            nextPageButton.backgroundColor = color
            previousPageButton.backgroundColor = color
        case .daysOfTheWeekBar:
            contentView.backgroundColor = color
        case .datesView:
            collectionView.backgroundColor = color
        case .selectedDateView:
            selectedDateBackgroundColor = color
        case .all:
            monthBar.backgroundColor = color
            collectionView.backgroundColor = color
            contentView.backgroundColor = color
            nextPageButton.backgroundColor = .clear
            previousPageButton.backgroundColor = .clear
        }
    }

    /**
     Sets the forground color of the specified view to the specified color

     Reloads collectionView if changes are made to `selectedDateView` or `datesView`
     - Parameters:
     - view: The ConfigurableView who's forground will be changed
     - color: The Color that the ConfigurableView's foreground should be set to
     */
    public func setForeground(forConfigurableView view: ConfigurableView, to color: UIColor) {
        switch view {
        case .monthBar:
            monthYearLabel.textColor = color
        case .monthBarButtons:
            nextPageButton.tintColor = color
            previousPageButton.tintColor = color
        case .daysOfTheWeekBar:
            daysOfWeekStackView.arrangedSubviews.forEach {
                guard let label = $0 as? UILabel else {
                    return
                }
                label.textColor = color
            }
        case .datesView:
            datesViewForegroundColor = color
        case .selectedDateView:
            selectedDateForegroundColor = color
        default:
            return
        }
    }

    /**
     Sets the font of the specified view to the specified font

     Reloads collectionView if changes are made to `selectedDateView` or `datesView`

     - Parameters:
     - view: The ConfigurableView who's font will be changed
     - color: The Font that the ConfigurableView's font should be set to
     */
    public func setFont(forConfigurableView view: ConfigurableView, to font: UIFont) {
        switch view {
        case .monthBar:
            monthYearLabel.font = font
        case .daysOfTheWeekBar:
            daysOfWeekStackView.arrangedSubviews.forEach {
                guard let label = $0 as? UILabel else {
                    return
                }
                label.font = font
            }
        case .datesView:
            datesViewFont = font
        default:
            return
        }
    }

    // MARK: - IBActions

    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        nextPage()
        adjustContentOffset(didGoToPreviousPage: false, didSwipeView: false)
    }

    /// This moves the calendar collection view forward by a page.
    /// In order to use this, you need to follow it up with `func adjustContentOffset(forGoingToPreviousPage:)`
    private func nextPage() {
        guard !isScrolling, let firstVisibleIndex = collectionView.indexPathsForVisibleItems.min()?.row else { return }

        if let (startIndex, endIndex) = model.generateFutureDates(from: firstVisibleIndex) {
            let indexPaths = (startIndex ... endIndex).map {
                IndexPath(row: $0, section: 0)
            }
            collectionView.insertItems(at: indexPaths)
            collectionView.collectionViewLayout.invalidateLayout()
        }
        weeksAhead = firstVisibleIndex / 7 - model.pastDays / 7 + 2

        delegate?.didGoToNextPage(self, weeksAhead: weeksAhead)
    }

    @IBAction func backwardButtonTapped() {
        previousPage()
        adjustContentOffset(didGoToPreviousPage: true, didSwipeView: false)
    }

    // MARK: Private Methods

    /// This moves the calendar collection view backwards by a page.
    /// In order to use this, you need to follow it up with `func adjustContentOffset(forGoingToPreviousPage:)`
    private func previousPage() {
        guard let firstVisibleIndex = collectionView.indexPathsForVisibleItems.min()?.row else { return }

        if model.generatePastDates(from: firstVisibleIndex) != nil {
            collectionView.reloadData()
            selectedIndexPath?.row += 14
            collectionView.collectionViewLayout.invalidateLayout()
            let contentOffset = collectionView.contentOffset
            collectionView.setContentOffset(CGPoint(x: contentOffset.x + collectionViewContentWidth, y: contentOffset.y), animated: false)
            weeksAhead = firstVisibleIndex / 7 - model.pastDays / 7
        } else {
            weeksAhead = firstVisibleIndex / 7 - model.pastDays / 7 - 2
        }

        delegate?.didGoToPreviousPage(self, weeksAhead: weeksAhead)
    }

    // MARK: - Collection View

    private func date(forIndexPath indexPath: IndexPath) -> Date? {
        return (collectionView.cellForItem(at: indexPath) as? CompactCalendarCell)?.date
    }

    private func setupCollectionView() {
        guard let indexPath = selectedIndexPath else {
            return
        }
        if scrollOnAppear {
            scrollToSegment(indexPath)
        }
        if fetchOnAppear {
            select(dateAtIndexPath: indexPath)
            if let selectedDate = date(forIndexPath: indexPath) {
                updateMonthLabel(for: selectedDate)
            }
        }
    }

    private func selectToday() {
        loadToday = false
        select(dateAtIndexPath: IndexPath(row: model.pastDays, section: 0))
    }

    private func select(dateAtIndexPath indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? CompactCalendarCell,
            let selectedDate = selectedCell.date
            else { return }

        var isAlreadySelected = false

        if let previousIndexPath = selectedIndexPath,
            let previousSelectedCell = collectionView.cellForItem(at: previousIndexPath) as? CompactCalendarCell,
            let previousSelectedCellDate = previousSelectedCell.date {
            isAlreadySelected = previousIndexPath == indexPath
            if previousSelectedCellDate < model.today {
                previousSelectedCell.configure(for: .inThePast)
            } else {
                previousSelectedCell.configure(for: .normal)
            }
        }

        if let todayCell = collectionView.cellForItem(at: IndexPath(row: model.pastDays, section: 0)) as? CompactCalendarCell {
            todayCell.configure(for: .today)
        }

        selectedCell.configure(for: .selected)
        selectedIndexPath = indexPath

        delegate?.compactCalendar(self, didSelectCalendarCellWith: selectedDate, isAlreadySelected: isAlreadySelected)
    }

    /// Use this method as a follow-up to `previousPage` or `nextPage`.
    /// I separated this part out because it caused an animation glitch if I didn't separate this
    /// in the scrollViewWillEndDragging from the other methods in scrollViewWillBeginDragging
    private func adjustContentOffset(didGoToPreviousPage: Bool, didSwipeView: Bool) {
        guard !isScrolling else { return }
        let contentOffset = collectionView.contentOffset
        let contentOffsetX = didGoToPreviousPage ? contentOffset.x - collectionViewContentWidth : contentOffset.x + collectionViewContentWidth
        isScrolling = true
        collectionView.setContentOffset(CGPoint(x: contentOffsetX, y: contentOffset.y), animated: true)
    }

    private func updateCompactCalendarAfterScrolling(_ scrollView: UIScrollView) {
        let cellWidth = collectionViewContentWidth / CGFloat(7)
        let currentIndex = Int(scrollView.contentOffset.x / CGFloat((cellWidth / 2)))
        let firstIndex = IndexPath(row: currentIndex, section: 0)
        let lastIndex = IndexPath(row: currentIndex + 13, section: 0)

        guard let firstDate = self.date(forIndexPath: firstIndex),
            let lastDate = self.date(forIndexPath: lastIndex)
            else { return }

        setMonthLabel(firstDate: firstDate, lastDate: lastDate)
    }

    private func scrollToSegment(_ indexPath: IndexPath) {
        let page = indexPath.row / 14 // Every 14 days is a page/segment
        collectionView.setContentOffset(CGPoint(x: (collectionViewContentWidth * CGFloat(page)), y: collectionView.contentOffset.y), animated: true)
    }

    @objc private func todayTapped() {
        let contentOffset = collectionView.contentOffset

        let whichPage = model.pastDays / 14 // integer arithmetic on purpose; don't want a remainder.
        let newOffset = CGFloat(whichPage) * collectionViewContentWidth
        // If we need to scroll back to today, do so and ask it to load today when it's done
        // otherwise, we're on the right calendar page, just select today.
        if contentOffset.x != newOffset {
            isScrolling = true
            collectionView.setContentOffset(CGPoint(x: newOffset, y: contentOffset.y), animated: true)
            loadToday = true
        } else {
            selectToday()
        }
    }

    // MARK: - Days of Week Stack View

    private func setDaysOfWeekLabels(withValues textForLabels: [String]) {
        guard textForLabels.count == daysOfWeekStackView.arrangedSubviews.count else {
            return
        }
        Array(zip(daysOfWeekStackView.arrangedSubviews, textForLabels)).forEach {
            if let label = $0 as? UILabel {
                label.text = $1
            }
        }
    }

    private func shuffleWeekdayHeaders() {
        // pop out Sunday and move it to the end. :)
        guard let sundayLabel = daysOfWeekStackView.arrangedSubviews.first else { return }
        sundayLabel.removeFromSuperview()
        daysOfWeekStackView.addArrangedSubview(sundayLabel)
    }

    // MARK: - Month Label

    private func tintedImage(named name: String) -> UIImage {
        return UIImage(named: name)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate) ?? UIImage()
    }

    private func monthLabelWithoutYear(_ monthLabel: String) -> String {
        var substrings = monthLabel.split(separator: " ").map(String.init)
        _ = substrings.popLast()
        return substrings.joined(separator: " ")
    }

    private func updateMonthLabel(for date: Date? = nil) {
        if let date = date {
            monthYearLabel?.text = DateHelpers.monthYearFormatter.string(from: date)
        }

        guard let firstIndex = collectionView.indexPathsForVisibleItems.min(),
            let lastIndex = collectionView.indexPathsForVisibleItems.max(),
            let firstDate = self.date(forIndexPath: firstIndex),
            let lastDate = self.date(forIndexPath: lastIndex)
            else { return }

        setMonthLabel(firstDate: firstDate, lastDate: lastDate)
    }

    private func setMonthLabel(firstDate: Date, lastDate: Date) {
        if DateHelpers.monthComponent(of: firstDate) != DateHelpers.monthComponent(of: lastDate) {
            let firstMonth = monthLabelWithoutYear(DateHelpers.monthYearFormatter.string(from: firstDate))
            let lastMonthWithYear = DateHelpers.monthYearFormatter.string(from: lastDate)
            monthYearLabel?.text = "\(firstMonth) – \(lastMonthWithYear)"
        } else {
            monthYearLabel?.text = DateHelpers.monthYearFormatter.string(from: firstDate)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension CompactCalendar: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let previousIndexPath = selectedIndexPath, indexPath != previousIndexPath else {
            return
        }
        select(dateAtIndexPath: indexPath)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCompactCalendarAfterScrolling(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        let didGoToPreviousPage = translation.x > 0
        didGoToPreviousPage ? previousPage() : nextPage()
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // This fixes an animation glitch that happens when the user slowly swipes on the calendar view
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        adjustContentOffset(didGoToPreviousPage: translation.x > 0, didSwipeView: true) // translation.x > 0 means swiped right
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
        if loadToday {
            selectToday()
        } else if let selectedIndexPath = selectedIndexPath {
            // First load of an initially selected date
            select(dateAtIndexPath: selectedIndexPath)
        }

        updateCompactCalendarAfterScrolling(scrollView)
    }
}

// MARK: - UICollectionViewDataSource

extension CompactCalendar: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.dates.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: calendarCellReuseIdentifier, for: indexPath) as? CompactCalendarCell else {
            return CompactCalendarCell()
        }

        if let selectedDateForegroundColor = selectedDateForegroundColor {
            cell.selectedColor = selectedDateForegroundColor
        }
        if let selectedDateBackgroundColor = selectedDateBackgroundColor {
            cell.selectedColor = selectedDateBackgroundColor
        }
        if let datesViewForegroundColor = datesViewForegroundColor {
            cell.textColor = datesViewForegroundColor
        }
        if let datesViewFont = datesViewFont {
            cell.font = datesViewFont
        }

        cell.date = model.dates[indexPath.row]

        let numberOfPastDates = model.pastDays - 1
        if indexPath.row <= numberOfPastDates {
            cell.configure(for: .inThePast)
        } else if indexPath.row == numberOfPastDates + 1 {
            cell.configure(for: .today)
        } else {
            cell.configure(for: .normal)
        }

        if indexPath == selectedIndexPath {
            cell.configure(for: .selected)
        }

        return cell
    }
}
