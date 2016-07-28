//
//  TeamViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "LeagueViewController.h"
#import "TeamDetailViewController.h"
#import "Team.h"
#import "TeamManager.h"
#import "Util.h"
#import <Crashlytics/Crashlytics.h>

@interface LeagueViewController () {
    
}

@property (nonatomic, strong) NSMutableArray *teams;

@end

@implementation LeagueViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData:)
                                                     name:@"ReloadData"
                                                   object:nil];
    }
    return [super initWithCoder:aDecoder];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 56;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.backBarButtonItem =	[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _teams = [TeamManager getInstance].league;
    if ([TeamManager getInstance].year)
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - Week %i", [TeamManager getInstance].year, [TeamManager getInstance].weekNumber];
    else
        self.navigationItem.title = @"No Data";
    NSLog(@"viewDidLoad %@ data", ([TeamManager getInstance].year ? @"with" : @"without"));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");
    if (!getOptionValueForKey(@"managerName")) {
        // need to show the screen to choose your name
        [self performSegueWithIdentifier:@"WhoAreYa" sender: self];
    }
    else {
        [self showNewWeekAlert];
    }
}

- (void) reloadData:(NSNotification *)notification {
    NSLog(@"Refresh data");
    
    _teams = [TeamManager getInstance].league;
    if ([TeamManager getInstance].year)
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - Week %i", [TeamManager getInstance].year, [TeamManager getInstance].weekNumber];
    else
        self.navigationItem.title = @"No Data";
    
    if (self.isViewLoaded && self.view.window) {
        // don't alert if WhoAreYa screen is overlaid
        UITabBarController *tabBarController = (UITabBarController *)self.view.window.rootViewController;
        id controller = [tabBarController presentedViewController];
        UIViewController *modalViewController = nil;
        
        if (![controller isKindOfClass:UIAlertController.class]) {
            modalViewController = ((UINavigationController *) controller).visibleViewController;
        
            if (!modalViewController)
                [self showNewWeekAlert];
            else
                [self.tableView reloadData];
        }
    }
    else {
        [self.tableView reloadData];
    }
}

