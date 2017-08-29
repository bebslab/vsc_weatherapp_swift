workspace 'WeatherApp'

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'


def weatherapp_pods

pod 'Alamofire'
pod 'DGElasticPullToRefresh', '~> 1.1'
pod 'GoogleMaps', '~> 2.1'
pod 'GooglePlaces', '~> 2.1'
pod 'NotificationBannerSwift'
pod 'PKHUD', '~> 4.0'
pod 'RxReachability'
pod 'SwiftyJSON'
pod 'SearchTextField'


end



project 'WeatherApp.xcodeproj'


# Pods only used by WeatherApp project

target :'WeatherApp' do
  weatherapp_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end


