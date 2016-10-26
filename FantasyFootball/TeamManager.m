//
//  TeamManager.m
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "TeamManager.h"
#import "Team.h"
#import "TeamWeek.h"
#import "Month.h"
#import "CupRound.h"
#import "Util.h"

@implementation TeamManager

+ (TeamManager *) getInstance {
    static TeamManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id) init {
    if (self = [super init]) {
        _league = [NSMutableArray new];
    }
    return self;
}

- (NSMutableArray *) loadData:(NSDictionary *) data cache:(BOOL) cache {
    NSLog(@"Load data");
    
    int oldWeek = [getOptionValueForKey(@"week") intValue];
    _weekNumber = [[data objectForKey:@"week"] intValue];
    _year = [data objectForKey:@"year"];
    
    NSArray *teamsJSON = [data objectForKey:@"teams"];
    NSArray *monthsJSON = [data objectForKey:@"months"];
    NSArray *cupJSON = [data objectForKey:@"cup"];
    NSMutableArray *teams = [NSMutableArray new];
    NSMutableArray *months = [NSMutableArray new];
    NSMutableArray *cupRounds = [NSMutableArray new];

    // create the month objects
    for (NSDictionary *monthJSON in monthsJSON) {
        Month *month = [Month new];
        month.monthNumber = [[monthJSON objectForKey:@"monthNumber"] intValue];
        month.monthName = [monthJSON objectForKey:@"monthName"];
        month.dateRange = [monthJSON objectForKey:@"dateRange"];
        month.weeks = [[monthJSON objectForKey:@"weeks"] intValue];
        month.managers = [NSMutableArray new];
        [months addObject:month];
    }
    
    // months sorted by reverse date
    _months = [NSMutableArray arrayWithArray:[months sortedArrayUsingComparator:^(id obj1, id obj2) {
        return -1 * [[NSNumber numberWithLong:((Month *) obj1).monthNumber] compare:[NSNumber numberWithLong:((Month *)obj2).monthNumber]];
    }]];
    
    // work out which month we are in
    _monthNumber = [self getMonthForWeek:_weekNumber];
    
    // create the team objects
    for (NSDictionary *teamJSON in teamsJSON) {
        Team *team = [Team new];
        team.teamName = [teamJSON objectForKey:@"teamName"];
        team.managerName = [teamJSON objectForKey:@"managerName"];
        //team.points = [[teamJSON objectForKey:@"points"] intValue];
        team.goals = [[teamJSON objectForKey:@"goals"] intValue];
        team.overallPosition = [[teamJSON objectForKey:@"overallPosition"] intValue];
        team.startingPoints = [[teamJSON objectForKey:@"startingPoints"] intValue];
        team.startingPosition = [[teamJSON objectForKey:@"startingPosition"] intValue];
        team.chairman = [[teamJSON objectForKey:@"chairman"] boolValue];
        if ([[teamJSON objectForKey:@"momentum"] isEqualToString:@"up"])
            team.momentum = Up;
        else if ([[teamJSON objectForKey:@"momentum"] isEqualToString:@"down"])
            team.momentum = Down;
        else
            team.momentum = Same;
        team.weeks = [NSMutableArray new];
        team.motms = [NSMutableArray new];
        [teams addObject:team];
        
        // the points scored are in a dictionary, one entry per week
        // use this to work out the total points and the motm data
        NSDictionary *weeks = [teamJSON objectForKey:@"weeks"];
        
        // sort by week number
        NSArray *keys = [weeks.allKeys sortedArrayUsingComparator:^(id obj1, id obj2) {
            return [@([obj1 intValue]) compare:@([obj2 intValue])];
        }];
        for (NSNumber *weekNumber in keys) {
            int weekPoints = [weeks[weekNumber] intValue];
            team.totalPoints += weekPoints;
            if ([weekNumber intValue] == _weekNumber)
                team.weeklyPoints += weekPoints;
            
            // create the week info for the team
            TeamWeek *teamWeek = [TeamWeek new];
            teamWeek.team = team;
            teamWeek.weekNumber = [weekNumber intValue];
            teamWeek.points = weekPoints;
            teamWeek.totalPoints = team.totalPoints;
            [team.weeks addObject:teamWeek];
            
            // get the month info
            int monthNumber = [self getMonthForWeek:[weekNumber intValue]];
            NSUInteger index = [_months indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                BOOL found = (((Month *) item).monthNumber == monthNumber);
                return found;
            }];
            
            // set the motm data
            if (index != NSNotFound) {
                Month *month = _months[index];
                
                NSMutableDictionary *manager;
                NSUInteger index2 = [month.managers indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                    BOOL found = [((NSDictionary *) item)[@"managerName"] isEqualToString:team.managerName];
                    return found;
                }];
                if (index2 != NSNotFound)
                    manager = month.managers[index2];
                else {
                    manager = [NSMutableDictionary new];
                    manager[@"managerName"] = team.managerName;
                    [month.managers addObject:manager];
                }
                manager[@"points"] = [NSNumber numberWithInt:[manager[@"points"] intValue] + weekPoints];
            }
        }
    }
    
    // work out the team position for each week and make a note of any motm wins
    for (int i = 0; i < _weekNumber; i++) {
        NSArray *teamWeeks = [NSMutableArray new];
        for (Team *team in teams) {
            if (team.weeks.count > i) {
                TeamWeek *teamWeek = team.weeks[i];
                [(NSMutableArray *)teamWeeks addObject:teamWeek];
            }
        }
    
        teamWeeks = [teamWeeks sortedArrayUsingComparator:^(id obj1, id obj2) {
            return -1 * [[NSNumber numberWithLong:((Team *) obj1).totalPoints] compare:[NSNumber numberWithLong:((Team *)obj2).totalPoints]];
        }];

        long previousPoints = 0, previousPosition = 0;
        for (int j = 0; j < teamWeeks.count; j++) {
            TeamWeek *teamWeek = [teamWeeks objectAtIndex:j];
            teamWeek.position = (teamWeek.totalPoints == previousPoints) ? previousPosition : j + 1;
            
            if (teamWeek.position == 1) {
                if ([self isLastWeekOfMonth:i + 1]) {
                    [teamWeek.team.motms addObject:[NSNumber numberWithLong:[self getMonthForWeek:i + 1]]];
                
                    if (_weekNumber == (i + 1) && (_weekNumber > oldWeek) && [getOptionValueForKey(@"managerName") isEqualToString:teamWeek.team.managerName])
                        setOptionBoolForKey(@"motmWin", YES);
                }
            }
            
            previousPoints = teamWeek.totalPoints;
            previousPosition = teamWeek.position;
        }
    }
    
    // sort the motm by points
    for (Month *month in _months) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO];
        month.managers = [NSMutableArray arrayWithArray:[month.managers sortedArrayUsingDescriptors:@[descriptor]]];
    }
 
    // league sorted by points, then by overall position
    NSMutableArray *league = [self sortLeague:teams];
    
    // get the position of current user
    long userPosition = 0;
    Team *currentTeam = [self getTeam:league forManagerName:getOptionValueForKey(@"managerName")];
    if (currentTeam)
        userPosition = currentTeam.leaguePosition;

    // set flags for a new week and/or new/current position
    if (_weekNumber != oldWeek) {
        // reset to showing points
        //setOptionBoolForKey(@"leagueMode", [NSNumber numberWithInt:0]);
        
        setOptionBoolForKey(@"newWeek", YES);
        if (userPosition > 0)
            setOptionValueForKey(@"newPosition", [NSNumber numberWithLong:userPosition]);
    }
    else if (cache && userPosition > 0) {
        setOptionValueForKey(@"position", [NSNumber numberWithLong:userPosition]);
    }
    else if (_weekNumber == 0) {
        setOptionValueForKey(@"position", @0);
    }
    setOptionValueForKey(@"week", [NSNumber numberWithInt:_weekNumber]);
    
    // golden boot sorted by goals
    [self sortGoals:teams];
    
    // cup data is an array of rounds which each contain the ties (assume 4 rounds)
    _cupRoundNumber = 0;
    for (NSDictionary *roundDict in cupJSON) {
        CupRound *round = [CupRound new];
        round.roundNumber = [roundDict[@"round"] intValue];
        round.weekNumber = [roundDict[@"weekNumber"] intValue];
        round.dateRange = roundDict[@"dateRange"];
        //for (NSDictionary *tie in roundDict[@"ties"]) {
        //    [round addTie:tie];
        //}
        round.ties = roundDict[@"ties"];
        
        if (round.ties.count > 0 && round.roundNumber > _cupRoundNumber)
            _cupRoundNumber = round.roundNumber;
        
        [cupRounds addObject:round];
    }
    _cupRounds = cupRounds;
    
    // sort cup ties in reverse round order
    _cupRounds = [_cupRounds sortedArrayUsingComparator:^(id obj1, id obj2) {
        return -1 * [[NSNumber numberWithLong:((CupRound *) obj1).roundNumber] compare:[NSNumber numberWithLong:((CupRound *)obj2).roundNumber]];
    }];
    
    // save the cache to disk for pre-population next time app is opened
    BOOL success = NO;
    if (cache) {
        NSLog(@"Cache league data");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cache.dat"];
        success = [data writeToFile:cachePath atomically:YES];
    }
    else {
        _league = league;
    }
    
    return league;
}

