//
//  ManagerStatsViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 06/08/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "DINLTStatsViewController.h"
#import "StatsKeyValueViewController.h"
#import "Util.h"

@interface DINLTStatsViewController ()

@property (nonatomic) NSArray *managers;

@end

@implementation DINLTStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.rowHeight = 60;
    
    self.navigationItem.backBarButtonItem =	[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"manager_stats" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    _managers = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
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
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Detail" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0: cell.textLabel.text = @"Average League Position"; break;
        case 1: cell.textLabel.text = @"Average League Points"; break;
        case 2: cell.textLabel.text = @"Average Goals"; break;
        case 3: cell.textLabel.text = @"Weeks At Top"; break;
        case 4: cell.textLabel.text = @"Total Prize Money"; break;
        case 5: cell.textLabel.text = @"Side Bets Profit"; break;
        case 6: cell.textLabel.text = @"All Team Names"; break;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSInteger row = [self.tableView indexPathForSelectedRow].row;
    StatsKeyValueViewController *vc = [segue destinationViewController];
    vc.DINLT = YES;
    
    switch (row) {
        case 0: {
            // sort by pos
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"averagePos" ascending:YES];
            _managers = [_managers sortedArrayUsingDescriptors:@[descriptor]];
            vc.keyValues = _managers;
            vc.detail = @"averagePos";
            break;
        }
        case 1: {
            // sort by points
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"averagePoints" ascending:NO];
            _managers = [_managers sortedArrayUsingDescriptors:@[descriptor]];
            vc.keyValues = _managers;
            vc.detail = @"averagePoints";
            break;
        }
        case 2: {
            // sort by goals
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"averageGoals" ascending:NO];
            _managers = [_managers sortedArrayUsingDescriptors:@[descriptor]];
            vc.keyValues = _managers;
            vc.detail = @"averageGoals";
            break;
        }
        case 3: {
            // sort by weeks at top
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"weeksAtTop" ascending:NO];
            _managers = [_managers sortedArrayUsingDescriptors:@[descriptor]];
            vc.keyValues = _managers;
            vc.detail = @"weeksAtTop";
            break;
        }
        case 4: {
            // sort by prize money
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"prizeMoney" ascending:NO];
            _managers = [_managers sortedArrayUsingDescriptors:@[descriptor]];
            vc.keyValues = _managers;
            vc.detail = @"prizeMoney";
            break;
        }
        case 5: {
            // sort by side bets
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sideBets" ascending:NO];
            _managers = [_managers sortedArrayUsingDescriptors:@[descriptor]];
            vc.keyValues = _managers;
            vc.detail = @"sideBets";
            break;
        }
        case 6: {
            // collect all team names, use a set to avoid duplicates
            NSMutableSet *teamNames = [NSMutableSet set];
            for (NSDictionary *manager in _managers) {
                for (NSDictionary *year in ((NSArray *) manager[@"years"])) {
                    [teamNames addObject:@{@"teamName" : year[@"teamName"], @"managerName" : manager[@"managerName"]}];
                }
            }

            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"teamName" ascending:YES];
            vc.keyValues = [[teamNames allObjects] sortedArrayUsingDescriptors:@[descriptor]];
            
            vc.detail = @"allTeamNames";
            break;
        }
    }
}


@end
