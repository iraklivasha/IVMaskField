Pod::Spec.new do |s|
  s.name             = 'IVMaskField'
  s.version          = '1.2'
  s.summary          = 'UITextField subclass with input mask support'
  s.homepage         = 'https://github.com/iraklivasha/IVMaskField'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iraklivasha' => 'iraklivashaka@gmail.com' }
  s.source           = { :git => 'https://github.com/iraklivasha/IVMaskField.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'IVMaskField/**/*'
  s.frameworks = 'UIKit'
  s.swift_version = '3.2'
end
