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

##Screenshots

![ScreenShot](https://raw.githubusercontent.com/greencoder/mybitly/master/Docs/splash.png)
![ScreenShot](https://raw.githubusercontent.com/greencoder/mybitly/master/Docs/list.png)
![ScreenShot](https://raw.githubusercontent.com/greencoder/mybitly/master/Docs/details.png)
![ScreenShot](https://raw.githubusercontent.com/greencoder/mybitly/master/Docs/save.png)

