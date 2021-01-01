platform :ios, '11.0'

# ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!

def nearbyweather_pods
    pod 'PKHUD', '~> 5.3.0'
    pod 'TextFieldCounter', '~> 1.1.0'
    pod 'Alamofire', '~> 4.9.1'
    pod 'APTimeZones', :git => 'https://github.com/Alterplay/APTimeZones.git', :branch => 'master', :commit => '9ffd147'
    pod 'FMDB', '~> 2.7.5'
    pod 'RealmSwift', '~> 4.4.1'
    pod 'Swinject', '~> 2.7.1'

    pod 'RxSwift', '~> 5.1.1'
    pod 'RxCocoa', '~> 5.1.1'
    pod 'RxOptional', '~> 4.1.0'
    pod 'RxFlow', '~> 2.7.0'
    pod 'RxRealm', '~> 2.0.0'
    pod 'RxAlamofire', '~> 5.1.0'
    pod 'RxCoreLocation', '~> 1.4.2'

    pod 'SwiftLint', '~> 0.38.2'
    pod 'R.swift', '5.0.3'

    pod 'Firebase/Analytics', '~> 6.21.0'
    pod 'Firebase/Crashlytics', '~> 6.21.0'
end

target 'NearbyWeather' do
    nearbyweather_pods
end  

target 'NearbyWeatherTests' do
    nearbyweather_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      next if config.name.downcase.include? 'debug'
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
      cflags << '-fembed-bitcode'
      config.build_settings['OTHER_CFLAGS'] = cflags
    end
  end
end
