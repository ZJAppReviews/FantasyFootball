//
//  TeamManager.h
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamManager : NSObject

@property (nonatomic, strong) NSMutableArray *league;
@property (nonatomic, strong) NSMutableArray *goldenBoot;
@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSMutableArray *motm;

+ (TeamManager *) getInstance;
- (void) loadData:(NSDictionary *) data;

@end
