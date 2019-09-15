platform :ios, '11.0'


target 'sharedeal' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'R.swift', '~> 5.0.3'
  pod 'RxSwift', '~> 5.0.0'
  pod 'RxCocoa', '~> 5.0.0'
  pod 'SwiftLint', '~> 0.35.0'
  pod 'MBProgressHUD', '~> 1.1.0'
  pod 'SkyFloatingLabelTextField', '~> 3.7.0'
  pod 'Reveal-SDK', :configurations => ['Debug']
  
  target 'sharedealTests' do
    inherit! :search_paths
    pod 'RxBlocking', '~> 5.0.0'
    pod 'RxTest', '~> 5.0.0'
  end

  target 'sharedealUITests' do
    inherit! :search_paths
    pod 'RxBlocking', '~> 5.0.0'
    pod 'RxTest', '~> 5.0.0'
  end

end
