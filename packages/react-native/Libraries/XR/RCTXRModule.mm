#import <React/RCTXRModule.h>

#if RCT_NEW_ARCH_ENABLED
#import <FBReactNativeSpec_visionOS/FBReactNativeSpec_visionOS.h>
#endif

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTUtils.h>
#import "RCTXR-Swift.h"

#if RCT_NEW_ARCH_ENABLED
@interface RCTXRModule () <NativeXRModuleSpec>
@end
#endif

@implementation RCTXRModule {
  UIViewController *_immersiveBridgeView;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(endSession
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  [self removeImmersiveBridge];
  resolve(nil);
}


RCT_EXPORT_METHOD(requestSession
                  : (NSString *)sessionId resolve
                  : (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  RCTExecuteOnMainQueue(^{
    UIWindow *keyWindow = RCTKeyWindow();
    UIViewController *rootViewController = keyWindow.rootViewController;
    
    if (self->_immersiveBridgeView == nil) {
      self->_immersiveBridgeView = [ImmersiveBridgeFactory makeImmersiveBridgeViewWithSpaceId:sessionId
                                                                            completionHandler:^(enum ImmersiveSpaceResult result){
        if (result == ImmersiveSpaceResultError) {
          reject(@"ERROR", @"Immersive Space failed to open, the system cannot fulfill the request.", nil);
          [self removeImmersiveBridge];
        } else if (result == ImmersiveSpaceResultUserCancelled) {
          reject(@"ERROR", @"Immersive Space canceled by user", nil);
          [self removeImmersiveBridge];
        } else if (result == ImmersiveSpaceResultOpened) {
          resolve(nil);
        }
      }];
      
      [rootViewController.view addSubview:self->_immersiveBridgeView.view];
      [rootViewController addChildViewController:self->_immersiveBridgeView];
      [self->_immersiveBridgeView didMoveToParentViewController:rootViewController];
    } else {
      reject(@"ERROR", @"Immersive Space already opened", nil);
    }
  });
}

- (void) removeImmersiveBridge
{
  RCTExecuteOnMainQueue(^{
    [self->_immersiveBridgeView willMoveToParentViewController:nil];
    [self->_immersiveBridgeView.view removeFromSuperview];
    [self->_immersiveBridgeView removeFromParentViewController];
    self->_immersiveBridgeView = nil;
  });
}

#pragma mark New Architecture

#if RCT_NEW_ARCH_ENABLED
- (facebook::react::ModuleConstants<JS::NativeXRModule::Constants::Builder>)constantsToExport {
  return [self getConstants];
}

- (facebook::react::ModuleConstants<JS::NativeXRModule::Constants>)getConstants {
  __block facebook::react::ModuleConstants<JS::NativeXRModule::Constants> constants;
  RCTUnsafeExecuteOnMainQueueSync(^{
    constants = facebook::react::typedConstants<JS::NativeXRModule::Constants>({
      .supportsMultipleScenes = RCTSharedApplication().supportsMultipleScenes
    });
  });
  
  return constants;
}
#endif

#if RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeXRModuleSpecJSI>(params);
}
#endif

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

@end

Class RCTXRModuleCls(void)
{
  return RCTXRModule.class;
}
