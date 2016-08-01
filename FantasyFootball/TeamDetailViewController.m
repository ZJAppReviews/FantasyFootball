//
//  TeamDetailViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "Team.h"
#import "TeamWeek.h"
#import "TeamManager.h"
#import "Month.h"

@interface TeamDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *teamName;
@property (weak, nonatomic) IBOutlet UITextField *managerName;
@property (weak, nonatomic) IBOutlet UITextField *totalPoints;
@property (weak, nonatomic) IBOutlet UITextField *goals;
@property (weak, nonatomic) IBOutlet UILabel *motm;
@property (weak, nonatomic) IBOutlet UITableView *weeklyPointsTable;

@end

@implementation TeamDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = _team.teamName;
    _teamName.text = [NSString stringWithFormat:@"%@", _team.teamName];
    _managerName.text = [NSString stringWithFormat:@"%@", _team.managerName];
    _totalPoints.text = [NSString stringWithFormat:@"%li", _team.totalPoints];
    _goals.text = [NSString stringWithFormat:@"%li", _team.goals];
    
    if (_team.motms.count == 0)
        _motm.text = @"None";
    else {
        BOOL firstMonth = YES;
        _motm.text = @"";
        for (NSNumber *month in _team.motms) {
            _motm.text = [NSString stringWithFormat:@"%@%@%@", _motm.text, (firstMonth ? @"" : @", "), [((Month *)[TeamManager getInstance].months[10 - [month intValue]]).monthName substringToIndex:3]];
            firstMonth = NO;
        }
    }
    
    _weeklyPointsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _weeklyPointsTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _weeklyPointsTable.allowsSelection = NO;
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
    return _team.weeks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Points"];
    cell.textLabel.text = [NSString stringWithFormat:@"%li", (_team.weeks.count - indexPath.row)];
    
    TeamWeek *teamWeek = [_team.weeks objectAtIndex:(_team.weeks.count - indexPath.row - 1)];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%li", teamWeek.points];
    
    // extend the separator to the left edge
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
    
    return cell;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == _goals) {
        _team.goals = [textField.text intValue];
        [[TeamManager getInstance] sortGoals];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
    else if (textField == _totalPoints) {
        _team.totalPoints = [textField.text intValue];
        [[TeamManager getInstance] sortLeague];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
    else if (textField == _managerName) {
        _team.managerName = textField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
    else if (textField == _teamName) {
        _team.teamName = textField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }

    return YES;
}

- (BOOL) doubleValues:(double) double1 equalsDoubleValue:(double) double2 withAccuracy:(double) accuracy {
    return (fabs(double1 - double2) < accuracy);
}

@end
