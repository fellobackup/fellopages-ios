# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

def seiosnativeapp_pods
    pod 'Kingfisher'
    pod 'FBAudienceNetwork', '~>4.28.1'
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'NVActivityIndicatorView'
    #pod 'SwiftyGif'
    pod 'Shimmer'
    #pod 'CropViewController'
    pod 'IGRPhotoTweaks'
    pod 'Google-Mobile-Ads-SDK', '7.31.0'
    pod 'TTTAttributedLabel'
    pod 'GoogleMaps'
    pod 'KYCircularProgress'
    pod 'Crashlytics', '~> 3.10.7'
    pod 'Fabric', '~> 1.7.11'
    pod 'Firebase/Core'
    pod 'Instructions', :git => 'https://github.com/shubham-gupta-bs/Instructions.git', :branch => 'bigstep/v1.0'
end


target 'seiosnativeapp' do
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# Pods for seiosnativeapp
seiosnativeapp_pods

target 'seiosnativeappTests' do
inherit! :search_paths
# Pods for testing
end

end



target 'share' do
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# Pods for share

end

#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        target.build_configurations.each do |config|
#            config.build_settings['SWIFT_VERSION'] = '3.0'
#        end
#    end
#end
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
