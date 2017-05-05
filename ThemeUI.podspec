Pod::Spec.new do |s|
  s.name             = 'ThemeUI'
  s.version          = '0.2.0'
  s.license          = 'MIT'
  s.summary          = 'A json based UI style setting for iOS.'
  s.homepage         = 'https://github.com/enzoliu/ThemeUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Enzo Liu' => 'item.search@gmail.com' }
  s.source           = { :git => 'https://github.com/enzoliu/ThemeUI.git', :tag => '0.2.0' }

  s.ios.deployment_target = '8.0'

  s.source_files = 'src/*.{swift,m,h}'
  
  s.requires_arc = true  
end
