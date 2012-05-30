//
//
//  Created by Ori Kadosh on 4/30/12.
//
//	This dylib contains two components:
//	1) an activator listener (like every activator listener, it *MUST* be loaded in SpringBoard) that opens the calendar app, and sets the wasCalendarAppLaunchedWithActivator to YES
//	2) hooks in the calendar app. After the calendar app is launched it sends a notification which a listener in SpringBoard listens to, that listener checks if the boolean is YES (that means our activator action launched the calendar app), if it is YES, it sends notification, a listener in the calendar app receives this notification and opens the add event menu. 


#import <libactivator/libactivator.h>
#import <notify.h>
#import <substrate.h>
#import <SpringBoard/SpringBoard.h>

#define AddEventNotification "com.orikad.calendaractivator.addEvent"
#define CalendarApplicationLaunched "com.orikad.calendaractivator.appLaunched"

static BOOL wasCalendarAppLaunchedWithActivator = NO;

static void addEventAction (CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
{
	id viewController = MSHookIvar<id>([UIApplication sharedApplication], "_calendarViewController");
	[viewController addEvent:nil];
}

static void notifyAppLaunched (CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
{
	if (wasCalendarAppLaunchedWithActivator) notify_post(AddEventNotification);
	wasCalendarAppLaunchedWithActivator = NO;
}

%group calendarHooks
%hook CalendarViewController
-(void)applicationDidBecomeActive{ %orig; notify_post(CalendarApplicationLaunched); }
%end
%end

%ctor
{
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.mobilecal"])
	{
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, addEventAction, CFSTR(AddEventNotification), NULL, CFNotificationSuspensionBehaviorCoalesce); //add an observer in the calendar app that'll call addEvent: on _calendarViewController
		%init(calendarHooks); //initiate calendar hooks only if we're loaded into the calendar app
	}
	else if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notifyAppLaunched, CFSTR(CalendarApplicationLaunched), NULL, CFNotificationSuspensionBehaviorCoalesce); //add an observer in SpringBoard that'll wait for the calendar app to fully launch and then if it was launched by our activator action, (tested with the wasCalendarAppLaunchedWithActivator boolean) send an AddEventNotification for the observer in the calendar app to open the add event menu.
}

@interface ACAddEventActivator : NSObject<LAListener> {}	
@end
@implementation ACAddEventActivator
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	wasCalendarAppLaunchedWithActivator = YES;
	[(SBUIController *) [objc_getClass("SBUIController") sharedInstance] activateApplicationFromSwitcher:[(SBApplicationController *) [objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:@"com.apple.mobilecal"]];
}
+ (void)load
{
    if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {return;}
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.orikad.calendaractivator"];
}
@end