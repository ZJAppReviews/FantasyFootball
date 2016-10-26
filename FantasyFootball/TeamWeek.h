//
//  TeamWeek.h
//  FantasyFootball
//
//  Created by Mark Riley on 31/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Team.h"

@class Team;

@interface TeamWeek : NSObject

@property (nonatomic) Team *team;
@property (nonatomic) long weekNumber;
@property (nonatomic) long points, totalPoints, goals;
@property (nonatomic) long position;
@property (nonatomic) enum Momentum momentum;

@end
