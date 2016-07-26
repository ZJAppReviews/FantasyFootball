//
//  Month.m
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "Month.h"

@implementation Month

- (void) addManager:(NSDictionary *) manager {
    if (!_managers)
        _managers = [NSMutableArray new];
    
    [_managers addObject:manager];
}

@end
