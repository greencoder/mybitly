# My bitly
A demo iOS application using the [bit.ly API](dev.bitly.com).

## Disclaimer

*Note: This repository is NOT affiliated with bitly. It is an independent project and not official any way.*

All logos are the property and copyright of bitly, I use them here respectfully but claim no right to do so. Please respect their copyrights.

## Instructions

To run the application, double-click the [My Bitly.xcworkspace](My%20Bitly.xcworkspace) file. Do not click the [My Bitly.xcodeproj](My%20Bitly.xcodeproj) file, it will not load the dependancies properly.

## Running Xcode Unit Tests

There is a mock API server written in Python in the (Test Server) directory. All the dependent libraries are included locally:
```
$ cd Test\ Server
$ python server.py
```
Once the mock server is running, you can run the unit tests in Xcode using the menu item *Product > Test*. 

Note that the unit tests will *not* hit the live bit.ly API.

## Security

This application will accept your bitly credentials and exchange them directly with the bitly API for an OAuth token. At no time will your username or password be stored, and the access token is stored securely in the iOS keychain.

See the [My Bitly/Managers/MBAPIManager.m](My%20Bitly/Managers/MBAPIManager.m) file for implementation details.


## Open-Source Libraries

This project leverages the hard work of the following libraries: (in no particular order)

* [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD)
* [Reachability](https://github.com/tonymillion/Reachability)
* [MMKeychain](https://github.com/greenisus/MMKeychain)
* [Cocoa Lumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)

All listed projects are installed via [CocoaPods](http://www.cocoapods.org). The pods are embedded in this repository for ease of trying the demo application.


##Screenshots

![ScreenShot](https://raw.githubusercontent.com/greencoder/mybitly/master/Docs/splash.png)
![ScreenShot](https://raw.githubusercontent.com/greencoder/mybitly/master/Docs/list.png)
![ScreenShot](https://raw.githubusercontent.com/greencoder/mybitly/master/Docs/details.png)
![ScreenShot](https://raw.githubusercontent.com/greencoder/mybitly/master/Docs/save.png)

