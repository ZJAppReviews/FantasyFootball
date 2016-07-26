//
//  MOTMViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "MOTMViewController.h"
#import "TeamManager.h"
#import "Month.h"
#import "Util.h"

@interface MOTMViewController ()

@property (nonatomic, strong) NSArray* months;

@end

@implementation MOTMViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData:)
                                                     name:@"ReloadData"
                                                   object:nil];
    }
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:229/255.0 green:249/255.0 blue:255/255.0 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.allowsSelection = NO;
    
    _months = [TeamManager getInstance].months;
}

- (void) reloadData:(NSNotification *)notification {
    _months = [TeamManager getInstance].months;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _months.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Month *month = [_months objectAtIndex:section];
    return month.managers.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Month *month = [_months objectAtIndex:section];
    return [NSString stringWithFormat:@"     %@ (%@)", month.monthName, month.dateRange];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Section" forIndexPath:indexPath];
    
    Month *month = [_months objectAtIndex:indexPath.section];
    NSDictionary *manager = month.managers[indexPath.row];

    NSString *managerName = manager[@"managerName"];
    int points = [manager[@"points"] intValue];
    
    Team *team = [[TeamManager getInstance] getTeam:managerName];
    cell.textLabel.text = team ? getManagerName(team) : managerName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", points];
    
    if ([managerName isEqualToString:getOptionValueForKey(@"managerName")])
        cell.backgroundColor = getAppDelegate().userBackground;
    else
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
