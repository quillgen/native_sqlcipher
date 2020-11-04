#import "NativeSqlcipherPlugin.h"
#if __has_include(<native_sqlcipher/native_sqlcipher-Swift.h>)
#import <native_sqlcipher/native_sqlcipher-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_sqlcipher-Swift.h"
#endif

@implementation NativeSqlcipherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeSqlcipherPlugin registerWithRegistrar:registrar];
}
@end