- (void) showNewWeekAlert {
    if (optionEnabled(@"newWeek")) {
        setOptionBoolForKey(@"newWeek", NO);
        
        int week = [getOptionValueForKey(@"newWeek") intValue];
        int oldPosition = [getOptionValueForKey(@"position") intValue];
        int newPosition = [getOptionValueForKey(@"newPosition") intValue];
        
        NSString *subscript = (newPosition == 1) ? @"st" : (newPosition == 2) ? @"nd" : (newPosition == 3) ? @"rd" : @"th";
        NSString *title = [NSString stringWithFormat:@"%i%@ in the League", newPosition, subscript];
        NSString *message;
        
        if (week == 1 || oldPosition == 0) {
            switch (newPosition) {
                case 1:
                    message = [NSString stringWithFormat:@"Woo Hoo, You're Top of the Pops!"];
                    break;
                case 2:
                case 3:
                case 4:
                case 5:
                    message = [NSString stringWithFormat:@"Good Start, Top 5!"];
                    break;
                case 6:
                case 7:
                case 8:
                case 9:
                case 10:
                    message = [NSString stringWithFormat:@"Mid table mediocrity for you!"];
                    break;
                case 11:
                case 12:
                case 13:
                case 14:
                case 15:
                    message = [NSString stringWithFormat:@"Near the bottom, must try harder!"];
                    break;
                case 16:
                    message = [NSString stringWithFormat:@"D'oh, a Bottom Dweller already!"];
                    break;
            }
            [self.tableView reloadData];
        }
        else if (newPosition > 0) {
            int movement = oldPosition - newPosition;
            
            NSString *places = abs(movement) > 1 ? @"places" : @"place";
            if (movement > 0) {
                if (newPosition == 1)
                    message = [NSString stringWithFormat:@"You made it to the summit! Respect, blud."];
                else
                    message = [NSString stringWithFormat:@"Yessss! Up %i %@, heading in the right direction!", movement, places];
            }
            else if (movement < 0) {
                if (newPosition == 16)
                    message = [NSString stringWithFormat:@"Oh no no no, Wooden Cock time!"];
                else
                    message = [NSString stringWithFormat:@"Noooo! Down %i %@, oh dear oh dear!", abs(movement), places];
            }
            else {
                if (newPosition == 16)
                    message = [NSString stringWithFormat:@"Still a Bottom Dweller, a Wooden Cock could be heading your way!"];
                else if (newPosition == 1)
                    message = [NSString stringWithFormat:@"Still Top of the Pops, nice one!"];
                else
                    message = [NSString stringWithFormat:@"Same spot as last week, could be worse I suppose!"];
            }
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:(oldPosition - 1) inSection:0] toIndexPath:[NSIndexPath indexPathForRow:(newPosition - 1) inSection:0]];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.6 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
        setOptionValueForKey(@"position", [NSNumber numberWithInt:newPosition]);
        setOptionValueForKey(@"newPosition", @0);
    }
    else {
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_teams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Team"];
    
    Team *team = [_teams objectAtIndex:indexPath.row];
    UILabel *positionLabel = (UILabel *)[cell viewWithTag:1];
    positionLabel.text = [NSString stringWithFormat:@"%li", team.leaguePosition];
    
    UILabel *teamLabel = (UILabel *)[cell viewWithTag:2];
    teamLabel.text = team.teamName;
    
    UILabel *managerLabel = (UILabel *)[cell viewWithTag:3];
    managerLabel.text = getManagerName(team);
    
    UILabel *totalPointsLabel = (UILabel *)[cell viewWithTag:4];
    totalPointsLabel.text = [NSString stringWithFormat:@"%li", team.totalPoints];
    
    UILabel *weeklyPointsLabel = (UILabel *)[cell viewWithTag:5];
    weeklyPointsLabel.text = [NSString stringWithFormat:@"%li", team.weeklyPoints];
    
    UIImageView *momentumView = (UIImageView *)[cell viewWithTag:6];
    enum Momentum momentum = team.momentum;
    switch (momentum) {
        case Up:
            momentumView.image = [UIImage imageNamed:@"arrow_up"];
            break;
        case Down:
            momentumView.image = [UIImage imageNamed:@"arrow_down"];
            break;
        case Same:
            momentumView.image = [UIImage imageNamed:@"arrow_right"];
            break;
    }
    
    /*medalView.layer.cornerRadius = 12;
    medalView.layer.masksToBounds = YES;
    if (team.leaguePosition <= 3)
        medalView.backgroundColor = [UIColor colorWithRed:255.0/255 green:215.0/255 blue:0 alpha:1.0];
    else if (team.leaguePosition <= 10)
        medalView.backgroundColor = [UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1.0];
    else
        medalView.backgroundColor = [UIColor colorWithRed:205.0/255 green:127.0/255 blue:50.0/255 alpha:1.0];*/
    
    
    if ([team.managerName isEqualToString:getOptionValueForKey(@"managerName")])
        cell.backgroundColor = getAppDelegate().userBackground;
    else
        cell.backgroundColor = getAppDelegate().rowBackground;
    
    UIView *bView = [[UIView alloc] initWithFrame:cell.bounds];
    bView.backgroundColor = [UIColor colorWithRed:224/255.0 green:228/255.0 blue:240/255.0 alpha:1.0];
    cell.selectedBackgroundView = bView;
    
    // extend the separator to the left edge
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
    
    NSLog(@"Cell: %@, Points: %@", managerLabel.text, totalPointsLabel.text);
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    Team *movedObject = _teams[sourceIndexPath.row];
    [_teams removeObject:movedObject];
    [_teams insertObject:movedObject atIndex:destinationIndexPath.row];
    
    long start = MIN(sourceIndexPath.row, destinationIndexPath.row);
    for (long i = start; i < _teams.count; i++) {
        Team *team = _teams[i];
        team.leaguePosition = i + 1;
    }
    
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //[[Crashlytics sharedInstance] crash];
    
    if ([segue.identifier isEqualToString:@"WhoAreYa"])
        return;
    
    TeamDetailViewController *vc = [segue destinationViewController];
    
    Team *team = [_teams objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    vc.team = team;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
