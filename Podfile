# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TextSight' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  #image cropper
  pod 'Mantis', '~> 2.9.1'
  # Pods for TextSight
  pod 'Firebase/MLVision', '6.25.0'
  # If using an on-device API:
  pod 'Firebase/MLVisionTextModel', '6.25.0'

  
# post install
post_install do |installer|
  # fix xcode 15 DT_TOOLCHAIN_DIR - remove after fix oficially - https://github.com/CocoaPods/CocoaPods/issues/12065
  installer.aggregate_targets.each do |target|
      target.xcconfigs.each do |variant, xcconfig|
      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
      IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
          xcconfig_path = config.base_configuration_reference.real_path
          IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15'
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO' # or 'NO' if you want to disable it


      end

 # Make it work with GoogleDataTransport
      if target.name.start_with? "GoogleDataTransport"
        target.build_configurations.each do |config|
          config.build_settings['CLANG_WARN_STRICT_PROTOTYPES'] = 'NO' 
        end
      end
    end
  end
end
end


