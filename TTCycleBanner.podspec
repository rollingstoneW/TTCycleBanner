#
#  Be sure to run `pod spec lint TTCycleBanner.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "TTCycleBanner"
  spec.version      = "0.0.2"
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.summary      = "A simple cycle banner with image and text"
  spec.description  = <<-DESC
  A simple and elegant cycle banner with image and text
                   DESC

  spec.homepage     = "https://github.com/rollingstoneW/TTCycleBanner"
  spec.author             = { "rollingstoneW" => "190268198@qq.com" }
  spec.platform     = :ios, "8.0"

  spec.source       = { :git => "https://github.com/rollingstoneW/TTCycleBanner.git", :tag => spec.version.to_s }
  spec.source_files  = "Classes", "TTCycleBanner/TTCycleBanner/*.{h,m}"

  spec.frameworks = 'UIKit', 'Foundation'
  spec.dependency "SDWebImage"
  spec.dependency "TTCombineDelegateProxy"

end
