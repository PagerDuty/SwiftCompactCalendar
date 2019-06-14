## Compact Calendar

Compact Calendar is a CocoaPod developed in Swift with a customizable View that displays a Calendar two weeks at a time. 

![Compact Calendar](https://user-images.githubusercontent.com/6761111/59296324-ac283080-8c53-11e9-820c-848eb3a9549b.png)

### Installation

1. Insert the following lines into your Podfile under `target $YOUR_PROJECT_NAME do`:

```
pod 'CompactCalendar'
```

2. Run `pod install`

3. Open your project workspace

### Setting up the Compact Calendar

1. Add a view to the desired View Controller to in your storyboard

![Step 1](https://user-images.githubusercontent.com/6761111/59296457-088b5000-8c54-11e9-825f-46bf642c39e1.png)

2. Place the view where you want it inside the View Controller, add desired constraints and constrain the height to 165. This is to ensure everything fits in the Calendar as expected.

![Step 2](https://user-images.githubusercontent.com/6761111/59296469-0fb25e00-8c54-11e9-8c65-666261dca501.png)

3. Change the view's class in the storyboard from _UIView_ to _CompactCalendar_ under Custom Class

![Step 3](https://user-images.githubusercontent.com/6761111/59296483-18a32f80-8c54-11e9-8834-3571de8141d1.png)

4. Add the Compact Calendar as an _IBOutlet_ in your View Controller's class

![Step 4](https://user-images.githubusercontent.com/6761111/59296498-1fca3d80-8c54-11e9-9eba-8db58e9dc3db.png)


#### _In your View Controller's Swift file_

5. Import _CompactCalendar_ at the top of the file

```Swift
import UIKit
import CompactCalendar
```

6. Make your View Controller conform to `CompactCalendarDelegate` and add the required methods

```Swift
class MyViewController: UIViewController, CompactCalendarDelegate {
  @IBOutlet weak var compactCalendar: CompactCalendar!

  func compactCalendar(_ compactCalendar: CompactCalendar, didSelectCalendarCellWith date: Date, isAlreadySelected: Bool) {

  }

  func didGoToNextPage(_ compactCalendar: CompactCalendar, weeksAhead: Int) {

  }

  func didGoToPreviousPage(_ compactCalendar: CompactCalendar, weeksAhead: Int) {

  }
}
```

7. Set the Compact Calendar's delegate to _MyViewController_ in the `viewDidLoad` method

```Swift
override func viewDidLoad() {
  super.viewDidLoad()
  compactCalendar.delegate = self
}
```

#### Now you are set to customize your Compact Calendar and add your implementations to the delegate methods!

### Customization

The various ways to customize the Compact Calendar are also in _ViewController.swift_ in this repository. You can clone the repo and view the demo app we've provided showing the different ways you can customize the view and it's model.

#### Customizing the model

To customize the model you can add various arguments to the `configure` method from step 7.

```Swift
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
```

#### Customizing the view

You can customize various components of the view by changing their background color, foreground color or font. We've provided three methods `setBackgroundColor`, `setForegroundColor` and `setFont` which take CompactCalendar's _ConfigurableView_ and _UIColor_ or _UIFont_ as arguments and sets the property of the specified configurable view.

##### Configurable Views:

Here are all the names of the configurable views and what they refer to

![Configurable Views](https://user-images.githubusercontent.com/6761111/59296541-37a1c180-8c54-11e9-9575-d95a53934072.png)

Here's how the methods are used to customize the view:

```Swift
// Background Color
compactCalendar.setBackground(forConfigurableView: .monthBar, to: .white)
compactCalendar.setBackground(forConfigurableView: .daysOfTheWeekBar, to: .white)
compactCalendar.setBackground(forConfigurableView: .datesView, to: .white)
// The three lines above are the same as the line below this comment
compactCalendar.setBackground(forConfigurableView: .all, to: .white)

compactCalendar.setBackground(forConfigurableView: .selectedDateView, to: systemRed)

// Foreground Color
compactCalendar.setForeground(forConfigurableView: .monthBar, to: .black)
compactCalendar.setForeground(forConfigurableView: .monthBarButtons, to: systemRed)
compactCalendar.setForeground(forConfigurableView: .daysOfTheWeekBar, to: systemRed)
compactCalendar.setForeground(forConfigurableView: .datesView, to: .black)
compactCalendar.setForeground(forConfigurableView: .selectedDateView, to: .white)

// Font
compactCalendar.setFont(forConfigurableView: .monthBar, to: .systemFont(ofSize: 17))
compactCalendar.setFont(forConfigurableView: .daysOfTheWeekBar, to: .systemFont(ofSize: 13))
compactCalendar.setFont(forConfigurableView: .datesView, to: .systemFont(ofSize: 16))
```

_**Note:** Only `monthBar`, `daysOfTheWeekBar` and `datesView` can have their fonts changed_

### Delegate Methods

There are 3 methods available from the CompactCalendarDelegate protocol:

```Swift
func compactCalendar(_ compactCalendar: CompactCalendar, didSelectCalendarCellWith date: Date, isAlreadySelected: Bool)
```

This method is called once configuring is done and every time the selected date changes i.e. the user selects a cell and the methods `setDateToToday` and `configure` are invoked. The parameters are the Compact Calendar that called the method, the date that was selected and a boolean indicating whether or not the cell was already selected.

The remaining methods:

```Swift
func didGoToNextPage(_ compactCalendar: CompactCalendar, weeksAhead: Int)

func didGoToPreviousPage(_ compactCalendar: CompactCalendar, weeksAhead: Int)
```

When either the button to go to the next page of dates is pressed OR the calendar is swiped, `didGoToNextPage` is called by `compactCalendar` view. The `weeksAhead` parameter is an integer value that represents the number of weeks that the new page is ahead of the previous page. An important thing to note is that this may not always be two weeks since the user may scroll multiple pages before the method is called.

Conversely, when the previous page button is pressed or the user swipes to a previous page, didGoToPreviousPage is called accept weeks ahead would be negative since the previous page will be in the past.

### Other methods

There is one more method at your disposal:

```Swift
setDateToToday()
```

This method will select and scroll to the date you've set as today. You can use this to implement a button to select todays date like we've done in the Demo.

### Contributing

Do you have feedback for our Compact Calendar or want to make a contribution? Create an issue and share your thoughts and concerns! If you want to make a contribution, open up a PR! We'll take a look as soon as we can. Just make sure to stick to the [Swift API Guidelines](https://swift.org/documentation/api-design-guidelines/) and document your code appropriately.

#### Testing

We have Unit Tests in the project to make sure everything's working properly. When making a PR, be sure to add any tests for your additions. When you make the PR, CI should test your branch against master, so make sure your tests are passing once you push!

### Final notes

We're happy to be sharing CompactCalendar on Open Source and welcome any feedback or suggestions for new features, methods or customizations that you would like to see.

Using CompactCalendar in your own app? Send us a link! We'd love to see how you're using it!
