Pod::Spec.new do |s|
  s.name             = 'GrowingAdvertising'
  s.version          = '1.0.0-beta'
  s.summary          = 'iOS SDK of GrowingIO.'
  s.description      = <<-DESC
GrowingAdvertising具备采集广告事件，包括activate,reengage
                       DESC

  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/growingio-sdk-ios-advertising.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'WebKit'
  s.requires_arc = true
  s.default_subspec = "Core"
  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}" "${PODS_ROOT}/GrowingAnalytics"' }

  s.subspec 'Core' do |core|
      core.source_files = 'GrowingAdvertising/**/*{.h,.m,.c,.cpp,.mm}'
      core.public_header_files = 'GrowingAdvertising/Public/*.h'
      core.dependency 'GrowingAnalytics/TrackerCore', '>=3.4.1'
  end
end
