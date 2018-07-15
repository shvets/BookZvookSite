Pod::Spec.new do |s|
  s.name         = "BookZvookSite"
  s.version      = "1.0.0"
  s.summary      = "Framework for playing media from BookZvuk.Ru"
  s.description  = "Framework for playing media from BookZvuk.Ru."

  s.homepage     = "https://github.com/shvets/BookZvookSite"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }

  s.ios.deployment_target = "10.0"
  #s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "10.0"
  #s.watchos.deployment_target = "2.0"

  s.source = { :git => "https://github.com/shvets/BookZvookSite.git", :tag => s.version }
  s.source_files = "Sources/**/*.swift"

  s.resource_bundles = {
    'com.rubikon.BookZvookSite' => ['Sources/**/*.{storyboard,strings,lproj}', ]
  }

  s.dependency 'WebAPI', '~> 1.0.3'
  s.dependency 'Runglish', '~> 1.0.0'
  s.dependency 'AudioPlayer', '~> 1.0.7'
  s.dependency 'TVSetKit', '~> 1.0.13'
end