- (void) sortLeague {
    _league = [self sortLeague:_league];
}

- (NSMutableArray *) sortLeague:(NSArray *) league  {
    NSMutableArray *sortedLeague = [NSMutableArray arrayWithArray:[league sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSComparisonResult comparison = [[NSNumber numberWithLong:((Team *) obj1).totalPoints] compare:[NSNumber numberWithLong:((Team *)obj2).totalPoints]];
        
        if (comparison == NSOrderedSame)
            return 1 * [[NSNumber numberWithLong:((Team *) obj1).overallPosition] compare:[NSNumber numberWithLong:((Team *)obj2).overallPosition]];

        return -1 * comparison;
    }]];
    
    long previousPoints = 0, previousPosition = 0;
    for (int i = 0; i < sortedLeague.count; i++) {
        Team *team = [sortedLeague objectAtIndex:i];
        team.leaguePosition = (team.totalPoints == previousPoints) ? previousPosition : i + 1;
        
        previousPoints = team.totalPoints;
        previousPosition = team.leaguePosition;
    }
    
    return sortedLeague;
}

- (void) sortGoals {
    [self sortGoals:_goldenBoot];
}

- (void) sortGoals:(NSArray *) teams {
    _goldenBoot = [NSMutableArray arrayWithArray:[teams sortedArrayUsingComparator:^(id obj1, id obj2) {
        return -1 * [[NSNumber numberWithLong:((Team *) obj1).goals] compare:[NSNumber numberWithLong:((Team *)obj2).goals]];
    }]];
    
    long previousGoals = 0;
    long previousPosition = 0;
    for (int i = 0; i < _goldenBoot.count; i++) {
        Team *team = [_goldenBoot objectAtIndex:i];
        team.goldenBootPosition = (team.goals == previousGoals) ? previousPosition : i + 1;
        
        previousGoals = team.goals;
        previousPosition = team.goldenBootPosition;
    }
}

