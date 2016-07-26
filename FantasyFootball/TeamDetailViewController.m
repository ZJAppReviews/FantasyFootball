//
//  TeamDetailViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "Team.h"

@interface TeamDetailViewController ()

@end

@implementation TeamDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = _team.teamName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Detail"];
    
    switch (indexPath.row) {
        case 0: {
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            label.text = @"Team Name";
            
            UITextField *value = (UITextField *)[cell viewWithTag:2];
            value.delegate = self;
            value.text = [NSString stringWithFormat:@"%@", _team.teamName];
            value.alpha = 0.999;
            break;
        }
        case 1: {
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            label.text = @"Manager Name";
            
            UITextField *value = (UITextField *)[cell viewWithTag:2];
            value.delegate = self;
            value.text = [NSString stringWithFormat:@"%@", _team.managerName];
            value.alpha = 0.9999;
            break;
        }
        case 2: {
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            label.text = @"Points";
            
            UITextField *value = (UITextField *)[cell viewWithTag:2];
            value.delegate = self;
            value.text = [NSString stringWithFormat:@"%li", _team.points];
            value.alpha = 0.99999;
            break;
        }
        case 3: {
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            label.text = @"Goals";
            
            UITextField *value = (UITextField *)[cell viewWithTag:2];
            value.delegate = self;
            value.text = [NSString stringWithFormat:@"%li", _team.goals];
            value.alpha = 0.999999;
            break;
        }
    }
    
    return cell;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    
    CGFloat alpha = textField.alpha;
    if ([self doubleValues:alpha equalsDoubleValue:0.999999 withAccuracy:0.000001]) {
        _team.goals = [textField.text intValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
    else if ([self doubleValues:alpha equalsDoubleValue:0.99999 withAccuracy:0.00001]) {
        _team.points = [textField.text intValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
    else if ([self doubleValues:alpha equalsDoubleValue:0.9999 withAccuracy:0.0001]) {
        _team.managerName = textField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
    else if ([self doubleValues:alpha equalsDoubleValue:0.999 withAccuracy:0.001]) {
        _team.teamName = textField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }

    return YES;
}

- (BOOL) doubleValues:(double) double1 equalsDoubleValue:(double) double2 withAccuracy:(double) accuracy {
    return (fabs(double1 - double2) < accuracy);
}

@end
