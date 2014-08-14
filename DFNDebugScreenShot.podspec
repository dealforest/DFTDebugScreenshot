Pod::Spec.new do |s|
  s.name         = "DFNDebugScreenShot"
  s.version      = "0.0.1"
  s.summary      = ""
  s.homepage     = "https://github.com/dealforest/DFNDebugScreenShot"
  s.license      = 'MIT'
  s.author       = { "Toshihiro Morimoto" => "dealforest.net@gmail.com" }
  s.source       = { :git => "https://github.com/dealforest/DFNDebugScreenShot.git" }
  s.platform     = :ios
  s.requires_arc = true
  s.source_files = 'DFNDebugScreenShot/*.{h,m}'
end