// months are listed in reverse order
- (int) getMonthForWeek:(long) weekNumber  {
    int weeksSoFar = 0;
    for (long i = (_months.count - 1); i >= 0; i--) {
        Month *month = _months[i];
        weeksSoFar += month.weeks;
        if (weekNumber <= weeksSoFar)
            return month.monthNumber;
    }
    return 0;
}

- (BOOL) isLastWeekOfMonth {
    return [self isLastWeekOfMonth:_weekNumber];
}

- (BOOL) isLastWeekOfMonth:(long) weekNumber {
    int weeksSoFar = 0;
    for (long i = (_months.count - 1); i >= 0; i--) {
        Month *month = _months[i];
        weeksSoFar += month.weeks;
        if (weekNumber == weeksSoFar)
            return YES;
    }
    return NO;
}

- (Team *) getTeam:(NSString *) managerName {
    return [self getTeam:_league forManagerName:managerName];
}

- (Team *) getTeam:(NSArray *) league forManagerName:(NSString *) managerName {
    if (!managerName)
        return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"managerName == %@", managerName];
    NSArray *results = [league filteredArrayUsingPredicate:predicate];
    return results.count > 0 ? [results objectAtIndex:0] : nil;
}

- (void) updatePosition:(NSString *) managerName {
    Team *team = [self getTeam:managerName];
    if (team) {
        setOptionValueForKey(@"position", @0);
        setOptionValueForKey(@"newPosition", [NSNumber numberWithLong:team.leaguePosition]);
    }
}

