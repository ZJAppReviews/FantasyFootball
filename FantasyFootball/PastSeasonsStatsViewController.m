//
//  PastSeasonsStatsViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 06/08/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "PastSeasonsStatsViewController.h"
#import "DataManager.h"
#import "Util.h"

@interface PastSeasonsStatsViewController ()

@property (nonatomic) NSArray *managers;

@end

@implementation PastSeasonsStatsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        /*[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData:)
                                                     name:@"ReloadData"
                                                   object:nil];*/
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.rowHeight = 60;
    
    self.navigationItem.backBarButtonItem =	[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //NSError *error = nil;
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"manager_stats" ofType:@"json"];
    //NSData *data = [NSData dataWithContentsOfFile:filePath];
    //_managers = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    /*_managers = [TeamManager getInstance].managerStats;
    if (!_managers) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cache_manager_stats.dat"];
        NSArray *cacheData = [NSArray arrayWithContentsOfFile:cachePath];
        if (cacheData)
            _managers = cacheData;
    }
    
    // sort by tffp
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"tffp" ascending:NO];
    _managers = [_managers sortedArrayUsingDescriptors:@[descriptor]];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void) reloadData:(NSNotification *)notification {
    _managers = [TeamManager getInstance].managerStats;
    
    // sort by tffp
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"tffp" ascending:NO];
    _managers = [_managers sortedArrayUsingDescriptors:@[descriptor]];
    
    [self.tableView reloadData];
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Season" forIndexPath:indexPath];
    
    //NSDictionary *managerStats = _managers[indexPath.row];
    switch (indexPath.row) {
        case 0: cell.textLabel.text = @"Current Season"; break;
        case 1: cell.textLabel.text = @"2016/2017"; break;
        case 2: cell.textLabel.text = @"2015/2016"; break;
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
    NSString *seasonText = [self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Info"
                                                                             message:[NSString stringWithFormat:@"Switched to %@", seasonText]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:nil];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    switch (indexPath.row) {
        case 0: removeOptionForKey(@"season"); break;
        case 1: setOptionValueForKey(@"season", @"2016_17"); break;
        case 2: setOptionValueForKey(@"season", @"2015_16"); break;
    }
    
    [DataManager loadData];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ManagerStatsDetailViewController *vc = [segue destinationViewController];
    vc.stats = _managers[[self.tableView indexPathForSelectedRow].row];
}*/


@end
