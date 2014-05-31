Pod::Spec.new do |s|
  s.name             = "BJRadialMenu"
  s.version          = "0.1.0"
  s.summary          = "Animated radial menu for iOS using Facebook's POP library"
  s.description      = <<-DESC
                       BJRadialMenu is a flexible and customizable radial menu control
                       for iOS. It leverages Facebook's awesome POP library to make
                       the motions fluid.
                       DESC
  s.homepage         = "https://github.com/bradjasper/BJRadialMenu"
#  s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Brad Jasper" => "bjasper@gmail.com" }
  s.source           = { :git => "https://github.com/bradjasper/BJRadialMenu.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bradjasper'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'BJRadialMenu'
  s.dependency 'pop', '~> 1.0'
end
