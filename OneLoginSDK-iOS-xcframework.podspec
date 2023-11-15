#
# Be sure to run `pod lib lint OneLoginSDK-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = 'OneLoginSDK-iOS-xcframework'
  s.version = '2.8.6.1'
  s.summary = '极验一键登录SDK'
  s.homepage = 'https://www.geetest.com'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Geetest' => 'develop@geetest.com' }
  s.source = { :git => 'https://github.com/GeeTeam/onelogin-xcframework-support.git', :tag => s.version.to_s, :submodules => true } 
  s.ios.deployment_target = '11.0'

  s.frameworks = 'CFNetwork', 'CoreTelephony', 'Foundation', 'SystemConfiguration', 'UIKit'
  s.weak_frameworks = 'Network'

  # 移动模拟器暂时只给了 x86_64 目标, 需要排除 arm64
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386，arm64', 'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'armv7' }


  s.libraries = 'c++.1', 'z.1.2.8'

  s.subspec 'Main' do |dm|
    dm.vendored_frameworks = 'SDK/EAccountApiSDK.xcframework','SDK/OAuth.xcframework','SDK/account_login_sdk_noui_core.xcframework', 'SDK/TYRZUISDK.xcframework', 'SDK/OneLoginSDK.xcframework'
    dm.resources = 'SDK/OneLoginResource.bundle'
  end

end
