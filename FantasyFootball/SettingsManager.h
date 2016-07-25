//
//  SettingsManager.h
//  DebtManager
//
//  Created by Mark Riley on 23/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsManager : NSObject {
    NSMutableData *remoteSettingsData;
    NSDictionary *remoteSettings;

    BOOL isLoading;
}

+ (SettingsManager *) getInstance;
+ (void) loadSettings;

@end
