#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_sqlcipher.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_sqlcipher'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.frameworks = 'Security'

  # refer to this:
  # https://www.zetetic.net/sqlcipher/ios-tutorial/
  # run `pod install` every time this file is changed
  s.xcconfig = { 'OTHER_CFLAGS' => '-DSQLITE_ENABLE_FTS5 -DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=3 -DSQLCIPHER_CRYPTO_CC -DNDEBUG' }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
