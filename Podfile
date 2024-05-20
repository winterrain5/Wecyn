# Uncomment the next line to define a global platform for your project

inhibit_all_warnings!
target 'Wecyn' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
#Rx
  pod 'RxSwift','5.1.2'
  pod 'RxGesture'
  pod 'RxSwiftExt'
  pod 'RxCocoa'
  pod 'RxMoyaCache'
  pod 'RxKeyboard'
  pod 'Cache', '~> 6.0.0'
  
  
  #other
  pod 'Then'
  pod 'SnapKit'
  pod 'SwiftyJSON'
  pod 'PromiseKit'
  pod 'SwifterSwift'
  pod 'HandyJSON'
  pod 'MJRefresh'
  pod 'R.swift'
  pod 'SwiftDate'
  pod 'Kingfisher'
  pod 'NFCReaderWriter'
  pod 'SafeSFSymbols'
  pod 'GPUImage'
  
  #UI
  pod 'IQKeyboardManagerSwift'
  pod 'DZNEmptyDataSet'
  pod 'EachNavigationBar'
  pod 'JXSegmentedView'
  pod 'SkeletonView'
  pod 'SVProgressHUD'
  pod 'JXPagingView/Paging'
  pod 'KMPlaceholderTextView'
  pod 'MarqueeLabel'
  pod 'CodeTextField', '~> 0.4.0'
  pod 'FSCalendar'
  pod 'SectionIndexView'
  pod "WordPress-Aztec-iOS"
  pod "WordPress-Editor-iOS"
  pod 'ParallaxHeader'
  pod 'TagListView'
  pod 'AnyImageKit'
  pod 'SKPhotoBrowser'
  pod 'SwiftEntryKit'
  pod 'OpenIMSDK'
  pod 'SPIndicator'
  pod 'FYVideoCompressor'
  pod 'TBDropdownMenu'
  pod 'BadgeControl'
  pod 'MessageKit'
  pod 'Localize-Swift', '~> 3.2'
  pod 'ZLPhotoBrowser', '4.3.0'
  pod 'MenuItemKit'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'Google-Maps-iOS-Utils'
  pod 'RichLabel'
  pod 'JZCalendarWeekView'
    
  pod 'Permission/Camera'
  pod 'Permission/Microphone'
  pod 'Permission/Photos'
  pod 'Permission/Notifications'
  
  pod 'LookinServer', :configurations => ['Debug']
  pod 'CocoaDebug', :configurations => ['Debug']
  
  pod 'DKLogger'
  pod 'ImagePickerSwift'
  pod 'EntryKit'
  pod 'DKEmptyDataSet'
  pod 'SwiftExtensionsLibrary', :git => 'https://github.com/winterrain5/SwiftExtensionsLibrary.git'
  

  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'CocoaHTTPServer'
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DD_LEGACY_MACROS=1']
      end
    end
    shell_script_path = "Pods/Target Support Files/#{target.name}/#{target.name}-frameworks.sh"
    if File::exists?(shell_script_path)
      shell_script_input_lines = File.readlines(shell_script_path)
      shell_script_output_lines = shell_script_input_lines.map { |line| line.sub("source=\"$(readlink \"${source}\")\"", "source=\"$(readlink -f \"${source}\")\"") }
      File.open(shell_script_path, 'w') do |f|
        shell_script_output_lines.each do |line|
          f.write line
        end
      end
    end
    target.build_configurations.each do |config|
      config.build_settings["DEVELOPMENT_TEAM"] = "4F6LM54QKY"
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f <= 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end


