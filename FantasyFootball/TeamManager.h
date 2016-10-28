//
//  TeamManager.h
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Team;

enum LeagueMode {Points, Overall, StartingPoints, StartingGoals, Winnings, Count};

@interface TeamManager : NSObject

@property (nonatomic) int weekNumber;
@property (nonatomic) int completedWeekNumber;
@property (nonatomic) int monthNumber;
@property (nonatomic) int cupRoundNumber;
@property (nonatomic, strong) NSString *year, *chairman;
@property (nonatomic, strong) NSMutableArray *league;
@property (nonatomic, strong) NSMutableArray *goldenBoot;
@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSMutableArray *motm;
@property (nonatomic, strong) NSArray *cupRounds;
@property (nonatomic, strong) NSArray *sideBets;
@property (nonatomic, strong) NSArray *managerStats;

+ (TeamManager *) getInstance;
- (NSMutableArray *) loadData:(NSDictionary *) data cache:(BOOL) cache;
- (NSMutableArray *) loadLeagueData:(NSDictionary *) staticData teamData:(NSArray *) teamRows overallData:(NSArray *) overallRows startingData:(NSArray *) startingRows cache:(BOOL) cache;
- (void) checkForNewData:(NSArray *) teamRows completionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
- (Team *) getTeam:(NSString *) managerName;
- (void) updatePosition:(NSString *) managerName;
- (void) sortLeague;
- (void) sortGoals;
- (BOOL) isLastWeekOfMonth;
- (Team *) whoIsWinningBetOfType:(NSDictionary *) sideBet betweenTeam1:(Team *) team1 team2:(Team *) team2 team3:(Team *) team3;
- (Team *) whoIsLosingBetOfType:(NSDictionary *) sideBet betweenTeam1:(Team *) team1 team2:(Team *) team2 team3:(Team *) team3;
- (double) getPredictedWinnings:(Team *) team;
- (int) getCupRound:(Team *) team;
- (BOOL) hasCupFinished;
+ (NSArray *) managerNames;

@end
