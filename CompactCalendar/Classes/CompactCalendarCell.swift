import UIKit

final class CompactCalendarCell: UICollectionViewCell {

    static let selectedDateDefaultBackgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)

    private let highlightWidth: CGFloat = 34.0
    private let calendarPastDate: UIColor = UIColor.black.withAlphaComponent(0.5)

    enum CellType {
        case normal
        case inThePast
        case today
        case selected
    }

    private let highlightedView = UIView()
    private let dayLabel = UILabel()

    var selectedColor: UIColor
    var textColor: UIColor
    var selectedTextColor: UIColor
    var font: UIFont

    var date: Date? {
        didSet {
            if let date = date {
                dayLabel.text = "\(DateHelpers.dayComponent(of: date))"
                accessibilityLabel = DateHelpers.monthDayFormatter.string(from: date)
            }
        }
    }

    override init(frame: CGRect) {
        selectedColor = CompactCalendarCell.selectedDateDefaultBackgroundColor
        selectedTextColor = .white
        textColor = .black
        font = .systemFont(ofSize: 16)
        super.init(frame: frame)

        highlightedView.layer.borderWidth = 1.0
        highlightedView.layer.cornerRadius = highlightWidth / 2
        highlightedView.clipsToBounds = true

        dayLabel.font = font
        dayLabel.textColor = textColor
        dayLabel.textAlignment = .center

        addSubview(highlightedView)
        addSubview(dayLabel)
        translatesAutoresizingMaskIntoConstraints = false
        highlightedView.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for cellType: CellType) {
        isAccessibilityElement = true
        accessibilityTraits = .button

        switch cellType {
        case .normal:
            dayLabel.textColor = textColor
            highlightedView.layer.borderColor = UIColor.clear.cgColor
            highlightedView.backgroundColor = .clear
        case .inThePast:
            dayLabel.textColor = textColor.withAlphaComponent(0.5)
            highlightedView.layer.borderColor = UIColor.clear.cgColor
            highlightedView.backgroundColor = .clear
        case .today:
            dayLabel.textColor = selectedColor
            highlightedView.layer.borderColor = selectedColor.cgColor
            highlightedView.backgroundColor = .clear
        case .selected:
            dayLabel.textColor = selectedTextColor
            highlightedView.layer.borderColor = selectedColor.cgColor
            highlightedView.backgroundColor = selectedColor
            accessibilityTraits.insert(.selected)
        }
    }

    func setupConstraints() {
        let margins = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            highlightedView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            highlightedView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            highlightedView.heightAnchor.constraint(equalToConstant: highlightWidth),
            highlightedView.widthAnchor.constraint(equalTo: highlightedView.heightAnchor),

            dayLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            dayLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            dayLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
}
