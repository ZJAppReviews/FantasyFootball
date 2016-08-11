//
//  TeamViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "LeagueViewController.h"
#import "TeamDetailViewController.h"
#import "LaunchScreenViewController.h"
#import "Team.h"
#import "TeamManager.h"
#import "SettingsManager.h"
#import "Month.h"
#import "Util.h"
#import "SoundEffect.h"
#import "SoundEffects.h"
#import <Crashlytics/Crashlytics.h>

@interface LeagueViewController () {
    BOOL taylorOnScreen, showNewWeekAlert;
}

@property (nonatomic, strong) NSMutableArray *teams;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, strong) LaunchScreenViewController *launchScreenVC;
@property (nonatomic) UIImageView *taylor;
@property (weak, nonatomic) SoundEffect	*taylorSound;

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
    
    if (getOptionValueForKey(@"managerName")) {
        taylorOnScreen = YES;
        self.launchScreenVC = [[LaunchScreenViewController alloc] initFromStoryboard:self.storyboard];
        
        UIView *v = _launchScreenVC.view;
        v.tag = 666;
        [self.view addSubview:v];
        
        _taylor = [v viewWithTag:1];
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        _taylorSound = [self randomTaylorSound];
        [_taylorSound play];
        
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:0
                         animations:^{
                             _taylor.alpha = 1.0;
                             _taylor.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.001, 0.001, 0.001);
                             CATransform3D scaleTransform = CATransform3DScale(_taylor.layer.transform, 1000, 1000, 1000);
                             _taylor.layer.transform = scaleTransform;
                         } completion:^(BOOL finished) {
                             [NSThread sleepForTimeInterval:1];
                             _taylor.tag = 20;
                             [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(removeWithSinkAnimationRotateTimer:) userInfo:nil repeats:YES];
                         }];
    }
}

- (SoundEffect *) randomTaylorSound {
    NSInteger index = arc4random_uniform(15);
    switch (index) {
        case 0: return canWeNotKnockItSound();
        case 1: return carltonStartedItSound();
        case 2: return disgracefulSound();
        case 3: return gottaGoBigSound();
        case 4: return hitLesSound();
        case 5: return iSweatALotSound();
        case 6: return ifYouWereOneOfMyPlayersSound();
        case 7: return madeForWrightySound();
        case 8: return plattySound();
        case 9: return sharpeySound();;
        case 10: return tuckInMoreSound();
        case 11: return weAreInTroubleSound();
        case 12: return youCannotWaitSound();
        case 13: return youKnowWeveBeenCheatedSound();
        case 14: return doINotLikeThatSound();
    }
    
    return nil;
}

- (void) removeWithSinkAnimationRotateTimer:(NSTimer*) timer {
    CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformScale(_taylor.transform, 0.8, 0.8),0.314 * 2);
    _taylor.transform = trans;
    _taylor.alpha = _taylor.alpha * 0.98;
    _taylor.tag = _taylor.tag - 1;
    if (_taylor.tag <= 0) {
        [timer invalidate];
        [[self.view viewWithTag:666] removeFromSuperview];
        self.edgesForExtendedLayout = UIRectEdgeAll;
        taylorOnScreen = NO;
        if (showNewWeekAlert) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showNewWeekAlert];
            });
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");
    if (!getOptionValueForKey(@"managerName")) {
        // need to show the screen to choose your name
        [self performSegueWithIdentifier:@"WhoAreYa" sender: self];
    }
    else {
        if (taylorOnScreen)
            showNewWeekAlert = YES;
        else
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
        
            if (!modalViewController) {
                if (taylorOnScreen)
                    showNewWeekAlert = YES;
                else
                    [self showNewWeekAlert];
            }
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
        
        int week = [getOptionValueForKey(@"week") intValue];
        int oldPosition = [getOptionValueForKey(@"position") intValue];
        int newPosition = [getOptionValueForKey(@"newPosition") intValue];
        
        NSString *subscript = (newPosition == 1) ? @"st" : (newPosition == 2) ? @"nd" : (newPosition == 3) ? @"rd" : @"th";
        NSString *title = [NSString stringWithFormat:@"%i%@ in the League", newPosition, subscript];
        NSString *message = nil;
        
        if (optionEnabled(@"motmWin")) {
            setOptionBoolForKey(@"motmWin", NO);
            title = @"Manager Of The Month";
            message = [NSString stringWithFormat:@"Congratulations! You are Manager Of The Month for %@. Slip a pair of Ladies into your back pocket.", ((Month *)[TeamManager getInstance].months[10 - [TeamManager getInstance].monthNumber]).monthName];
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
                    message = [NSString stringWithFormat:@"Mid table mediocrity looms, but safely above the Wooden Cock zone for now."];
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
                    @"Back of the net. Order a round of Jagerbombs!",
                    @"You've got to be hitting the target from there. And it looks like you did!",
                    @"He almost hit it too well there, Ray. Still went in the back of the net though!",
                    @"It’s just handbags Geoff. Not a yellow card for me.",
                    @"That Betting Ring is really starting to pay off.",
                    @"Keep taking that EPO and HGH."
                ];
                NSArray *topCliches = @[
                    @"Congratulations! The cream always rises and you just creamed yourself.",
                    @"Respect Blud! King of the Castle.",
                    @"Woo Hoo, You the Main Man! Double Jagerbombs all round."
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
                    @"It's a game of two halves apparently, which probably explains why you haven't moved an inch.",
                    @"They ran their socks off, but got nothing for it. Points shared!",
                    @"Some tired legs out there. Might explain why you are treading water.",
                    @"Stuck in a rut? Consult Andy Townsend for tactical inspiration.",
                    @"Not going anywhere fast? Consider a change of formation, throw on 4 strikers and hope for the best.",
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
                     @"Still propping up the table I'm afraid. Time to make a move (upwards).",
                     @"The Wooden Cock could be yours to keep this year.",
                     @"Maybe a different strategy is required. Give David Moyes a call.",
                     @"Time to buy the Unlimited Transfers In-App Purchase."
                ];
                
                if (newPosition == 16)
                    message = bottomCliches[arc4random_uniform((int) bottomCliches.count)];
                else if (newPosition == 1)
                    message = topCliches[arc4random_uniform((int) topCliches.count)];
                else
                    message = sameCliches[arc4random_uniform((int) sameCliches.count)];
            }
        }

        if (message) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                if (week > 1 && oldPosition > 0) {
                    if (oldPosition == newPosition) {
                        [self.tableView reloadData];
                    }
                    else {
                        [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:(oldPosition - 1) inSection:0] toIndexPath:[NSIndexPath indexPathForRow:(newPosition - 1) inSection:0]];
                        
                        // wait a bit for the row move animation to finish
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.6 * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }
            }];
            [alertController addAction:ok];
            
            if (!optionEnabled(@"testMode"))
                [self presentViewController:alertController animated:YES completion:nil];
            else
                [self.tableView reloadData];
        }
        else {
            [self.tableView reloadData];
        }
        
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
