//
//  Team.h
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Team : NSObject

@property (nonatomic) NSString *teamName;
@property (nonatomic) NSString *managerName;
@property (nonatomic) long leaguePosition;
@property (nonatomic) long goldenBootPosition;
@property (nonatomic) long points;
@property (nonatomic) long goals;
@property (nonatomic) BOOL chairman;
@property (nonatomic) NSArray *months;

@end