- (int) getCupRound:(Team *) team {
    int cupRoundNumber = 1;
    
    for (CupRound *cupRound in _cupRounds) {
        if (_weekNumber < cupRound.weekNumber)
            continue;
        
        for (NSDictionary *tie in cupRound.ties) {
            NSString *managerName1 = tie[@"managerName1"];
            NSString *managerName2 = tie[@"managerName2"];
            
            if (![team.managerName isEqualToString:managerName1] && ![team.managerName isEqualToString:managerName2])
                continue;
            
            Team *team1 = [[TeamManager getInstance] getTeam:managerName1];
            Team *team2 = [[TeamManager getInstance] getTeam:managerName2];
            NSString *winner = nil;
            
            long team1Points = ((TeamWeek *) team1.weeks[cupRound.weekNumber - 1]).points;
            long team2Points = ((TeamWeek *) team2.weeks[cupRound.weekNumber - 1]).points;
            
            if (team1Points > team2Points) {
                winner = managerName1;
            }
            else if (team2Points > team1Points) {
                winner = managerName2;
            }
            else {
                // must have been a draw, so check manual flag
                winner = tie[@"winner"];
            }
            
            if ([winner isEqualToString:team.managerName])
                cupRoundNumber = cupRound.roundNumber + 1;
            else
                cupRoundNumber = cupRound.roundNumber;
            
            break;
        }
        
        if (cupRoundNumber > 1)
            break;
    }
    
    return cupRoundNumber;
}

- (Team *) whoIsWinningBetOfType:(NSDictionary *) sideBet betweenTeam1:(Team *) team1 team2:(Team *) team2 team3:(Team *) team3 {
    NSString *type = sideBet[@"type"];
    if (team1 && team2) {
        if ([type isEqualToString:@"league"]) {
            if (team1.leaguePosition < team2.leaguePosition && (!team3 || team1.leaguePosition < team3.leaguePosition))
                return team1;
            else if (team2.leaguePosition < team1.leaguePosition && (!team3 || team2.leaguePosition < team3.leaguePosition))
                return team2;
            else if (team3.leaguePosition < team1.leaguePosition && team3.leaguePosition < team2.leaguePosition)
                return team3;
        }
        else if ([type isEqualToString:@"goals"]) {
            if (team1.goldenBootPosition < team2.goldenBootPosition)
                return team1;
            else if (team1.goldenBootPosition > team2.goldenBootPosition)
                return team2;
        }
        else if ([type isEqualToString:@"other"]) {
            NSString *winningTeam = sideBet[@"winning"];
            if (winningTeam)
                return [self getTeam:sideBet[winningTeam]];
        }
        else if ([sideBet[@"type"] isEqualToString:@"cup"]) {
            int team1Round = [self getCupRound:team1];
            int team2Round = [self getCupRound:team2];
            
            if (team1Round < team2Round)
                return team2;
            else if (team1Round > team2Round)
                return team1;
        }
    }
    
    return nil;
}

- (Team *) whoIsLosingBetOfType:(NSDictionary *) sideBet betweenTeam1:(Team *) team1 team2:(Team *) team2 team3:(Team *) team3 {
    NSString *type = sideBet[@"type"];
    if (team1 && team2) {
        if ([type isEqualToString:@"league"]) {
            if (team1.leaguePosition > team2.leaguePosition && (!team3 || team1.leaguePosition > team3.leaguePosition))
                return team1;
            else if (team2.leaguePosition > team1.leaguePosition && (!team3 || team2.leaguePosition > team3.leaguePosition))
                return team2;
            else if (team3.leaguePosition > team1.leaguePosition && team3.leaguePosition > team2.leaguePosition)
                return team3;
        }
        else if ([type isEqualToString:@"goals"]) {
            if (team1.goldenBootPosition > team2.goldenBootPosition)
                return team1;
            else if (team1.goldenBootPosition < team2.goldenBootPosition)
                return team2;
        }
        else if ([type isEqualToString:@"other"]) {
            NSString *winningTeam = sideBet[@"winning"];
            if (winningTeam) {
                if ([winningTeam isEqualToString:@"managerName1"])
                    return [self getTeam:sideBet[@"managerName2"]];
                else
                    return [self getTeam:sideBet[@"managerName1"]];
            }
        }
        else if ([sideBet[@"type"] isEqualToString:@"cup"]) {
            int team1Round = [self getCupRound:team1];
            int team2Round = [self getCupRound:team2];
            
            if (team1Round > team2Round)
                return team2;
            else if (team1Round < team2Round)
                return team1;
        }
    }
    
    return nil;
}

