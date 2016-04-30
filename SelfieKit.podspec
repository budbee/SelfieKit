Pod::Spec.new do |s|
  s.name             = "SelfieKit"
  s.version          = "0.1.0"
  s.summary          = "Assisted Camera Picker to take selfies"
  s.homepage         = "https://github.com/budbee/SelfieKit"
  s.license          = 'MIT'
  s.author           = { "Axel Möller" => "axel.moller@budbee.com" }
  s.source           = { :git => "https://github.com/budbee/SelfieKit.git", :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'SelfieKit/Classes/**/*'
  s.resource_bundles = {
     'SelfieKit' => ['SelfieKit/Assets/*.png']
  }
  s.frameworks = 'AVFoundation'
end
