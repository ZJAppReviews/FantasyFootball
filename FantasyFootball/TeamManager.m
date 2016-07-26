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

- (void) loadData:(NSDictionary *) data {
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
        month.managers = [NSMutableArray new];
        [months addObject:month];
    }
    
    // months sorted by reverse date
    _months = [NSMutableArray arrayWithArray:[months sortedArrayUsingComparator:^(id obj1, id obj2) {
        return -1 * [[NSNumber numberWithLong:((Month *) obj1).monthNumber] compare:[NSNumber numberWithLong:((Month *)obj2).monthNumber]];
    }]];
    
    // create the team objects
    for (NSDictionary *teamJSON in teamsJSON) {
        Team *team = [Team new];
        team.teamName = [teamJSON objectForKey:@"teamName"];
        team.managerName = [teamJSON objectForKey:@"managerName"];
        team.points = [[teamJSON objectForKey:@"points"] intValue];
        team.goals = [[teamJSON objectForKey:@"goals"] intValue];
        team.chairman = [[teamJSON objectForKey:@"chairman"] boolValue];
        if ([[teamJSON objectForKey:@"momentum"] isEqualToString:@"up"])
            team.momentum = Up;
        else if ([[teamJSON objectForKey:@"momentum"] isEqualToString:@"down"])
            team.momentum = Down;
        else
            team.momentum = Same;
        [teams addObject:team];
        
        // motm the month data is in a dictionary, one entry per month number
        NSDictionary *months = [teamJSON objectForKey:@"months"];
        for (NSNumber *monthNumber in months.allKeys) {
            NSUInteger index = [_months indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                BOOL found = (((Month *) item).monthNumber == [monthNumber intValue]);
                return found;
            }];
            
            if (index != NSNotFound) {
                Month *month = _months[index];
                NSMutableDictionary *manager = [NSMutableDictionary new];
                manager[@"managerName"] = team.managerName;
                manager[@"points"] = months[monthNumber];
                [month.managers addObject:manager];
            }
        }
    }
    
    // sort the motm by points
    for (Month *month in _months) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO];
        month.managers = [NSMutableArray arrayWithArray:[month.managers sortedArrayUsingDescriptors:@[descriptor]]];
    }
 
    // league sorted by points
    _league = [NSMutableArray arrayWithArray:[teams sortedArrayUsingComparator:^(id obj1, id obj2) {
        return -1 * [[NSNumber numberWithLong:((Team *) obj1).points] compare:[NSNumber numberWithLong:((Team *)obj2).points]];
    }]];
    
    // go through and assign the league positions
    long previousPoints = 0, previousPosition = 0;
    for (int i = 0; i < _league.count; i++) {
        Team *team = [_league objectAtIndex:i];
        team.leaguePosition = (team.points == previousPoints) ? previousPosition : i + 1;
        
        previousPoints = team.points;
        previousPosition = team.leaguePosition;
    }
    
    // golden boot sort by goals
    _goldenBoot = [NSMutableArray arrayWithArray:[teams sortedArrayUsingComparator:^(id obj1, id obj2) {
        return -1 * [[NSNumber numberWithLong:((Team *) obj1).goals] compare:[NSNumber numberWithLong:((Team *)obj2).goals]];
    }]];
    
    // go through and assign the golden boot positions
    long previousGoals = 0;
    previousPosition = 0;
    for (int i = 0; i < _goldenBoot.count; i++) {
        Team *team = [_goldenBoot objectAtIndex:i];
        team.goldenBootPosition = (team.points == previousGoals) ? previousPosition : i + 1;
        
        previousGoals = team.goals;
        previousPosition = team.goldenBootPosition;
    }
}

- (Team *) getTeam:(NSString *) managerName {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"managerName == %@", managerName];
    NSArray *results = [_league filteredArrayUsingPredicate:predicate];
    return results.count > 0 ? [results objectAtIndex:0] : nil;
}

@end
