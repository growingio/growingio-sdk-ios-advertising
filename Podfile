# source 'https://github.com/growingio/giospec.git'
# source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

install!'cocoapods',:deterministic_uuids=>false
platform :ios, '10.0'

workspace 'GrowingAdvertising.xcworkspace'

target 'Example' do
  project 'Example/Example'
  pod 'GrowingAnalytics/Autotracker'
  pod 'GrowingAdvertising', :path => './'
  pod 'GrowingToolsKit'
end

target 'GrowingAdvertisingTests' do
   project 'Example/Example'
   pod 'GrowingAnalytics/Autotracker'
   pod 'GrowingAdvertising', :path => './'
end

target 'ExampleiOS13' do
  project 'Example/Example'
  pod 'GrowingAnalytics/Autotracker'
  pod 'GrowingAdvertising', :path => './'
  pod 'GrowingToolsKit'
end
