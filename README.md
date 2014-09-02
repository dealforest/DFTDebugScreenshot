# DFTDebugScreenshot
[![Badge w/ Version](http://cocoapod-badges.herokuapp.com/v/DFTDebugScreenshot/badge.png)](http://cocoadocs.org/docsets/DFTDebugScreenshot)
[![Badge w/ Platform](http://cocoapod-badges.herokuapp.com/p/DFTDebugScreenshot/badge.png)](http://cocoadocs.org/docsets/DFTDebugScreenshot)


Simple debug tool for screenshot.

It will write out the debug image of the ViewController being displayed.

![demo](https://github.com/dealforest/DFTDebugScreenShot/raw/master/images/demo.gif)

## Requirements
* iOS 7.0 or later
* only ARC

## Usage

1) In your Podfile:

```
pod 'DFTDebugScreenShot'
```

2) In your .m files:

```
#import <DFTDebugScreenshot/DFTDebugScreenshot.h>
```

3) write to the code(`- [UIViewController dft_debugObjectForDebugScreenshot]`) for the debug information.

```objective-c
@implementation DFTViewController
... 
- (id)dft_debugObjectForDebugScreenshot {
    return [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
}
...
@end
```

### Using auto capture
When you take a screenshot, and automatically write out the debug image.

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  ...
  [DFTDebugScreenshot setTracking:YES];
  ...
}
```

### Without auto capture
It will write out the debug image at the timing at which you intended.

```objective-c
- (IBAction)touchedCaptureButton {
  [DFNDebugScreenshot capture];
}
```

## Without CocoaPods 

If you don’t want to use CocoaPods you can use[CocoaPods Packager](https://github.com/CocoaPods/cocoapods-packager) to generate a static version of DFTDebugScreenshot and just embed that.

## Demo

```shell
$ pod install
$ open DFTDebugScreenshotDemo.xcworkspace
```

## Change log

see [Releases](https://github.com/dealforest/DFTDebugScreenshot/releases)

## License

Copyright (c) 2014 Toshihiro Morimoto

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
