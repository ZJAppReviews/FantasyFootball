//
//  GoalsViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "GoldenBootViewController.h"
#import "Team.h"
#import "TeamManager.h"

@interface GoldenBootViewController () {
    
}

@property (nonatomic, strong) NSMutableArray *teams;

@end

@implementation GoldenBootViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 56;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _teams = [TeamManager getInstance].goldenBoot;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"ReloadData"
                                               object:nil];
}

- (void) reloadData:(NSNotification *)notification {
    _teams = [TeamManager getInstance].goldenBoot;
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
    positionLabel.text = [NSString stringWithFormat:@"%li", team.goldenBootPosition];
    
    UILabel *teamLabel = (UILabel *)[cell viewWithTag:2];
    teamLabel.text = team.teamName;
    
    UILabel *managerLabel = (UILabel *)[cell viewWithTag:3];
    managerLabel.text = team.managerName;
    
    UILabel *goalsLabel = (UILabel *)[cell viewWithTag:4];
    goalsLabel.text = [NSString stringWithFormat:@"%li", team.goals];
    
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
