# Project uses a global platform
ios_version = '13.0'
platform :ios, ios_version

target 'powerlyrics' do
  # Use dynamic frameworks
  use_frameworks!
  
  # Suppress warnings
  inhibit_all_warnings!

  # Pods for powerlyrics
  
  # Project
  pod 'SwiftLint'
  pod 'SwiftGen'

  # Haptic feedback
  pod 'Haptica'

  # Data binding
  pod 'ReactiveKit'
  pod 'Bond'

  # Realm data storage
  pod 'RealmSwift'
  
  # Dependency injection
  pod 'Swinject'

  # Keyboard manager
  pod 'Typist'
  
  # Networking
  pod 'Moya/ReactiveSwift'
  pod 'Alamofire'
  pod 'Kingfisher'
  
  # Token storage
  pod 'KeychainAccess'
  
  # Fix for Realm
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        config.build_settings['EXCLUDED_ARCHS[sdk=watchsimulator*]'] = 'arm64'
        config.build_settings['EXCLUDED_ARCHS[sdk=appletvsimulator*]'] = 'arm64'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = ios_version
      end
    end
  end
end
