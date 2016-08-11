//
//  ManagerStatsViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 06/08/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "ManagerStatsDetailViewController.h"
#import "StatsKeyValueViewController.h"
#import "Util.h"

@interface ManagerStatsDetailViewController ()

@end

@implementation ManagerStatsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.navigationItem.backBarButtonItem =	[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.title = _stats[@"managerName"];
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Detail" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Seasons";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [_stats[@"seasons"] intValue]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 1:
            cell.textLabel.text = @"League Wins";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [_stats[@"1st"] intValue]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 2:
            cell.textLabel.text = @"2nd Place";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [_stats[@"2nd"] intValue]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 3:
            cell.textLabel.text = @"3rd Place";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [_stats[@"3rd"] intValue]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 4:
            cell.textLabel.text = @"FU Cup Wins";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [_stats[@"cup_win"] intValue]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 5:
            cell.textLabel.text = @"FU Cup Runner Up";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [_stats[@"cup_ru"] intValue]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 6:
            cell.textLabel.text = @"MOTM";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [_stats[@"motm"] intValue]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 7:
            cell.textLabel.text = @"League Positions";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 8:
            cell.textLabel.text = @"Goals Scored";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 9:
            cell.textLabel.text = @"Team Names";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 7:
        case 8:
        case 9:{
            [self performSegueWithIdentifier:@"StatsKeyValue" sender: self];
            break;
        }
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSInteger row = [self.tableView indexPathForSelectedRow].row;
    
    StatsKeyValueViewController *vc = [segue destinationViewController];
    if (row == 7) {
        vc.keyValues = _stats[@"years"];
        vc.detail = @"position";
    }
    else if (row == 8) {
        NSMutableArray *years = [NSMutableArray array];
        for (NSDictionary *year in _stats[@"years"]) {
            if ([year[@"goals"] intValue] != 0)
                [years addObject:year];
        }
        vc.keyValues = years;
        vc.detail = @"goals";
    }
    else if (row == 9) {
        vc.keyValues = _stats[@"years"];
        vc.detail = @"teamName";
    }
}


@end
