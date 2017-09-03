# MZLocationPicker

Simple to use location picker. As for developer, so for users, too. 

Yet, it still presents: reverse geocoding for location chosen in map, location search, history of chosen locations, multiple map types, custom pins, custom tint color, support for translations using delegate, landscape as well as portrait orientation.

[![Version](https://img.shields.io/cocoapods/v/MZLocationPicker.svg?style=flat)](http://cocoapods.org/pods/MZLocationPicker)
[![License](https://img.shields.io/cocoapods/l/MZLocationPicker.svg?style=flat)](http://cocoapods.org/pods/MZLocationPicker)
[![Platform](https://img.shields.io/cocoapods/p/MZLocationPicker.svg?style=flat)](http://cocoapods.org/pods/MZLocationPicker)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MZLocationPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MZLocationPicker"
```

## Usage 

For simple usage just implement MZLocationPickerDelegate methods and present picker like this:

```ruby
let picker = MZLocationPickerController()
picker.delegate = self
present(picker, animated: true, completion: nil)
```

However, you can also customize the picker a bit more:

```ruby
let picker = MZLocationPickerController()
picker.delegate = self
picker.tintColor = .purple
picker.annotation.image = #imageLiteral(resourceName: "custom_pin")
picker.annotation.centerOffset = CGPoint(x: 0, y: 24)
picker.mapType = .satellite
picker.translator = self
present(picker, animated: true, completion: nil)
```

## Known issues

- When map type is flyover, search is not displayed correctly. For best functionality, avoid using flyover map types.

## Author

Michal Ziman, ziman@reinto.cz

## License

MZLocationPicker is available under the MIT license. See the LICENSE file for more info.
