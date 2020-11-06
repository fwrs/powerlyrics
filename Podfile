# Project uses a global platform
ios_version = '13.0'
platform :ios, ios_version

target 'powerlyrics' do
  # Use dynamic frameworks
  use_frameworks!
  
  # Suppress warnings
  inhibit_all_warnings!

  # Pods for powerlyrics:
  
  # Project management
  pod 'SwiftLint'
  pod 'SwiftGen'

  # Syntax sugar
  pod 'Then'

  # Haptic feedback
  pod 'Haptica'
  
  # Pan modals
  pod 'PanModal'

  # Data binding
  pod 'ReactiveKit'
  pod 'Bond'
  
  # Labels with links and formatting
  pod 'ActiveLabel'
  
  # Quotation marks formatter
  pod 'Typographizer', :git => 'https://github.com/frankrausch/Typographizer.git'

  # Realm data storage
  pod 'RealmSwift'
  
  # Dependency injection
  pod 'Swinject'

  # Keyboard manager
  pod 'IQKeyboardManager'
  
  # Networking
  pod 'Moya/ReactiveSwift'
  pod 'Alamofire'
  pod 'Kingfisher'
  
  # HTML scraping
  pod 'SwiftSoup'
  
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
