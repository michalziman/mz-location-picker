#
# Be sure to run `pod lib lint MZLocationPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'MZLocationPicker'
    s.version          = '0.1.0'
    s.summary          = 'MZLocationPicker allows user to select one exact location.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description      = <<-DESC
This location picker allows user to choose location by tapping in map view or searching for it.
It is designed to match general picker design such as the one used in Contact picker.
It is intended to be presented modally, though it is not necessary.
    DESC

    s.homepage         = 'https://github.com/michalziman/MZLocationPicker'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2' #TODO
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Michal Ziman' => 'michalziman@me.cz' }
    s.source           = { :git => 'https://github.com/michalziman/MZLocationPicker.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '10.0'

    s.source_files = 'MZLocationPicker/Classes/**/*'

    s.resources = 'MZLocationPicker/*.xib'
    s.resource_bundles = {
      'MZLocationPicker' => ['Pod/**/*.xib']
    }
# 'MZLocationPicker/Assets/*.png', 

    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    # s.dependency 'AFNetworking', '~> 2.3'
end
