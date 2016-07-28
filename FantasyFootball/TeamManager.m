//
//  TeamManager.m
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "TeamManager.h"
#import "Team.h"
#import "Month.h"
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
    int oldWeek = [getOptionValueForKey(@"week") intValue];
    _weekNumber = [[data objectForKey:@"week"] intValue];
    _year = [data objectForKey:@"year"];
    
    NSArray *teamsJSON = [data objectForKey:@"teams"];
    NSArray *monthsJSON = [data objectForKey:@"months"];
    NSMutableArray *teams = [NSMutableArray new];
    NSMutableArray *months = [NSMutableArray new];

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
    _monthNumber = [self getMonthWithin:_months forWeek:_weekNumber];
    
    // create the team objects
    for (NSDictionary *teamJSON in teamsJSON) {
        Team *team = [Team new];
        team.teamName = [teamJSON objectForKey:@"teamName"];
        team.managerName = [teamJSON objectForKey:@"managerName"];
        //team.points = [[teamJSON objectForKey:@"points"] intValue];
        team.goals = [[teamJSON objectForKey:@"goals"] intValue];
        team.chairman = [[teamJSON objectForKey:@"chairman"] boolValue];
        if ([[teamJSON objectForKey:@"momentum"] isEqualToString:@"up"])
            team.momentum = Up;
        else if ([[teamJSON objectForKey:@"momentum"] isEqualToString:@"down"])
            team.momentum = Down;
        else
            team.momentum = Same;
        team.weeks = [NSMutableDictionary new];
        [teams addObject:team];
        
        // the points scored are in a dictionary, one entry per week
        // use this to work out the total points and the motm data
        NSDictionary *weeks = [teamJSON objectForKey:@"weeks"];
        for (NSNumber *weekNumber in weeks.allKeys) {
            int weekPoints = [weeks[weekNumber] intValue];
            team.totalPoints += weekPoints;
            if ([weekNumber intValue] == _weekNumber)
                team.weeklyPoints += weekPoints;
            [team.weeks setObject:[NSNumber numberWithInt:weekPoints] forKey:weekNumber];
            
            int monthNumber = [self getMonthWithin:_months forWeek:[weekNumber intValue]];
            
            NSUInteger index = [_months indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                BOOL found = (((Month *) item).monthNumber == monthNumber);
                return found;
            }];
            
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
    
    // sort the motm by points
    for (Month *month in _months) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO];
        month.managers = [NSMutableArray arrayWithArray:[month.managers sortedArrayUsingDescriptors:@[descriptor]]];
    }
 
    // league sorted by points
    NSMutableArray *league = [NSMutableArray arrayWithArray:[teams sortedArrayUsingComparator:^(id obj1, id obj2) {
        return -1 * [[NSNumber numberWithLong:((Team *) obj1).totalPoints] compare:[NSNumber numberWithLong:((Team *)obj2).totalPoints]];
    }]];
    
    // go through and assign the league positions
    long previousPoints = 0, previousPosition = 0, userPosition = 0;
    for (int i = 0; i < league.count; i++) {
        Team *team = [league objectAtIndex:i];
        team.leaguePosition = (team.totalPoints == previousPoints) ? previousPosition : i + 1;
        
        previousPoints = team.totalPoints;
        previousPosition = team.leaguePosition;
        
        if ([getOptionValueForKey(@"managerName") isEqualToString:team.managerName]) {
            userPosition = team.leaguePosition;
        }
    }

    if (_weekNumber > oldWeek) {
        setOptionBoolForKey(@"newWeek", YES);
        if (userPosition > 0)
            setOptionValueForKey(@"newPosition", [NSNumber numberWithLong:userPosition]);
    }
    else if (cache && userPosition > 0) {
        setOptionValueForKey(@"position", [NSNumber numberWithLong:userPosition]);
    }
    setOptionValueForKey(@"week", [NSNumber numberWithInt:_weekNumber]);
    
    // golden boot sort by goals
    _goldenBoot = [NSMutableArray arrayWithArray:[teams sortedArrayUsingComparator:^(id obj1, id obj2) {
        return -1 * [[NSNumber numberWithLong:((Team *) obj1).goals] compare:[NSNumber numberWithLong:((Team *)obj2).goals]];
    }]];
    
    // go through and assign the golden boot positions
    long previousGoals = 0;
    previousPosition = 0;
    for (int i = 0; i < _goldenBoot.count; i++) {
        Team *team = [_goldenBoot objectAtIndex:i];
        team.goldenBootPosition = (team.totalPoints == previousGoals) ? previousPosition : i + 1;
        
        previousGoals = team.goals;
        previousPosition = team.goldenBootPosition;
    }
    
    // save the cache to disk for pre-population next time app is opened
    BOOL success = NO;
    if (cache) {
        NSLog(@"Cache data");
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

// months are listed in reverse order
- (int) getMonthWithin:(NSArray *) months forWeek:(int) weekNumber  {
    int weeksSoFar = 0;
    for (long i = (months.count - 1); i >= 0; i--) {
        Month *month = months[i];
        weeksSoFar += month.weeks;
        if (weekNumber <= weeksSoFar)
            return month.monthNumber;
    }
    return 0;
}

- (Team *) getTeam:(NSString *) managerName {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"managerName == %@", managerName];
    NSArray *results = [_league filteredArrayUsingPredicate:predicate];
    return results.count > 0 ? [results objectAtIndex:0] : nil;
}

- (void) updatePosition:(NSString *) managerName {
    Team *team = [self getTeam:managerName];
    if (team) {
        setOptionValueForKey(@"position", @0);
        setOptionValueForKey(@"newPosition", [NSNumber numberWithLong:team.leaguePosition]);
    }
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
                          @"Mr J Ransley",
                          @"Mr M Riley"];
    });
    return _managerNames;
}

@end
