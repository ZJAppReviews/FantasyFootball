//
//  TeamWeek.h
//  FantasyFootball
//
//  Created by Mark Riley on 31/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Team;

@interface TeamWeek : NSObject

@property (nonatomic) Team *team;
@property (nonatomic) long weekNumber;
@property (nonatomic) long points, totalPoints;
@property (nonatomic) long position;

@end
