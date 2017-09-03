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
This location picker allows user to choose location by tapping in map view, searching for it by name or address or by selecting recently picked location.
It presents: reverse geocoding for location chosen in map, location search, history of chosen locations, multiple map types, custom pins, custom tint color, support for translations using delegate, landscape as well as portrait orientation.
It is designed to match general picker design such as the one used in Contact picker.
It is intended to be presented modally, though it is not necessary.
    DESC

    s.homepage         = 'https://github.com/michalziman/mz-location-picker'
    s.screenshots      = 'https://raw.githubusercontent.com/michalziman/mz-location-picker/master/screenshot1.png', 'https://raw.githubusercontent.com/michalziman/mz-location-picker/master/screenshot2.png', 'https://raw.githubusercontent.com/michalziman/mz-location-picker/master/screenshot3.png', 'https://raw.githubusercontent.com/michalziman/mz-location-picker/master/screenshot4.png'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Michal Ziman' => 'michalziman@me.cz' }
    s.source           = { :git => 'https://github.com/michalziman/mz-location-picker.git', :tag => s.version.to_s }

    s.ios.deployment_target = '10.0'

    s.source_files = 'MZLocationPicker/**/*.swift'

    s.resources = ['MZLocationPicker/*.xib', 'MZLocationPicker/*.xcassets', 'MZLocationPicker/MZLocationPickerHistory.xcdatamodeld']


    s.frameworks = 'UIKit', 'MapKit', 'CoreData'
end
