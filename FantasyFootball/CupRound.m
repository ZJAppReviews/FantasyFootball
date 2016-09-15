//
//  CupRound.m
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "CupRound.h"

@implementation CupRound

- (void) addTie:(NSDictionary *) tie {
    if (!_ties)
        _ties = [NSMutableArray new];
    
    [_ties addObject:tie];
}

@end
