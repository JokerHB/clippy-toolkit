#import <UIKit/UIKit.h>
#import <UIKit/UIKit-Private.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <OCHook/OCHook.h>
#import <GraphicsServices/GraphicsServices.h>
#import "../HapticPro/HapticPro.h"

#include <substrate.h>
#include <notify.h>
#include <objc/runtime.h>

#define kSettingsChangeNotification "com.booleanmagic.rotationinhibitor.settingschange"
#define kSettingsFilePath "/User/Library/Preferences/com.booleanmagic.rotationinhibitor.plist"

static BOOL rotationEnabled;
static UIDeviceOrientation desiredOrientation;

#pragma mark Preferences

static void ReloadPreferences()
{
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@kSettingsFilePath];
	if (dict == nil) {
		rotationEnabled = NO;
		desiredOrientation = UIDeviceOrientationPortrait;
	} else {
		id setting = [dict objectForKey:@"RotationEnabled"];
		if (setting)
			rotationEnabled = [setting boolValue];
		else
			rotationEnabled = NO;
		setting = [dict objectForKey:@"DesiredOrientation"];
		if (setting)
			desiredOrientation = (UIDeviceOrientation)[setting integerValue];
		else
			desiredOrientation = UIDeviceOrientationPortrait;
	}
	[dict release];
	if (!rotationEnabled) {
		/*GSEvent event;
		memset(&event, 0, sizeof(event));
		[[UIApplication sharedApplication] deviceOrientationChanged:&event];*/
		[[UIDevice currentDevice] setOrientation:desiredOrientation];
	}
	OCDebugLogSource(@"rotationEnabled=%s", (rotationEnabled)?"YES":"NO");
}

static void PreferencesCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	ReloadPreferences();
}

#pragma mark SBSettings Toggle

BOOL isCapable()
{
	return YES;
}

BOOL isEnabled()
{
	return rotationEnabled;
}

BOOL getStateFast()
{
	return rotationEnabled;
}

float getDelayTime()
{
	return 0.0f;
}

void setState(BOOL enable)
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@kSettingsFilePath];
	if (dict == nil)
		dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithBool:enable] forKey:@"RotationEnabled"];
	[dict writeToFile:@kSettingsFilePath atomically:YES];
	[dict release];
	notify_post(kSettingsChangeNotification);
}

void invokeHoldAction()
{
	HPPerformHapticFeedback(HPHapticFeedbackTypeRepeated);
	desiredOrientation--;
	if (desiredOrientation == UIDeviceOrientationUnknown)
		desiredOrientation = UIDeviceOrientationLandscapeRight;
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@kSettingsFilePath];
	if (dict == nil)
		dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithInteger:desiredOrientation] forKey:@"DesiredOrientation"];
	[dict writeToFile:@kSettingsFilePath atomically:YES];
	[dict release];
	notify_post(kSettingsChangeNotification);
}

#define OverrideOrientation(superValue) \
	(rotationEnabled)?superValue:desiredOrientation

#pragma mark GraphicsServices

MSHook(UIDeviceOrientation, GSEventDeviceOrientation, GSEvent *event)
{
	return OverrideOrientation(_GSEventDeviceOrientation(event));
}

#pragma mark UIDevice

OCReplacement(UIDeviceOrientation, UIDevice, orientation)

#pragma mark UIHardware
	return OverrideOrientation(OCSuper(UIHardware, deviceOrientation, something));

#pragma mark Initialization

void ToggleInit()
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	ReloadPreferences();
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(), //center
		NULL, // observer
		PreferencesCallback, // callback
		(CFStringRef)@kSettingsChangeNotification, // name
		NULL, // object
		CFNotificationSuspensionBehaviorHold
	);

	// GraphicsServices
	MSHookFunction(&GSEventDeviceOrientation, &$GSEventDeviceOrientation, (void **)&_GSEventDeviceOrientation);

	// UIDevice
	
	
	[pool release];
}
