#import "FlutterRtmpStreamerPlugin.h"
#if __has_include(<flutter_rtmp_streamer/flutter_rtmp_streamer-Swift.h>)
#import <flutter_rtmp_streamer/flutter_rtmp_streamer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_rtmp_streamer-Swift.h"
#endif

@implementation FlutterRtmpStreamerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterRtmpStreamerPlugin registerWithRegistrar:registrar];
}

//- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar{
//    NSLog(@"detachFromEngineForRegistrar");
//}
@end
