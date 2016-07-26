//
//  DismissSegue.m
//  FantasyFootball
//
//  Created by Mark Riley on 26/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
