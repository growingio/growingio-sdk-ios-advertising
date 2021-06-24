#
# Be sure to run `pod lib lint GrowingIO.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowingAdvertising'
  s.version          = '0.0.1'
  s.summary          = 'iOS SDK of GrowingIO.'
  s.description      = <<-DESC
GrowingAdvertising具备采集广告事件，包括activate,reengage,vst
                       DESC

  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/growingio-sdk-ios-advertising.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'WebKit'
  s.requires_arc = true
  s.default_subspec = "Core"
  
  s.subspec 'Core' do |core|
      core.source_files = 'GrowingAdvertising/**/*{.h,.m,.c,.cpp,.mm}'
      core.dependency 'GrowingAnalytics/TrackerCore'
      core.dependency 'GrowingAnalytics/Network'
  end


end
