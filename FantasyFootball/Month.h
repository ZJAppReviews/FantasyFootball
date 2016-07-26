//
//  Month.h
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Month : NSObject

@property (nonatomic) int monthNumber;
@property (nonatomic) NSString *monthName;
@property (nonatomic) NSString *dateRange;
@property (nonatomic) NSMutableArray *managers;

- (void) addManager:(NSDictionary *) manager;

@end
