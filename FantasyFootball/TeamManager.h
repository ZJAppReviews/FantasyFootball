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
- (void) loadData:(NSDictionary *) data;
- (Team *) getTeam:(NSString *) managerName;
- (void) updatePosition:(NSString *) managerName;
+ (NSArray *) managerNames;

@end
