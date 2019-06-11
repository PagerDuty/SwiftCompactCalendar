Pod::Spec.new do |s|
  s.name                  = 'CompactCalendar'
  s.version               = '0.1.0'
  s.summary               = 'A view that displays a calendar two weeks at a time'
  s.description           = 'This CocoaPod provides the ability to use a calendar view'

  s.homepage              = 'https://github.com/PagerDuty/PDCompactCalendar'
  s.license               = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author                = { 'steve509' => 'stran@pagerduty.com' }
  s.source                = { :git => 'https://github.com/PagerDuty/PDCompactCalendar.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.resources             = 'CompactCalendar/Assets/**/*'
  s.source_files          = 'CompactCalendar/Classes/**/*'
  s.swift_versions        = '4.2'
end
