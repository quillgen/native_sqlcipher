#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_sqlcipher.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_sqlcipher'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.osx.pod_target_xcconfig = { 
    'HEADER_SEARCH_PATHS' => [
      '$(PODS_TARGET_SRCROOT)/../src/include'
    ]
  }
  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'native_sqlcipher_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES'
  }
  s.swift_version = '5.0'
  s.compiler_flags = [
    '-DSQLITE_HAS_CODEC',
    '-DSQLITE_TEMP_STORE=3',
    '-DSQLITE_THREADSAFE=1',
    '-DSQLITE_ENABLE_FTS5',
    '-DSQLITE_OMIT_LOAD_EXTENSION',
    '-DSQLITE_OMIT_DEPRECATED',
    '-DSQLITE_EXTRA_INIT=sqlcipher_extra_init',
    '-DSQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown',
    # use CommonCrypto instead of OpenSSL on macOS
    '-DSQLCIPHER_CRYPTO_CC',
    '-DSQLITE_EXTRA_AUTOEXT=sqlite3_fts5_hans_init',
    # disable asserts, otherwise get compiler errors such as: error: implicit declaration of function 'sqlite3FirstAvailableRegister' is invalid in C99 [-Werror,-Wimplicit-function-declaration]
    '-DNDEBUG' 
  ]
end
