Pod::Spec.new do |spec|
  spec.platform     = :ios
  spec.name         = "DFNDebugScreenShot"
  spec.version      = "0.0.1"
  spec.license      = 'MIT'
  spec.homepage     = "https://github.com/dealforest/DFNDebugScreenShot"
  spec.authors      = { "Toshihiro Morimoto" => "dealforest.net@gmail.com" }
  spec.summary      = ""
  spec.source       = { :git => "https://github.com/dealforest/DFNDebugScreenShot.git" }
  spec.source_files = 'DFNDebugScreenShot/*.{h,m}'
  spec.framework    = 'AssetsLibrary'
  spec.requires_arc = true
end