- (double) getPredictedWinnings:(Team *) team {
    double winnings = 0;
    
    // league winnings
    switch (team.leaguePosition) {
        case 1: winnings += 120; break;
        case 2: winnings += 60; break;
        case 3: winnings += 30; break;
        case 4: winnings += 15; break;
        case 5: winnings += 10; break;
        case 6: winnings += 9; break;
        case 7: winnings += 8; break;
        case 8: winnings += 7; break;
        case 9: winnings += 6; break;
        case 10: winnings += 5; break;
        case 11: winnings += 4; break;
        case 12: winnings += 3; break;
        case 13: winnings += 2; break;
        case 14: winnings += 1; break;
    }
    
    // motm winnings
    winnings += (team.motms.count * 10);
    
    // golden boot winnings
    if (team.goldenBootPosition == 1)
        winnings += 10;
    
    NSArray *sideBets = _sideBets;
    if (!_sideBets) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cache_side_bets.dat"];
        NSArray *cacheData = [NSArray arrayWithContentsOfFile:cachePath];
        if (cacheData)
            sideBets = cacheData;
    }
    
    for (NSDictionary *sideBet in sideBets) {
        NSString *type = sideBet[@"type"];
        NSString *dOrQ = sideBet[@"dorq"];
        Team *team1 = [[TeamManager getInstance] getTeam:sideBet[@"managerName1"]];
        Team *team2 = [[TeamManager getInstance] getTeam:sideBet[@"managerName2"]];
        Team *team3 = [[TeamManager getInstance] getTeam:sideBet[@"managerName3"]];
        
        Team *winningTeam = [[TeamManager getInstance] whoIsWinningBetOfType:sideBet betweenTeam1:team1 team2:team2 team3:team3];
        Team *losingTeam = [[TeamManager getInstance] whoIsLosingBetOfType:sideBet betweenTeam1:team1 team2:team2 team3:team3];
        
        if ([winningTeam.managerName isEqualToString:team.managerName]) {
            double amount = [dOrQ isEqualToString:winningTeam.managerName] ? 0 : [sideBet[@"amount"] doubleValue];
            
            if ([type isEqualToString:@"league"]) {
                winnings += team3 ? 2 * amount : amount;
            }
            else {
                winnings += amount;
            }
        }
        else if ([losingTeam.managerName isEqualToString:team.managerName]) {
            double amount = [dOrQ isEqualToString:winningTeam.managerName] ? 0 : [sideBet[@"amount"] doubleValue];
            
            if ([type isEqualToString:@"league"]) {
                winnings -= (team3 ? 2 * amount : amount);
            }
            else {
                winnings -= amount;
            }
        }
    }
    
    // fu cup is £45 winner / £15 runner up
    int cupRound = [self getCupRound:team];
    if (cupRound == 5)
        winnings += 45;
    else if (cupRound == 4)
        winnings += 15;
    
    return winnings;
}

+ (NSArray *)managerNames
{
    static NSArray *_managerNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _managerNames = @[@"Mr C Attrill",
                          @"Mr P Attrill",
                          @"Mr J Appleby",
                          @"Mr C Cowpertwait",
                          @"Mr S Dowe",
                          @"Mr C Emmerson",
                          @"Mr C Foxall",
                          @"Mr J Free",
                          @"Mr P Gill",
                          @"Mr J Hitchins",
                          @"Mr T Lewis",
                          @"Mr D Lin",
                          @"Mr M Mitchell",
                          @"Mr P Pritchard",
                          @"Mr M Riley"];
    });
    return _managerNames;
}

@end
