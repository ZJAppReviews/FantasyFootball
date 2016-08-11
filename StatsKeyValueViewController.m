//
//  StatsKeyValueViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 06/08/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "StatsKeyValueViewController.h"
#import "Util.h"

@interface StatsKeyValueViewController ()

@end

@implementation StatsKeyValueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    if ([_detail isEqualToString:@"position"])
        self.navigationItem.title = @"League Positions";
    else if ([_detail isEqualToString:@"goals"])
        self.navigationItem.title = @"Goals Scored";
    else if ([_detail isEqualToString:@"teamName"])
        self.navigationItem.title = @"Team Names";
    else if ([_detail isEqualToString:@"averagePos"])
        self.navigationItem.title = @"Average League Positions";
    else if ([_detail isEqualToString:@"averagePoints"])
        self.navigationItem.title = @"Average League Points";
    else if ([_detail isEqualToString:@"averageGoals"])
        self.navigationItem.title = @"Average Goals";
    else if ([_detail isEqualToString:@"weeksAtTop"])
        self.navigationItem.title = @"Weeks At Top";
    else if ([_detail isEqualToString:@"prizeMoney"])
        self.navigationItem.title = @"Total Prize Money";
    else if ([_detail isEqualToString:@"sideBets"])
        self.navigationItem.title = @"Side Bets Profit";
    else if ([_detail isEqualToString:@"allTeamNames"])
        self.navigationItem.title = @"All Team Names";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _keyValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:([_detail isEqualToString:@"allTeamNames"] ? @"KeyValueSub" : @"KeyValue") forIndexPath:indexPath];
    
    if (_DINLT) {
        NSDictionary *values = _keyValues[indexPath.row];
        if ([_detail isEqualToString:@"allTeamNames"]) {
            cell.textLabel.text = values[@"teamName"];
            cell.detailTextLabel.text = values[@"managerName"];
        }
        else {
            cell.textLabel.text = values[@"managerName"];
            if ([_detail isEqualToString:@"averagePos"] || [_detail isEqualToString:@"averagePoints"] || [_detail isEqualToString:@"averageGoals"])
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f", [values[_detail] floatValue]];
            else if ([_detail isEqualToString:@"weeksAtTop"])
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [values[_detail] intValue]];
            else if ([_detail isEqualToString:@"prizeMoney"] || [_detail isEqualToString:@"sideBets"]) {
                NSNumber *value = values[_detail] ? values[_detail] : @0;
                cell.detailTextLabel.text = [getCurrencyFormatter() stringFromNumber:value];
            }
            else
                cell.detailTextLabel.text = values[_detail];
        }
    }
    else {
        NSDictionary *year = _keyValues[indexPath.row];
        cell.textLabel.text = year[@"year"];
        if ([_detail isEqualToString:@"position"] || [_detail isEqualToString:@"goals"])
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [year[_detail] intValue]];
        else
            cell.detailTextLabel.text = year[_detail];
    }
    
    cell.backgroundColor = getAppDelegate().rowBackground;
    
    UIView *bView = [[UIView alloc] initWithFrame:cell.bounds];
    bView.backgroundColor = [UIColor colorWithRed:224/255.0 green:228/255.0 blue:240/255.0 alpha:1.0];
    cell.selectedBackgroundView = bView;
    
    // extend the separator to the left edge
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
