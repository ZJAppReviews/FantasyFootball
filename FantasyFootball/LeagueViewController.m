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
    
    _teams = [TeamManager getInstance].league;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!getOptionValueForKey(@"managerName")) {
        // need to show the screen to choose your name
        [self performSegueWithIdentifier:@"WhoAreYa" sender: self];
    }
}

- (void) reloadData:(NSNotification *)notification {
    _teams = [TeamManager getInstance].league;
    [self.tableView reloadData];
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
    managerLabel.text = team.managerName;
    if (team.chairman) {
        managerLabel.text = [managerLabel.text substringFromIndex:5];
        managerLabel.text = [NSString stringWithFormat:@"Chairman %@ *", managerLabel.text];
    }
    
    UILabel *pointsLabel = (UILabel *)[cell viewWithTag:4];
    pointsLabel.text = [NSString stringWithFormat:@"%li", team.points];
    
    UIView *medalView = (UILabel *)[cell viewWithTag:5];
    medalView.layer.cornerRadius = 12;
    medalView.layer.masksToBounds = YES;
    if (team.leaguePosition <= 3)
        medalView.backgroundColor = [UIColor colorWithRed:255.0/255 green:215.0/255 blue:0 alpha:1.0];
    else if (team.leaguePosition <= 10)
        medalView.backgroundColor = [UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1.0];
    else
        medalView.backgroundColor = [UIColor colorWithRed:205.0/255 green:127.0/255 blue:50.0/255 alpha:1.0];
    
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
