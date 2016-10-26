//
//  SettingsManager.m
//  DebtManager
//
//  Created by Mark Riley on 23/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsManager.h"
#import "TeamManager.h"
#import "Util.h"
#import "TFHpple.h"

#define DEBUG_MODE 0

@interface SettingsManager ()

@end

@implementation SettingsManager

static SettingsManager* _instance = nil;

- (void) _applySettings {
    
    NSMutableArray *league = [[TeamManager getInstance] loadData:remoteSettings cache:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [TeamManager getInstance].league = league;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    });
}

- (void) _loadSettings {
    // check that we are not in the middle of loading the settings already
    if (isLoading)
        return;

    isLoading = YES;
    remoteSettingsData = [[NSMutableData alloc] init];

    /*NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/get"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];*/
    
    if (DEBUG_MODE && !optionEnabled(@"testMode")) {
        NSError *error = nil;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"teams_debug" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        remoteSettings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        [self _applySettings];
        
        isLoading = NO;
        
        NSURL *URL = [NSURL URLWithString:@"https://fantasyfootball.telegraph.co.uk/premier-league/json/getgraphdata/8114439"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        [request setHTTPMethod:@"GET"];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *leagueTask = [session dataTaskWithRequest:request
                                                      completionHandler:
            ^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error && data) {
                    NSError *error2 = nil;
                    remoteSettings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
                    
                    if (!error2) {
                        //NSLog(@"JSON Settings: %@", remoteSettings);
                        NSURL *URL = [NSURL URLWithString:@"https://fantasyfootball.telegraph.co.uk/premier-league/json/getleaguetable/8114439/O/1/1"];
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
                        [request setHTTPMethod:@"GET"];
                        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
                        
                        NSURLSession *session = [NSURLSession sharedSession];
                        NSURLSessionDataTask *leagueTask = [session dataTaskWithRequest:request
                                                                      completionHandler:
                            ^(NSData *data, NSURLResponse *response, NSError *error) {
                                if (!error && data) {
                                    NSError *error2 = nil;
                                    remoteSettings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
                                    
                                    if (!error2) {
                                        //NSLog(@"JSON Settings: %@", remoteSettings);
                                        //[self _applySettings];
                                        
                                        NSString *html = remoteSettings[@"HTML"];
                                        
                                        // remove new lines and tabs
                                        html = [[html stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                                        
                                        // remove extraneous white space
                                        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:0 error:&error];
                                        html = [regex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@""];
                                        
                                        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
             
                                        NSString *xPathQuery = @"//tr[@class='\']";
                                        NSArray *teamRows = [htmlParser searchWithXPathQuery:xPathQuery];
                                        for (TFHppleElement *element in teamRows) {
                                            for (TFHppleElement *child in element.children) {
                                                NSString *content = [child content];
                                                NSLog(@"Content %@", [child content]);
                                            }
                                        }
                                    }
                                    else {
                                        NSLog(@"League JSON Deserialization failed: %@", [error2 userInfo]);
                                    }
                                }
                                else {
                                    NSLog(@"League connection failed: %@", [error userInfo]);
                                }
                                
                                isLoading = NO;
                            }];
                        [leagueTask resume];
                    }
                    else {
                        NSLog(@"League JSON Deserialization failed: %@", [error2 userInfo]);
                    }
                }
                else {
                    NSLog(@"League connection failed: %@", [error userInfo]);
                }
                
                isLoading = NO;
            }];
        [leagueTask resume];
    }
    else {
        NSURL *URL = [NSURL URLWithString:@"http://www.mhriley.com/fantasyfootball/teams.json"];
        if (optionEnabled(@"testMode"))
            URL = [NSURL URLWithString:@"http://www.mhriley.com/fantasyfootball/teams_test.json"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        [request setHTTPMethod:@"GET"];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];

        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *leagueTask = [session dataTaskWithRequest:request
                                                completionHandler:
        ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error && data) {
                NSError *error2 = nil;
                remoteSettings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
                
                if (!error2) {
                    //NSLog(@"JSON Settings: %@", remoteSettings);
                    [self _applySettings];
                }
                else {
                    NSLog(@"League JSON Deserialization failed: %@", [error2 userInfo]);
                }
            }
            else {
                NSLog(@"League connection failed: %@", [error userInfo]);
            }
            
            isLoading = NO;
        }];
        [leagueTask resume];
    }
    
    NSURL *URL = [NSURL URLWithString:@"http://www.mhriley.com/fantasyfootball/side_bets.json"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sideBetsTask = [session dataTaskWithRequest:request
                                                  completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            NSError *error2 = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
            
            if (!error2) {
                [TeamManager getInstance].sideBets = dict[@"sideBets"];
                
                NSLog(@"Cache side bets data");
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                     NSUserDomainMask, YES);
                NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cache_side_bets.dat"];
                [[TeamManager getInstance].sideBets writeToFile:cachePath atomically:YES];
            }
            else {
                NSLog(@"Side Bets JSON Deserialization failed: %@", [error2 userInfo]);
            }
        }
        else {
            NSLog(@"Side Bets connection failed: %@", [error userInfo]);
        }
    }];
    [sideBetsTask resume];
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
    static SettingsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

@end


