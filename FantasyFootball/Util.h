//
//  Util.h
//  MyMortgage
//
//  Created by Mark Riley on 13/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

#define PRO_UPGRADE @"com.mhriley.SpendingTracker.proupgrade"

@class Team;

NSString* getManagerName(Team *team);
BOOL isIPhone();
BOOL isIPhone5();
BOOL isIPhone6();
BOOL isIPhone6Plus();
BOOL isRetinaHD();
int getPhoneHeight();
int getPhoneWidth();
int getPickerWidth();
int extraHeight();
int extraWidth();
BOOL isCanada();
BOOL isUS();
BOOL isGB();
BOOL isSpain();
BOOL isCountry(NSString *c);
BOOL isLanguage(NSString *c);
BOOL isSpanish();
NSString* getDeviceName();
NSString* getUDID();
void resetUDID();

AppDelegate* getAppDelegate();

NSManagedObjectContext* getManagedObjectContext();
NSManagedObjectContext* getEditingManagedObjectContext();

CGRect getRectPlusXOffset(CGRect frame, CGFloat xOffset);

NSString* getKeyFromMapUsingValue(NSDictionary *map, NSString *value);

BOOL isIPad();

UIKeyboardType getDecimalKeyboardType();
UIKeyboardType getCurrencyKeyboardType();

int roundToNearestInt(int value, int nearest);
float roundToNearestFloat(float value, float nearest);
int roundToInt(double value, int nearest, BOOL up);

BOOL isLandscape();
BOOL isPortrait();
CGRect getMainFrame();
CGFloat getMainWidth();
CGFloat getMainWidthPortrait();
CGFloat getMainWidthLandscape();
CGFloat getMainHeight();
CGFloat getDetailWidth();
CGFloat getAddDetailWidth();
CGFloat getGroupCellWidth();
CGFloat getGroupCellWidthFull();
CGFloat getGroupCellDetailWidth();
CGFloat getGroupCellDetailWidthFull();
CGFloat getX(CGFloat x);
CGFloat getXPortrait(CGFloat x);
CGFloat getY(CGFloat y);

id getOptionValueForKey(NSString *key);
BOOL optionEnabled(NSString *optionName);
void setOptionValueForKey(NSString *key, id value);
void setOptionBoolForKey(NSString *key, BOOL value);
void removeOptionForKey(NSString *key);

void showCoreDataErrorAlert(NSError *error);
UIViewController* getModalParentController(UIViewController *vc);
void dismissModalViewController(UIViewController *vc, BOOL animated);

long getYIntervalForChart(double maxY);
BOOL arePrimaryHintsShown();

CGSize getSizeOfText(NSString *text, UIFont *font, CGFloat minFontSize, CGFloat *actualFontSize, CGFloat maxWidth, NSLineBreakMode lineBreakMode);
void drawTextWithVariableSize (NSString *text, CGPoint point, CGFloat maxWidth, UIFont *font, CGFloat actualFontSize, NSLineBreakMode lineBreakMode);

NSString* getMatchIgnoringWhitespace(NSString *name);
NSString* addOrRemoveTrailingWhitespace(NSString *text);
NSString* stripTrailingWhitespace(NSString *text);


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and iPod touch style UI

#define IS_IPHONE_5_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0f)

#define IS_IPHONE_5_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 568.0f)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6P_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) < 568.0f)

#define IS_IPHONE_5 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_5_IOS8 : IS_IPHONE_5_IOS7 )
#define IS_IPHONE_6 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6_IOS8 : IS_IPHONE_6_IOS7 )
#define IS_IPHONE_6P ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6P_IOS8 : IS_IPHONE_6P_IOS7 )
#define IS_IPHONE_4_AND_OLDER ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_4_AND_OLDER_IOS8 : IS_IPHONE_4_AND_OLDER_IOS7 )

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_0 478.23
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_1 478.26
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_2 478.29
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_0 478.47
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_1 478.52
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_2 478.61
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_1 550.38
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_2 550.47
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
#define IF_IOS_3_2_OR_GREATER(...) \
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_3_2) \
    { \
        __VA_ARGS__ \
    }
#else
#define IF_IOS_3_2_OR_GREATER(...)
#endif

#define IF_PRE_IOS_3_2(...) \
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iPhoneOS_3_2) \
    { \
        __VA_ARGS__ \
    }
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
#define IF_IOS_4_OR_GREATER(...) \
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) \
    { \
        __VA_ARGS__ \
    }
#else
#define IF_IOS_4_OR_GREATER(...)
#endif

#define IF_PRE_IOS_4(...) \
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iPhoneOS_4_0) \
    { \
        __VA_ARGS__ \
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40100
#define IF_IOS_4_1_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_1) \
{ \
__VA_ARGS__ \
}
#else
#define IF_IOS_4_1_OR_GREATER(...)
#endif

#define IF_PRE_IOS_4_1(...) \
if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iPhoneOS_4_1) \
{ \
__VA_ARGS__ \
}

