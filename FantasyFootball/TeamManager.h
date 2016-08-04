//
//  TeamManager.h
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Team;

@interface TeamManager : NSObject

@property (nonatomic) int weekNumber;
@property (nonatomic) int monthNumber;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSMutableArray *league;
@property (nonatomic, strong) NSMutableArray *goldenBoot;
@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSMutableArray *motm;

+ (TeamManager *) getInstance;
- (NSMutableArray *) loadData:(NSDictionary *) data cache:(BOOL) cache;
- (Team *) getTeam:(NSString *) managerName;
- (void) updatePosition:(NSString *) managerName;
- (void) sortLeague;
- (void) sortGoals;
- (BOOL) isLastWeekOfMonth;
- (Team *) whoIsWinningBetOfType:(NSDictionary *) sideBet betweenTeam1:(Team *) team1 team2:(Team *) team2 team3:(Team *) team3;
- (Team *) whoIsLosingBetOfType:(NSDictionary *) sideBet betweenTeam1:(Team *) team1 team2:(Team *) team2 team3:(Team *) team3;
+ (NSArray *) managerNames;

@end
