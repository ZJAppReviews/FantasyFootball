//
//  TeamDetailViewController.h
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimatedNumericLabel.h"

@class Team;

@interface TeamDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AnimatedNumericLabelDelegate>

@property (nonatomic, strong) Team *team;

@end
