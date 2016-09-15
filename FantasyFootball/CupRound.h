//
//  CupRound.h
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CupRound : NSObject

@property (nonatomic) int roundNumber;
@property (nonatomic) int weekNumber;
@property (nonatomic) NSString *dateRange;
@property (nonatomic) NSMutableArray *ties;

- (void) addTie:(NSDictionary *) tie;

@end
