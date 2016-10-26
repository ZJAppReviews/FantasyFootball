//
//  MOTMViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "FUCupViewController.h"
#import "TeamManager.h"
#import "CupRound.h"
#import "Team.h"
#import "TeamWeek.h"
#import "Util.h"

@interface FUCupViewController ()

@property (nonatomic, strong) NSArray* cupRounds;
@property (nonatomic, strong) NSMutableDictionary *sectionExpanded;

@end

@implementation FUCupViewController

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
    //self.tableView.allowsSelection = NO;
    self.tableView.sectionHeaderHeight = 30;
    self.tableView.rowHeight = 50;
    
    _cupRounds = [TeamManager getInstance].cupRounds;
    self.tableView.tableHeaderView.frame = _cupRounds.count > 0 ? CGRectZero :
            CGRectMake(0, 0, self.tableView.tableHeaderView.frame.size.width, 500);
    
    _sectionExpanded = [NSMutableDictionary new];
    for (NSInteger i = 0; i < _cupRounds.count; i++) {
        [_sectionExpanded setObject:@NO forKey:[NSNumber numberWithInteger:i]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // always 4 rounds in a cup so use this to show the correct round considering they are listed in reverse order
    int roundNumber = [TeamManager getInstance].cupRoundNumber;
    if (roundNumber > 0 && ((CupRound *)[TeamManager getInstance].cupRounds[4 - roundNumber]).ties.count > 0)
         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:(4 - roundNumber)] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)handleSectionHeaderTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        UIView *view = (UITableViewHeaderFooterView *) sender.view;
        NSNumber *expanded = [_sectionExpanded objectForKey:[NSNumber numberWithInteger:view.tag - 1]];
        [_sectionExpanded setObject:[NSNumber numberWithBool:![expanded boolValue]] forKey:[NSNumber numberWithInteger:view.tag - 1]];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:view.tag - 1] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) reloadData:(NSNotification *)notification {
    _cupRounds = [TeamManager getInstance].cupRounds;
    self.tableView.tableHeaderView.frame = _cupRounds.count > 0 ? CGRectZero :
            CGRectMake(0, 0, self.tableView.tableHeaderView.frame.size.width, 400);
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cupRounds.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CupRound *round = [_cupRounds objectAtIndex:section];
    
    //if (section > (4 - [TeamManager getInstance].cupRoundNumber) && round.ties.count > 0)
    //    return [[_sectionExpanded objectForKey:[NSNumber numberWithInteger:section]] boolValue] ? round.ties.count : 1;
    
    return round.ties.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.tag = section + 1;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = [self tableView:self.tableView titleForHeaderInSection:section];
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    [label sizeToFit];
    label.frame = CGRectMake(label.frame.origin.x, 10, label.frame.size.width, label.frame.size.height);
    [view sizeToFit];
    [view addSubview:label];
    
    // listen for taps once we know the header has been drawn
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSectionHeaderTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:singleTap];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CupRound *round = [_cupRounds objectAtIndex:section];
    NSString *headerText;
    switch (round.roundNumber) {
        case 1: headerText = @"First Round"; break;
        case 2: headerText = @"Quarter Final"; break;
        case 3: headerText = @"Semi Final"; break;
        case 4: headerText = @"Final"; break;
    }
    return [[NSString stringWithFormat:@"     %@ (%@)", headerText, round.dateRange] uppercaseString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Section" forIndexPath:indexPath];
    
    CupRound *round = [_cupRounds objectAtIndex:indexPath.section];
    NSDictionary *tie = round.ties[indexPath.row];

    NSString *managerName1 = tie[@"managerName1"];
    NSString *managerName2 = tie[@"managerName2"];

    Team *team1 = [[TeamManager getInstance] getTeam:managerName1];
    Team *team2 = [[TeamManager getInstance] getTeam:managerName2];
    NSString *winner = nil;
    
    long team1Points = 0, team2Points = 0;
    if ([TeamManager getInstance].completedWeekNumber >= round.weekNumber) {
        team1Points = ((TeamWeek *) team1.weeks[round.weekNumber - 1]).points;
        team2Points = ((TeamWeek *) team2.weeks[round.weekNumber - 1]).points;
        
        if (team1Points > team2Points)
            winner = managerName1;
        else if (team2Points > team1Points)
            winner = managerName2;
        else {
            // must have been a draw, so check manual flag
            winner = tie[@"winner"];
        }
    }
    
    UILabel *team1Label = (UILabel *)[cell viewWithTag:1];
    team1Label.text = team1.teamName;
    
    UILabel *team2Label = (UILabel *)[cell viewWithTag:2];
    team2Label.text = team2 ? team2.teamName : @"Bye";

    UILabel *points1Label = (UILabel *)[cell viewWithTag:3];
    points1Label.text = [@(team1Points) stringValue];
    
    UILabel *points2Label = (UILabel *)[cell viewWithTag:4];
    points2Label.text = [@(team2Points) stringValue];
    
    team1Label.textColor = [winner isEqualToString:managerName1] ? getAppDelegate().goldText : [UIColor blackColor];
    team2Label.textColor = [winner isEqualToString:managerName2] ? getAppDelegate().goldText : [UIColor blackColor];
    points1Label.textColor = [winner isEqualToString:managerName1] ? getAppDelegate().goldText : [UIColor blackColor];
    points2Label.textColor = [winner isEqualToString:managerName2] ? getAppDelegate().goldText : [UIColor blackColor];
    
    /*if (indexPath.row == 0 && (indexPath.section > (4 - [TeamManager getInstance].cupRoundNumber) ||
                                (indexPath.section == (4 - [TeamManager getInstance].cupRoundNumber) && [[TeamManager getInstance] isLastWeekOfMonth])))
        cell.backgroundColor = [UIColor colorWithRed:255.0/255 green:215.0/255 blue:0 alpha:1.0];
    else if ([managerName isEqualToString:getOptionValueForKey(@"managerName")])
        cell.backgroundColor = getAppDelegate().userBackground;
    else
        cell.backgroundColor = getAppDelegate().rowBackground;*/
    
    UIView *bView = [[UIView alloc] initWithFrame:cell.bounds];
    bView.backgroundColor = [UIColor colorWithRed:224/255.0 green:228/255.0 blue:240/255.0 alpha:1.0];
    cell.selectedBackgroundView = bView;
    
    // extend the separator to the left edge
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *expanded = [_sectionExpanded objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    [_sectionExpanded setObject:[NSNumber numberWithBool:![expanded boolValue]] forKey:[NSNumber numberWithInteger:indexPath.section]];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
