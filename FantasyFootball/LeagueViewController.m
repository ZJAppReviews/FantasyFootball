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
#import "SettingsManager.h"
#import "Month.h"
#import "Util.h"
#import <Crashlytics/Crashlytics.h>

@interface LeagueViewController () {
}

@property (nonatomic, strong) NSMutableArray *teams;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

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
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.backBarButtonItem =	[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _teams = [TeamManager getInstance].league;
    [self setTitle];
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 2;
    [[_settingsButton valueForKey:@"view"] addGestureRecognizer:longPress];
    
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

- (void) setTitle {
    if ([TeamManager getInstance].year)
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - Week %i", (optionEnabled(@"testMode") ? @"Test Data" : [TeamManager getInstance].year), [TeamManager getInstance].weekNumber];
    else
        self.navigationItem.title = @"No Data";
}

- (void) reloadData:(NSNotification *)notification {
    NSLog(@"Refresh data");
    
    _teams = [TeamManager getInstance].league;
    [self setTitle];
    
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

- (void)handleLongPress:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        setOptionBoolForKey(@"testMode", !optionEnabled(@"testMode"));
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Info"
                                                                                 message:[NSString stringWithFormat:@"Test Mode: %@", optionEnabled(@"testMode") ? @"On" : @"Off"]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            dispatch_async(dispatch_get_main_queue(), ^{
                [SettingsManager loadSettings];
            });
        }];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
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
        
        if (optionEnabled(@"motmWin")) {
            setOptionBoolForKey(@"motmWin", NO);
            title = @"Manager Of The Month";
            message = [NSString stringWithFormat:@"Congratulation! You are Manager Of The Month for %@. Slip a pair of Ladies into your back pocket.", ((Month *)[TeamManager getInstance].months[10 - [TeamManager getInstance].monthNumber]).monthName];
        }
        else if (week == 1 || oldPosition == 0) {
            switch (newPosition) {
                case 1:
                    message = [NSString stringWithFormat:@"Back of the net, you're Top of the Pops!"];
                    break;
                case 2:
                case 3:
                case 4:
                case 5:
                    message = [NSString stringWithFormat:@"Top 5, you must be over the moon with that!"];
                    break;
                case 6:
                case 7:
                case 8:
                case 9:
                case 10:
                case 11:
                    message = [NSString stringWithFormat:@"Mid table mediocrity, but safely above the Wooden Cock zone for now."];
                    break;
                case 12:
                case 13:
                case 14:
                case 15:
                    message = [NSString stringWithFormat:@"Maybe you have just found it hard to settle into the pace of the Premier League."];
                    break;
                case 16:
                    message = [NSString stringWithFormat:@"You can't win the title in August, but you sure can lose it."];
                    break;
            }
            [self.tableView reloadData];
        }
        else if (newPosition > 0) {
            int movement = oldPosition - newPosition;
  
            NSString *places = abs(movement) > 1 ? @"places" : @"place";
            if (movement > 0) {
                NSArray *upCliches = @[
                    @"Heading in the right direction, Shooting for the stars, Dribbling in your sleep, you get the idea...",
                    @"Back of the net. Order a round of Jagermeisters!",
                    @"You've got to be hitting the target from there. And it looks like you did!",
                    @"He almost hit it too well there, Ray. Still went in the back of the net though!",
                    @"It’s just handbags Geoff. Not a yellow card for me.",
                    @"That Betting Ring is really starting to pay off.",
                    @"Keep taking that EPO and HGH."
                ];
                NSArray *topCliches = @[
                    @"Congratulations! The cream always rises and you just creamed yourself.",
                    @"Respect Blud! King of the Castle.",
                    @"Woo Hoo, You the Main Man! Double Jagermeisters all round."
                ];
                
                if (newPosition == 1)
                    message = topCliches[arc4random_uniform((int) topCliches.count)];
                else
                    message = [NSString stringWithFormat:@"%@ Up %i %@", upCliches[arc4random_uniform((int) upCliches.count)], movement, places];
            }
            else if (movement < 0) {
                NSArray *cliches = @[
                    @"The lads gave 110% but it just wasn't enough.",
                    @"You can blame it on Fergie Time if you like...",
                    @"Some schoolboy defending has cost you dear.",
                    @"Looks like you've lost the dressing room.",
                    @"Some real six pointers out there, and you lost them all.",
                    @"Looks like the performance enhancing drugs are starting to wear off.",
                    @"Mental fatigue must be setting in. Maybe have a spa day."
                ];
                
                if (newPosition == 16)
                    message = [NSString stringWithFormat:@"Ouch, you just sat on a Wooden Cock."];
                else
                    message = [NSString stringWithFormat:@"%@ Down %i %@", cliches[arc4random_uniform((int) cliches.count)], abs(movement), places];
            }
            else {
                NSArray *sameCliches = @[
                    @"It's a game of two halves, which probably explains why you haven't moved an inch.",
                    @"They ran their socks off, but got nothing for it. Points shared!",
                    @"Some tired legs out there. Might explain why you are treading water.",
                    @"Nothing to see here. Move along, move along.",
                    @"Cue tuneless whistling...",
                    @"Stuck in a rut? Consult Andy Townsend for tactical inspiration.",
                    @"Not going anywhere fast? Consider a change of formation, throw on 4 strikers and pray.",
                    @"Still in the same old position. Visit Mystic Meg for a change of fortune."
                ];
                NSArray *topCliches = @[
                     @"Still Top of the Pops, nice one son!",
                     @"Still King of the Castle, keep up the good work.",
                     @"Still Numero Uno, Booooooom!",
                     @"Still The Main Man, Chase Me, Chase Me...",
                     @"Still The Boss, keep those subordinates in order.",
                     @"Still Mr Big, Eat My Cheese!"
                ];
                NSArray *bottomCliches = @[
                     @"Still a Bottom Dweller, feeding off those above you.",
                     @"Remember those things called Transfers? Maybe time to use some...",
                     @"Still at the bottom rung of the ladder. Time to start climbing.",
                     @"Still propping up the table I'm afraid. Do you have a lot of Sunderland players?",
                     @"The Wooden Cock could be yours to keep this year.",
                     @"Maybe a different strategy is required. Give David Moyes a call.",
                     @"You may need some time away managing a team in the Saudi Arabian league to get your confidence back and get over the alcohol dependence.",
                     @"Time to invoke the Unlimited Transfers In-App Purchase."
                ];
                
                if (newPosition == 16)
                    message = bottomCliches[arc4random_uniform((int) bottomCliches.count)];
                else if (newPosition == 1)
                    message = topCliches[arc4random_uniform((int) topCliches.count)];
                else
                    message = sameCliches[arc4random_uniform((int) sameCliches.count)];
            }
        }

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:(oldPosition - 1) inSection:0] toIndexPath:[NSIndexPath indexPathForRow:(newPosition - 1) inSection:0]];
            
            // wait a bit for the row move animation to finish
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.6 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        [alertController addAction:ok];
        
        if (!optionEnabled(@"testMode"))
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

/*- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
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
}*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //[[Crashlytics sharedInstance] crash];
    
    if ([segue.identifier isEqualToString:@"WhoAreYa"] || [segue.identifier isEqualToString:@"Stats"])
        return;
    
    TeamDetailViewController *vc = [segue destinationViewController];
    
    Team *team = [_teams objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    vc.team = team;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
