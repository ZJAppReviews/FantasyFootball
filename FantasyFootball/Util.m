//
//  Util.m
//  MyMortgage
//
//  Created by Mark Riley on 13/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "AppDelegate.h"

BOOL hasProUpgrade() {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#endif
    //return YES; int remove_me_2;
    return optionEnabled(PRO_UPGRADE);
}

BOOL isIPhone() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

BOOL isIPhone5() {
    CGRect bounds = [UIScreen mainScreen].bounds;
    return bounds.size.height == 568;
}

BOOL isIPhone6() {
    CGRect bounds = [UIScreen mainScreen].bounds;
    return bounds.size.height == 667;
}

BOOL isIPhone6Plus() {
    CGRect bounds = [UIScreen mainScreen].bounds;
    return bounds.size.height == 736;
}

BOOL isRetinaHD() {
    return isIPhone6() || isIPhone6Plus();
}

int extraHeight() {
    return isIPad() ? 0 : getPhoneHeight() - 480;
}

int extraWidth() {
    return isIPad() ? 0 : getPhoneWidth() - 320;
}

int getPhoneHeight() {
    return [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.height;
}

int getPhoneWidth() {
    return [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width;
}

int getPickerWidth() {
    return isIPad() ? 320 : getPhoneWidth();
}

BOOL isCanada() {
	return isCountry(@"CA");
}

BOOL isUS() {
	return isCountry(@"US");
}

BOOL isGB() {
	return isCountry(@"GB");
}

BOOL isSpain() {
	return isCountry(@"ES");
}

BOOL isCountry(NSString *c) {
	NSString *country = (NSString *) [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
	return [country isEqualToString:c];
}

BOOL isLanguage(NSString *c) {
	NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
	return [language isEqualToString:c];
}

BOOL isSpanish() {
	return isLanguage(@"es");
}

NSString* getDeviceName() {
    static NSString *deviceName = nil;
    if (!deviceName) {
        deviceName = [[UIDevice currentDevice] name];
        deviceName = [deviceName stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    
    return deviceName;
}

static NSString *UDID = nil;

NSString* getUDID() {
    /*if (!UDID) {
        UDID = [getOptionValueForKey(@"udid") retain];
        if (UDID == nil) {
            UDID = [[BPXLUUIDHandler UUID] retain];
            setOptionValueForKey(@"udid", UDID);
        }
    }*/
    return UDID;
}

void resetUDID() {
    /*if (UDID) {
        [UDID release]; UDID = nil;
        [BPXLUUIDHandler reset];
        removeOptionForKey(@"udid");
    }*/
}

AppDelegate* getAppDelegate() {
	return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

NSManagedObjectContext* getManagedObjectContext() {	
	//return getAppDelegate().managedObjectContext;
    return nil;
}

NSManagedObjectContext* getEditingManagedObjectContext() {	
	//return [getAppDelegate() editingManagedObjectContext];
    return nil;
}

CGRect getRectPlusXOffset(CGRect frame, CGFloat xOffset) {
	return CGRectMake(frame.origin.x + xOffset, frame.origin.y, frame.size.width-xOffset, frame.size.height);
}

// searches the map to find the key with the given value, arbitrarily returns first keys found
NSString* getKeyFromMapUsingValue(NSDictionary *map, NSString *value) {
	IF_IOS_4_OR_GREATER
	(
		NSSet *dbValue = [map keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
							 return [(NSString *)obj isEqualToString:value];
						 }];
						 
		// we shall assume that the values are unique, so one value should be returned
		return [dbValue anyObject];
	)
	
	IF_PRE_IOS_4
	(
		NSArray *keys = [map allKeys];
		for (NSString *key in keys) {
			if ([(NSString *)[map objectForKey:key] isEqualToString:value])
				return key;
		}
		
		return nil;	
	)
	
	return nil;
}

UIKeyboardType getDecimalKeyboardType() {
	IF_IOS_4_1_OR_GREATER
	(
		return isIPad() ? UIKeyboardTypeNumbersAndPunctuation : UIKeyboardTypeDecimalPad;
	)
	
	IF_PRE_IOS_4_1
	(
		return UIKeyboardTypeNumbersAndPunctuation;
	)

	return UIKeyboardTypeNumbersAndPunctuation;
}

UIKeyboardType getCurrencyKeyboardType() {
	return optionEnabled(@"decimal_entry_pref") ? getDecimalKeyboardType() : UIKeyboardTypeNumberPad;
}

BOOL isIPad() {
    IF_IOS_3_2_OR_GREATER
    (
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            return YES;
        }
    );
    
    return NO;
}

BOOL isLandscape() {
	//CGSize size = [[UIScreen mainScreen] applicationFrame].size;
    //return isIPad() ? (size.width == 748 ? YES : NO) : (size.width == 300 ? YES : NO);
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	return UIInterfaceOrientationIsLandscape(orientation);
}

BOOL isPortrait() {
	return !isLandscape();
}

CGRect getMainFrame() {
	UIScreen *screen = [UIScreen mainScreen];
	return [screen bounds];
}

CGFloat getMainWidth() {
    return getMainFrame().size.width;
}

CGFloat getMainWidthPortrait() {
	return isIPad() ? 768 : 320;
}

CGFloat getMainWidthLandscape() {
	return isIPad() ? 1024 : 480;
}

CGFloat getMainHeight() {
    return getMainFrame().size.height;
}

CGFloat getDetailWidth() {
	if (isIPad())
		return getMainFrame().size.height - 320;
	
	return isLandscape() ? getMainFrame().size.height - (isIPad() ? 320 : 0) : getMainFrame().size.width;
}

CGFloat getAddDetailWidth() {
	if (isIPad())
		return (SYSTEM_VERSION_LESS_THAN(@"4.3") ? 775 : 550);
	
	return isLandscape() ? getMainFrame().size.height - (isIPad() ? 320 : 0) : getMainFrame().size.width;
}

CGFloat getGroupCellWidth() {
	return isIPad() ? 615 : 302;
}

CGFloat getGroupCellWidthFull() {
	return isIPad() ? (isLandscape() ? 1001 : 745) : 302+extraWidth();
}

CGFloat getGroupCellDetailWidth() {
	return isIPad() ? 460 : 150+extraWidth();
}

CGFloat getGroupCellDetailWidthFull() {
	return isIPad() ? (isLandscape() ? 780 : 520) : 150+extraWidth();
}

CGFloat getX(CGFloat x) {
	if (isIPad())
		return isLandscape() ? x * ((1024 - 320.0) / 443.0) : x * (768 / 443.0);
	
	return x;
}

CGFloat getXPortrait(CGFloat x) {
	if (isIPad())
		return x * (768 / 443.0);
	
	return x;
}

CGFloat getY(CGFloat y) {
	if (isIPad())
		return isLandscape() ? y * (768 / 320.0) : y * (1004 / 320.0);
	
	return y;
}

id getOptionValueForKey(NSString *key) {
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

BOOL optionEnabled(NSString *optionName) {
	NSNumber *option = getOptionValueForKey(optionName);
	return option == nil ? NO : [option boolValue];
}

void setOptionValueForKey(NSString *key, id value) {
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

void setOptionBoolForKey(NSString *key, BOOL value) {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

void removeOptionForKey(NSString *key) {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

int roundToNearestInt(int value, int nearest) {
	int roundedValue = ((int) ((value + (nearest / 2)) / nearest)) * nearest;
	return roundedValue;
}

float roundToNearestFloat(float value, float nearest) {
	int multiplier = round(1.0 / nearest);
	float roundedValue = round(value * multiplier) / multiplier;
	return roundedValue;
}

int roundToInt(double value, int nearest, BOOL up) {
	int roundedValue = ((int) ((value + (nearest / 2)) / nearest)) * nearest;
	roundedValue = (up && roundedValue < value) ? roundedValue + nearest : (!up && roundedValue > value) ? roundedValue - nearest : roundedValue;
	return roundedValue;
}

void showCoreDataErrorAlert(NSError *error) {
	/*NSLog(@"Save error %@", [error userInfo]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
													message:NSLocalizedString(@"The item has failed to save!\n\nThis could be due to a general problem, please turn your device off and on, then try again.", nil) delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"OK", nil)
										  otherButtonTitles:nil];
	[alert show];*/
}

UIViewController* getModalParentController(UIViewController *vc) {
    if ([vc respondsToSelector:@selector(presentingViewController)])
		return [vc performSelector:@selector(presentingViewController)];

    return vc.parentViewController;
}

void dismissModalViewController(UIViewController *vc, BOOL animated) {
    [[vc performSelector:@selector(presentingViewController)] dismissViewControllerAnimated:animated completion:nil];
}

long getYIntervalForChart(double maxY) {
    NSInteger interval;
    if (maxY > 160000)
        interval = roundToNearestInt(maxY / 8, 20000);
    else if (maxY > 80000)
        interval = roundToNearestInt(maxY / 8, 10000);
    else if (maxY > 40000)
        interval = roundToNearestInt(maxY / 8, 5000);
    else if (maxY > 16000)
        interval = roundToNearestInt(maxY / 8, 2000);
    else if (maxY > 8000)
        interval = roundToNearestInt(maxY / 8, 1000);
    else if (maxY > 4000)
        interval =  roundToNearestInt(maxY / 8, 500);
    else if (maxY > 2000)
        interval = roundToNearestInt(maxY / 8, 250);
    else if (maxY > 800)
        interval = roundToNearestInt(maxY / 8, 100);
    else if (maxY > 400)
        interval = roundToNearestInt(maxY / 8, 50);
	else if (maxY > 200)
        interval = roundToNearestInt(maxY / 8, 25);
	else if (maxY > 160)
        interval = roundToNearestInt(maxY / 8, 20);
	else if (maxY > 80)
        interval = roundToNearestInt(maxY / 8, 10);
	else if (maxY > 40)
        interval = roundToNearestInt(maxY / 8, 5);
	else if (maxY > 16)
        interval = roundToNearestInt(maxY / 8, 2);
    else
        interval = MAX(roundToNearestInt(maxY / 8, 1), 1);
    
    return interval;
}

BOOL arePrimaryHintsShown() {
    return optionEnabled(@"hint_summary")
        && (isIPad() || optionEnabled(@"hint_rotate"))
        && optionEnabled(@"hint_date")
        && optionEnabled(@"hint_help")
        /*&& optionEnabled(@"hint_transactions")
        && optionEnabled(@"hint_edit_category")*/
        ;
}

NSString* getMatchIgnoringWhitespace(NSString *text) {
    NSMutableString *regex = [NSMutableString string];
    [regex appendString:@"\\s*\\b"];
    [regex appendString:text];
    [regex appendString:@"\\b\\s*"];
    return regex;
}

NSString* addOrRemoveTrailingWhitespace(NSString *text) {
    NSString *alteredText;
    if (text.length > 0 && [[text substringFromIndex:text.length - 1] isEqualToString:@" "])
        alteredText = [text substringToIndex:text.length - 1];
    else
        alteredText = [text stringByAppendingString:@" "];
    return alteredText;
}

NSString* stripTrailingWhitespace(NSString *text) {
    NSString *alteredText = text;
    if (text.length > 0 && [[text substringFromIndex:text.length - 1] isEqualToString:@" "])
        alteredText = [text substringToIndex:text.length - 1];
    return alteredText;
}

CGSize getSizeOfText(NSString *text, UIFont *font, CGFloat minFontSize, CGFloat *actualFontSize, CGFloat maxWidth, NSLineBreakMode lineBreakMode) {
    
    //CGSize size = [text sizeWithFont:font minFontSize:minFontSize actualFontSize:actualFontSize forWidth:maxWidth lineBreakMode:lineBreakMode];

    //return size;
    return CGSizeMake(0, 0);
}

void drawTextWithVariableSize (NSString *text, CGPoint point, CGFloat maxWidth, UIFont *font, CGFloat actualFontSize, NSLineBreakMode lineBreakMode) {
    //[text drawAtPoint:point forWidth:maxWidth withFont:font fontSize:actualFontSize lineBreakMode:lineBreakMode baselineAdjustment:UIBaselineAdjustmentAlignCenters];
}
