platform :ios, '11.0'

def shared_pods
  pod 'MBProgressHUD', '~> 1.1.0'
end

target 'sharedeal' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'R.swift', '~> 5.0.3'
  pod 'RxSwift', '~> 5.0.0'
  pod 'RxCocoa', '~> 5.0.0'
  pod 'SwiftLint', '~> 0.35.0'
  pod 'SkyFloatingLabelTextField', '~> 3.7.0'
  pod 'Reveal-SDK', :configurations => ['Debug']
  shared_pods
  
  target 'sharedealTests' do
    inherit! :search_paths
    pod 'RxBlocking', '~> 5.0.0'
    pod 'RxTest', '~> 5.0.0'
  end
end

target 'sharedealUITests' do
  inherit! :search_paths
  use_frameworks!
  pod 'RxBlocking', '~> 5.0.0'
  pod 'RxTest', '~> 5.0.0'
  shared_pods
end

