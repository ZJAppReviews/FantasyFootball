//
//  SettingsManager.m
//  DebtManager
//
//  Created by Mark Riley on 23/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsManager.h"
#import "TeamManager.h"

@interface SettingsManager ()

@end

@implementation SettingsManager

static SettingsManager* _instance = nil;

- (void) _applySettings {
    NSArray *teams = [remoteSettings objectForKey:@"teams"];
    [[TeamManager getInstance] loadTeams:teams];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
}

- (void) _loadSettings {
    // check that we are not in the middle of loading the settings already
    if (isLoading)
        return;

    isLoading = YES;
    remoteSettingsData = [[NSMutableData alloc] init];

    NSURL *URL = [NSURL URLWithString:@"http://www.mhriley.com/fantasyfootball/teams.json"];
    //URL = [NSURL URLWithString:@"http://www.mhriley.com/fantasyfootball/teams_test.json"]; int remove_me;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

+ (void) loadSettings {
    return [[SettingsManager getInstance] _loadSettings];
}

#pragma mark delegate methods for asynchronous requests

- (void)connection:(NSURLConnection*) myConnection didReceiveData:(NSData*) myData {
    [remoteSettingsData appendData:myData];
}

- (void)connection:(NSURLConnection*) myConnection didFailWithError:(NSError*) myError {
    isLoading = NO;

	NSLog(@"Connection failed");
}

- (void)connectionDidFinishLoading:(NSURLConnection*) myConnection {
    NSError *error = nil;
    remoteSettings = [NSJSONSerialization JSONObjectWithData:remoteSettingsData options:NSJSONReadingMutableContainers error:&error];
   
    if (!error) {
        //NSLog(@"JSON Settings: %@", remoteSettings);
        [self _applySettings];
    }
    else {
        NSLog(@"JSON Deserialization failed: %@", [error userInfo]);
    }

    isLoading = NO;
}

#pragma mark -
#pragma mark Lifecycle

+ (SettingsManager *) getInstance
{
	@synchronized([SettingsManager class])
	{
		if (!_instance) {
			[[self alloc] init];
		}
		
		return _instance;
	}
	
	return nil;
}

+ (id) alloc
{
	@synchronized([SettingsManager class])
	{
		NSAssert(_instance == nil, @"Attempted to allocate a second instance of SettingsManager.");
		_instance = [super alloc];
		return _instance;
	}
	
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here
	}
	
	return self;
}

@end


