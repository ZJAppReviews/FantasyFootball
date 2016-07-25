//
//  TeamManager.m
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "TeamManager.h"
#import "Team.h"

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

- (void) loadTeams:(NSArray *) teamsJSON {
    NSMutableArray *teams = [NSMutableArray new];
    
    for (NSDictionary *teamJSON in teamsJSON) {
        Team *team = [Team new];
        team.teamName = [teamJSON objectForKey:@"teamName"];
        team.managerName = [teamJSON objectForKey:@"managerName"];
        team.points = [[teamJSON objectForKey:@"points"] intValue];
        team.goals = [[teamJSON objectForKey:@"goals"] intValue];
        team.chairman = [[teamJSON objectForKey:@"chairman"] boolValue];
        [teams addObject:team];
    }
    
    // league sorted by points
    _league = [NSMutableArray arrayWithArray:[teams sortedArrayUsingComparator:^(id obj1, id obj2) {
        return -1 * [[NSNumber numberWithLong:((Team *) obj1).points] compare:[NSNumber numberWithLong:((Team *)obj2).points]];
    }]];
    
    // go through and assign the positions
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
    
    // go through and assign the positions
    long previousGoals = 0;
    previousPosition = 0;
    for (int i = 0; i < _goldenBoot.count; i++) {
        Team *team = [_goldenBoot objectAtIndex:i];
        team.goldenBootPosition = (team.points == previousGoals) ? previousPosition : i + 1;
        
        previousGoals = team.goals;
        previousPosition = team.goldenBootPosition;
    }
}

@end
