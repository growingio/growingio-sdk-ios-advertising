# source 'https://github.com/growingio/giospec.git'
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/aliyun/aliyun-specs.git'

use_frameworks!

install!'cocoapods',:deterministic_uuids=>false
platform :ios, '8.0'

workspace 'GrowingAdvertising.xcworkspace'

target 'Example' do
  project 'Example/Example'
  pod 'GrowingAnalytics/Autotracker', :path => './../growingio-sdk-ios-autotracker'
  pod 'GrowingAnalytics/TrackerCore', :path => './../growingio-sdk-ios-autotracker'
  pod 'GrowingAdvertising', :path => './'
#  pod 'GrowingAnalytics/DISABLE_IDFA', :path => './' #禁用idfa
  pod 'SDCycleScrollView', '~> 1.75'
  pod 'MJRefresh'
  pod 'MBProgressHUD'
  pod 'AlicloudPush', '~> 1.9.8'
end



