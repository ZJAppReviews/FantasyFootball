//
//  SettingsManager.m
//  DebtManager
//
//  Created by Mark Riley on 23/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "TeamManager.h"
#import "Util.h"

#import "TFHpple.h"

#define DEBUG_MODE 1

@interface DataManager ()

@end

@implementation DataManager

static DataManager* _instance = nil;

- (void) _applyData {
    
    NSMutableArray *league = [[TeamManager getInstance] loadData:remoteJSONData cache:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [TeamManager getInstance].league = league;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    });
}

- (void) _loadData {
    // check that we are not in the middle of loading the settings already
    if (isLoading)
        return;

    isLoading = YES;

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
        /*NSError *error = nil;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"teams_debug" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        staticData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        [[TeamManager getInstance] loadData:staticData cache:YES];*/
        
        [self loadLeagueDataDebug];
    }
    else {
        [self loadLeagueData];
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

- (void) loadLeagueData {
    NSURL *URL = [NSURL URLWithString:@"http://www.mhriley.com/fantasyfootball/league.json"];
    if (optionEnabled(@"testMode"))
        URL = [NSURL URLWithString:@"http://www.mhriley.com/fantasyfootball/league_test.json"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *leagueTask = [session dataTaskWithRequest:request
                                                  completionHandler:
        ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error && data) {
                NSError *error2 = nil;
                staticData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
                
                if (!error2) {
                    //[self _applyData];
                    [self scrapeTeamsData];
                }
                else {
                    isLoading = NO;
                    NSLog(@"League JSON Deserialization failed: %@", [error2 userInfo]);
                }
            }
            else {
                isLoading = NO;
                NSLog(@"League connection failed: %@", [error userInfo]);
            }
        }];
    [leagueTask resume];
}

- (void) loadLeagueDataDebug {
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"teams_debug" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    staticData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

    [self scrapeTeamsData];
}

- (void) scrapeTeamsData {
    NSURL *URL = [NSURL URLWithString:@"https://fantasyfootball.telegraph.co.uk/premier-league/json/getgraphdata/8114439"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                  completionHandler:
        ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error && data) {
                NSError *error2 = nil;
                NSDictionary *teamsData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
                
                if (!error2) {
                    BOOL success = [[teamsData objectForKey:@"SUCCESS"] boolValue];
                    if (success) {
                        teamRows = [teamsData objectForKey:@"DATA"];
                        [self scrapeOverallData];
                    }
                    else {
                        isLoading = NO;
                        NSLog(@"Teams TFF scrape failed");
                    }
                }
                else {
                    isLoading = NO;
                    NSLog(@"Teams JSON Deserialization failed: %@", [error2 userInfo]);
                }
            }
            else {
                isLoading = NO;
                NSLog(@"Teams connection failed: %@", [error userInfo]);
            }
        }];
    [task resume];
}

- (void) scrapeOverallData {
    NSURL *URL = [NSURL URLWithString:@"https://fantasyfootball.telegraph.co.uk/premier-league/json/getleaguetable/8114439/O/1/1"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                  completionHandler:
        ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error && data) {
                NSError *error2 = nil;
                NSDictionary *overallData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
                
                if (!error2) {
                    BOOL success = [[overallData objectForKey:@"SUCCESS"] boolValue];
                    if (success) {
                        NSString *html = [overallData objectForKey:@"HTML"];
                        
                        // remove new lines and tabs
                        html = [[html stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                        
                        // remove extraneous white space
                        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:0 error:&error];
                        html = [regex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@""];
                        
                        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
                        NSString *xPathQuery = @"//tr[@class='\']";
                        overallRows = [htmlParser searchWithXPathQuery:xPathQuery];
                        
                        [self scrapeStartingData];
                    }
                    else {
                        isLoading = NO;
                        NSLog(@"Overall TFF scrape failed");
                    }
                }
                else {
                    isLoading = NO;
                    NSLog(@"Overall JSON Deserialization failed: %@", [error2 userInfo]);
                }
            }
            else {
                isLoading = NO;
                NSLog(@"Overall connection failed: %@", [error userInfo]);
            }
        }];
    [task resume];
}

- (void) scrapeStartingData {
    NSURL *URL = [NSURL URLWithString:@"https://fantasyfootball.telegraph.co.uk/premier-league/json/getleaguetable/8114439/S/1/1"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                  completionHandler:
        ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error && data) {
                NSError *error2 = nil;
                NSDictionary *startingData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
                
                if (!error2) {
                    BOOL success = [[startingData objectForKey:@"SUCCESS"] boolValue];
                    
                    if (success) {
                        NSString *html = [startingData objectForKey:@"HTML"];
                        
                        // remove new lines and tabs
                        html = [[html stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                        
                        // remove extraneous white space
                        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:0 error:&error];
                        html = [regex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@""];
                        
                        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
                        NSString *xPathQuery = @"//tr[@class='\']";
                        NSArray *startingRows = [htmlParser searchWithXPathQuery:xPathQuery];

                        NSMutableArray *league = [[TeamManager getInstance] loadLeagueData:staticData teamData:teamRows overallData:overallRows startingData:startingRows cache:YES];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [TeamManager getInstance].league = league;
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
                        });
                    }
                    else {
                        NSLog(@"Starting TFF scrape failed");
                    }
                }
                else {
                    NSLog(@"Starting JSON Deserialization failed: %@", [error2 userInfo]);
                }
            }
            else {
                NSLog(@"Starting connection failed: %@", [error userInfo]);
            }
            
            isLoading = NO;
        }];
    [task resume];
}

+ (void) loadData {
    return [[DataManager getInstance] _loadData];
}

#pragma mark -
#pragma mark Lifecycle

+ (DataManager *) getInstance
{
    static DataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

@end


