# DKLogger

[![CI Status](https://img.shields.io/travis/winterrain5/DKLogger.svg?style=flat)](https://travis-ci.org/winterrain5/DKLogger)
[![Version](https://img.shields.io/cocoapods/v/DKLogger.svg?style=flat)](https://cocoapods.org/pods/DKLogger)
[![License](https://img.shields.io/cocoapods/l/DKLogger.svg?style=flat)](https://cocoapods.org/pods/DKLogger)
[![Platform](https://img.shields.io/cocoapods/p/DKLogger.svg?style=flat)](https://cocoapods.org/pods/DKLogger)

## Example


```swift
Logger.debug("hello world")
Logger.info("hello world")
Logger.warn("hello world")
Logger.error("hello world")
```
- 设置路径和文件名称
```swift
Logger.cacheDirectory = ""
Logger.cacheTxtName = ""
```
- 设置debug模式下是否写入文件 默认不写入
```swift
Logger.isEnableWriteToFileInDebugMode = true
```




To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DKLogger is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DKLogger'
```

## Author

winterrain5, 913419042@qq.com

## License

DKLogger is available under the MIT license. See the LICENSE file for more info.

