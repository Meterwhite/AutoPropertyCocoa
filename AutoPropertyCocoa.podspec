Pod::Spec.new do |s|
  s.name         = "AutoPropertyCocoa"
  s.version      = "1.0.7"

  s.osx.deployment_target = '10.10'
  s.ios.deployment_target = '7.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
    
  s.summary      = 'Lazy loading.Will and Did access property like swift.All methos is green that can be unbind.'
  s.homepage     = 'https://github.com/qddnovo/AutoPropertyCocoa'
  s.license      = 'MIT'
  s.author       = { "Meterwhite" => "meterwhite@outlook.com" }
  s.requires_arc = true
  s.source       = { :git => "https://github.com/qddnovo/AutoPropertyCocoa.git", :tag => s.version}
  s.source_files  = 'AutoPropertyCocoa/**/*.{h,c,m,mm}'
end