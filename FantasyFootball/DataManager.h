//
//  SettingsManager.h
//  DebtManager
//
//  Created by Mark Riley on 23/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject {
    NSDictionary *remoteJSONData;
    NSDictionary *staticData;
    NSArray *teamRows, *overallRows;

    BOOL isLoading;
}

+ (DataManager *) getInstance;
+ (void) loadData;

@end
