Pod::Spec.new do |spec|
  spec.platform     = :ios
  spec.name         = "DFTDebugScreenshot"
  spec.version      = "0.0.1"
  spec.license      = 'MIT'
  spec.homepage     = "https://github.com/dealforest/DFTDebugScreenshot"
  spec.authors      = { "Toshihiro Morimoto" => "dealforest.net@gmail.com" }
  spec.summary      = "Simple debug tool for screenshot."
  spec.source       = { :git => "https://github.com/dealforest/DFTDebugScreenshot.git" }
  spec.source_files = 'DFTDebugScreenshot/*.{h,m}'
  spec.framework    = 'AssetsLibrary'
  spec.requires_arc = true
end
