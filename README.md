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
### Unarchive object
The user comment of EXIF write debug object HEX.
So you can get object by unarchive it.

```objective-c
id debugObject = [DFTDebugScreenshot unarchiveObjectWithHex:@"<62706c69 73743030 d4010203 040506bb bc582476 65727369 6f6e5824 6f626a65 63747359 24617263 68697665 72542474 6f701200 0186a0af 102c0708 19242526 2728292a 313b3c3d 47484953 54555f60 616b6c6d 77787983 84858f90 919b9c9d a7a8a9b3 b4b55524 6e756c6c d2090a0b 185a4e53 2e6f626a 65637473 5624636c 617373ac 0c0d0e0f 10111213 14151617 8002800a 800d8010 80138016 8019801c 801f8022 80258028 802bd31a 090a1b1f 23574e53 2e6b6579 73a31c1d 1e800380 048005a3 20212280 06800780 08800952 6964546e 616d6559 696d706f 7274616e 74100157 6e616d65 3a20315f 10285468 6520696e 666f726d 6174696f 6e206973 20726571 75697265 6420666f 72206465 6275672e 2e2ed22b 2c2d2e5a 24636c61 73736e61 6d655824 636c6173 7365735c 4e534469 6374696f 6e617279 a22f305c 4e534469 6374696f 6e617279 584e534f 626a6563 74d31a09 0a323623 a31c1d1e 80038004 8005a337 3822800b 800c8008 80091002 576e616d 653a2032 d31a090a 3e4223a3 1c1d1e80 03800480 05a34344 22800e80 0f800880 09100357 6e616d65 3a2033d3 1a090a4a 4e23a31c 1d1e8003 80048005 a34f5022 80118012 80088009 1004576e 616d653a 2034d31a 090a565a 23a31c1d 1e800380 048005a3 5b5c2280 14801580 08800910 05576e61 6d653a20 35d31a09 0a626623 a31c1d1e 80038004 8005a367 68228017 80188008 80091006 576e616d 653a2036 d31a090a 6e7223a3 1c1d1e80 03800480 05a37374 22801a80 1b800880 09100757 6e616d65 3a2037d3 1a090a7a 7e23a31c 1d1e8003 80048005 a37f8022 801d801e 80088009 1008576e 616d653a 2038d31a 090a868a 23a31c1d 1e800380 048005a3 8b8c2280 20802180 08800910 09576e61 6d653a20 39d31a09 0a929623 a31c1d1e 80038004 8005a397 98228023 80248008 8009100a 586e616d 653a2031 30d31a09 0a9ea223 a31c1d1e 80038004 8005a3a3 a4228026 80278008 8009100b 586e616d 653a2031 31d31a09 0aaaae23 a31c1d1e 80038004 8005a3af b0228029 802a8008 8009100c 586e616d 653a2031 32d22b2c b6b75e4e 534d7574 61626c65 41727261 79a3b8b9 ba5e4e53 4d757461 626c6541 72726179 574e5341 72726179 584e534f 626a6563 745f100f 4e534b65 79656441 72636869 766572d1 bdbe5472 6f6f7480 01000800 11001a00 23002d00 32003700 66006c00 71007c00 83009000 92009400 96009800 9a009c00 9e00a000 a200a400 a600a800 aa00b100 b900bd00 bf00c100 c300c700 c900cb00 cd00cf00 d200d700 e100e300 eb011601 1b012601 2f013c01 3f014c01 55015c01 60016201 64016601 6a016c01 6e017001 72017401 7c018301 87018901 8b018d01 91019301 95019701 99019b01 a301aa01 ae01b001 b201b401 b801ba01 bc01be01 c001c201 ca01d101 d501d701 d901db01 df01e101 e301e501 e701e901 f101f801 fc01fe02 00020202 06020802 0a020c02 0e021002 18021f02 23022502 27022902 2d022f02 31023302 35023702 3f024602 4a024c02 4e025002 54025602 58025a02 5c025e02 66026d02 71027302 75027702 7b027d02 7f028102 83028502 8d029402 98029a02 9c029e02 a202a402 a602a802 aa02ac02 b502bc02 c002c202 c402c602 ca02cc02 ce02d002 d202d402 dd02e402 e802ea02 ec02ee02 f202f402 f602f802 fa02fc03 05030a03 19031d03 2c033403 3d034f03 52035700 00000000 00020100 00000000 0000bf00 00000000 00000000 00000000 000359>"];
```

### If you want to copy clipboard
It is stored in the meta-data(EXIF:userComment),  please copy from the meta-data.

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
