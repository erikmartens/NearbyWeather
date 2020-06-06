<p align="center">
<img src="Resources/app_icon.png" alt="NearbyWeather for iOS" height="128" width="128">
</p>

<h1 align="center">NearbyWeather - OpenWeatherMap Client</h1>

<p align="center">
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-5-orange.svg?style=flat" alt="Swift"/></a>
<img src="https://img.shields.io/badge/Platform-iOS%2011.0+-lightgrey.svg" alt="Platform: iOS">
<img src="https://img.shields.io/github/license/erikmartens/NearbyWeather.svg?style=flat" alt="License: MIT">
<a href="https://github.com/erikmartens/NearbyWeather/graphs/contributors"><img src="https://img.shields.io/github/contributors/erikmartens/NearbyWeather.svg?style=flat" alt="Contributors"></a>
<a href="https://twitter.com/erik_martens"><img src="https://img.shields.io/badge/Twitter-@erik_martens-blue.svg" alt="Twitter: @erik_martens"/></a>
<a href="https://discord.gg/fxPgKzC"><img src="https://img.shields.io/discord/717413902689894411.svg?style=shield" alt="Discord: NearbyWeather by Erik Martens"/></a>
</p>
<p align="center">
<a href="https://itunes.apple.com/app/nearbyweather/id1227313069"><img src="Resources/app_store_badge.svg" alt="Download on the App Store"/></a>
</p>

<p align="center">
<img src="Resources/screenshots.PNG" alt="NearbyWeather Screenshots">
</p>

## About the App
NearbyWeather is a simple weather app, that provides current weather information for nearby cities, as well for bookmarked locations. NearbyWeather uses the OpenWeatherMap API to download weather data. Additionally the OpenWeatherMaps location database is directly bootstrapped into the app for quick access.

With NearbyWeather you can:

- See current weather information for bookmarked and nearby places via a list and a map view
- See the current temperature on your app icon
- Detailed weather information is offered in addition to the overviews
- Add places as bookmarks via OpenWeatherMaps weather-station data base
- Choose your preferred units (celsius/fahrenheit/kelvin & kilometres/miles)
- Access previously loaded data offline

> Please note that you need to supply your own OpenWeatherMap API key, in order to use the app. A free tier API key only allows for 60 requests per minute, which may only be sufficient for a single user. As the app is available at no charge, a paid tier API key can not be included. 

> Downloading data for a bookmarked location counts as one request. Downloading bulk data for nearby places also counts as a single request, regardless of the amount of results you choose. You can add bookmarks indefinitely, but for example exceeding the 60 requests limit with a free tier API key may result in a failure to download data (this scenario has not been tested and depends of the tier of your API key).

## Goals of this Project
NearbyWeather should help you as a reference for your development. Whether you just started iOS development or want to learn more about Swift by seeing in action, this project is here for your guidance. Idealy you already have gained some experience or got your feet wet with mobile development. NearbyWeather is created to teach basic principles of iOS development, including but not limited to:

- Programming concepts such as delegation, closures, generics & extensions
- Avoidance of retain cycles
- Swift language features such as codables
- Persisiting data
- Using various UIKit classes
- Various Apple-iOS-Components such as UserDefaults or NotificationCenter
- Using MapKit and customising maps
- Accessing and using the user's location
- Language localization
- Network requests
- Using 3rd part REST-APIs
- Using 3rd party libraries via CocoaPods
- Using support scripts for creating bootstrapped/bundle resources
- Accessing bootstrapped/bundle resources
- "DevOps" tools such as Fastlane or SwiftLint

It therefore otherwise refrains from advanced concepts. The architecture is kept simple by using [Apple's recommended MVC pattern](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html). This architecture is fine for a small projects like this one. For complex apps there are better options, such as MVVM, VIP (Clean Swift) or even VIPER. The chosen architecture may for example limit the testability of the project, but then again for simplicty sake there are no unit tests present at all. Additionally the app uses singeltons for all services and managers. This further hinders testing. A better approach to enable this would be dependency injection. Furthermore delegation is used only losely. 

## Getting Started
In order to get started, fork the project and clone it to your local machine. 

In order to open the project and in oder to run it, you will need to have the latest Apple developer tools installed, namely Xcode. 

For libraries this app uses the dependency manager [Cocoa Pods](https://cocoapods.org). Pods are not checked into the repository, so you will have run `pod install` in the project base directory after cloning. Additionally it might be helpful to set up signing through [fastlane match](https://docs.fastlane.tools/actions/match/). Create your own repo to store your personal sigining certificates and provisioning profiles and adapt the `./fastlane/Matchfile` accordingly. _Make sure to never commit these changes or your pull requests will be rejected._

## Contributing

We looking forward to receiving your contributions. You can find more information in the [contribution docs](https://github.com/erikmartens/NearbyWeather/blob/master/CONTRIBUTING.md).

Additionally you may also assist as a beta tester. Periodically test-builds will become available via Testflight. In order to take part in testing those submit an email address used as an Apple-ID to [erikmartens.developer@gmail.com](mailto:erikmartens.developer@gmail.com) to be added to the list of testers.

## Future Developments
- Integrate RxSwift for reactive scenes
- Refactor scene-architecture using the MVVM+C pattern and define UI programmatically via autolayout
- SwiftUI previews for ViewControllers using mock models
- Integrate Realm for data persistence
- Include Unit Tests for Services
- Include UITests for Scenes
- Setup CI and CD with Bitrise
