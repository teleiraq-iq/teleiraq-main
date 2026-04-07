source 'https://github.com/CocoaPods/Specs.git'
# Uncomment this line to define a global platform for your project
platform :ios, '15.0'
# By default, ignore all warnings from any pod
inhibit_all_warnings!
# Use frameworks to allow usage of pods written in Swift
use_frameworks!
# Method to import the MatrixSDK
def import_MatrixSDK
  pod 'MatrixSDK', :path => 'matrix-ios-sdk/MatrixSDK.podspec', :inhibit_warnings => false
  pod 'MatrixSDK/JingleCallStack', :path => 'matrix-ios-sdk/MatrixSDK.podspec', :inhibit_warnings => false
end
########################################
def import_MatrixKit_pods
  pod 'libPhoneNumber-iOS', '~> 0.9.13'
  pod 'Down', '~> 0.11.0'
end
def import_SwiftUI_pods
    pod 'Introspect', '~> 0.1'
    pod 'ZXingObjC', '~> 3.6.9'
end
abstract_target 'RiotPods' do
  pod 'GBDeviceInfo', '~> 7.1.0'
  pod 'Reusable', '~> 4.1'
  pod 'KeychainAccess', '~> 4.2.2'
  pod 'WeakDictionary', '~> 2.0'
  pod 'Sentry', '~> 8.46.0'
  pod 'zxcvbn-ios'
  # Tools
  pod 'SwiftGen'
  pod 'SwiftLint'
  pod 'SwiftFormat/CLI'
  target "Riot" do
    import_MatrixSDK
    import_MatrixKit_pods
    import_SwiftUI_pods
    pod 'UICollectionViewRightAlignedLayout', '~> 0.0.3'
    pod 'UICollectionViewLeftAlignedLayout', '~> 1.0.2'
    pod 'KTCenterFlowLayout', '~> 1.3.1'
    pod 'FlowCommoniOS', '~> 1.12.0'
    pod 'ReadMoreTextView', '~> 3.0.1'
    pod 'SwiftBase32', '~> 0.9.0'
    pod 'SwiftJWT', '~> 3.6.200'
    pod 'SideMenu', '~> 6.5'
    pod 'DSWaveformImage', '~> 6.1.1'
    pod 'FLEX', '~> 5.22.10', :configurations => ['Debug'], :inhibit_warnings => true
    target 'RiotTests' do
      inherit! :search_paths
    end
  end
  target "RiotSwiftUI" do
    import_SwiftUI_pods
  end
  target "RiotSwiftUITests" do
    import_SwiftUI_pods
  end
  target "RiotNSE" do
    import_MatrixSDK
    import_MatrixKit_pods
  end
  target "BroadcastUploadExtension" do
    import_MatrixSDK
  end
  # Disabled due to crypto corruption issues.
  # https://github.com/element-hq/element-ios/issues/7618
  # target "RiotShareExtension" do
  #   import_MatrixSDK
  #   import_MatrixKit_pods
  # end
  #
  # target "SiriIntents" do
  #   import_MatrixSDK
  #   import_MatrixKit_pods
  # end
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Disable bitcode for each pod framework
      # Because the WebRTC pod (included by the JingleCallStack pod) does not support it.
      # Plus the app does not enable it
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      # Force ReadMoreTextView to use Swift 5.2 version (as there is no code changes to perform)
      if target.name.include? 'ReadMoreTextView'
        config.build_settings['SWIFT_VERSION'] = '5.2'
      end
      # Stop Xcode 12 complaining about old IPHONEOS_DEPLOYMENT_TARGET from pods
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      # Disable nullability checks
      config.build_settings['WARNING_CFLAGS'] ||= ['$(inherited)','-Wno-nullability-completeness']
      config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)', '-Xcc', '-Wno-nullability-completeness']
      # Fix Swift 6 / Xcode 26 compatibility - force Swift 5 mode for all pods
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['SWIFT_SWIFT3_OBJC_INFERENCE'] = 'Default'
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      config.build_settings['SWIFT_STRICT_CONCURRENCY'] = 'minimal'
      # Fix _SwiftConcurrencyShims missing module
      config.build_settings['OTHER_SWIFT_FLAGS'] << ' -Xfrontend -disable-experimental-clang-importer-diagnostics'
      # Fix AFNetworking private header issue with newer Xcode/SDKs
      if target.name == 'AFNetworking'
        config.build_settings['HEADER_SEARCH_PATHS'] ||= ['$(inherited)']
        config.build_settings['HEADER_SEARCH_PATHS'] << '$(SDKROOT)/usr/include/netinet6'
      end
    end
    # Fix Xcode 14 resource bundle signing issues
    # https://github.com/CocoaPods/CocoaPods/issues/11402#issuecomment-1259231655
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
  # Fix AFNetworking private header - patch the source files directly
  afnetworking_files = [
    'Pods/AFNetworking/AFNetworking/AFNetworkReachabilityManager.m',
    'Pods/AFNetworking/AFNetworking/AFHTTPSessionManager.m'
  ]
  afnetworking_files.each do |file|
    if File.exist?(file)
      File.chmod(0644, file)
      content = File.read(file)
      if content.include?('#import <netinet6/in6.h>')
        content = content.gsub('#import <netinet6/in6.h>', '#import <netinet/in.h>')
        File.write(file, content)
        puts "✅ Patched #{File.basename(file)}"
      else
        puts "ℹ️ #{File.basename(file)} already patched"
      end
    end
  end
end
