//
//  SideBetsViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 02/08/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "SideBetsViewController.h"
#import "TeamManager.h"
#import "Team.h"
#import "Util.h"

@interface SideBetsViewController ()

@property (nonatomic) NSArray *sideBets;
@end

@implementation SideBetsViewController

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
    
    self.tableView.rowHeight = 80;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.allowsSelection = NO;
    
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"side_bets" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    _sideBets = dict[@"sideBets"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) reloadData:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sideBets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sideBet" forIndexPath:indexPath];
    
    NSDictionary *sideBet = _sideBets[indexPath.row];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLenient:YES];
    [currencyFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [currencyFormatter setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
    [currencyFormatter setCurrencySymbol:@"£"];
    [currencyFormatter setNegativeFormat:[@"-" stringByAppendingString:[currencyFormatter positiveFormat]]];
    
    UILabel *amount = (UILabel *)[cell viewWithTag:1];
    amount.text = [currencyFormatter stringFromNumber:sideBet[@"amount"]];
    
    UILabel *name1 = (UILabel *)[cell viewWithTag:2];
    name1.text = sideBet[@"name1"];
    
    UILabel *name2 = (UILabel *)[cell viewWithTag:3];
    name2.text = sideBet[@"name2"];
    
    UILabel *betLabel = (UILabel *)[cell viewWithTag:6];
    NSString *bet = sideBet[@"bet"];
    betLabel.text = bet ? bet : @"";
    
    UILabel *vLabel = (UILabel *)[cell viewWithTag:8];
    vLabel.text = @"v";
    
    UILabel *bespokeLabel = (UILabel *)[cell viewWithTag:7];
    if (sideBet[@"name3"]) {
        name1.text = @"";
        name2.text = @"";
        vLabel.text = @"";
        bespokeLabel.text = [NSString stringWithFormat:@"%@   v   %@   v   %@", sideBet[@"name1"], sideBet[@"name2"], sideBet[@"name3"]];
        
        UIImageView *image1 = (UIImageView *)[cell viewWithTag:4];
        image1.image = [UIImage imageNamed:@"ipswich"];
        
        UIImageView *image2 = (UIImageView *)[cell viewWithTag:5];
        image2.image = [UIImage imageNamed:@"ipswich"];
    }
    else {
        bespokeLabel.text = @"";

        UIImageView *image1 = (UIImageView *)[cell viewWithTag:4];
        image1.image = [UIImage imageNamed:[name1.text lowercaseString]];
        
        UIImageView *image2 = (UIImageView *)[cell viewWithTag:5];
        image2.image = [UIImage imageNamed:[name2.text lowercaseString]];
        
        // whos is winning
        Team *team1 = [[TeamManager getInstance] getTeam:sideBet[@"managerName1"]];
        Team *team2 = [[TeamManager getInstance] getTeam:sideBet[@"managerName2"]];
        Team *team3 = [[TeamManager getInstance] getTeam:sideBet[@"managerName3"]];
        Team *winningTeam = [[TeamManager getInstance] whoIsWinningBetOfType:sideBet betweenTeam1:team1 team2:team2 team3:team3];
        if ([winningTeam.managerName isEqualToString:sideBet[@"managerName1"]]) {
            name1.textColor = getAppDelegate().goldText;
            //name1.font = [self font:name1.font withWeight:UIFontDescriptorTraitBold];
            //name1.font = [self font:name1.font withSize:17];
        }
        else {
            name1.textColor = [UIColor blackColor];
            //name1.font = [self font:name1.font withWeight:0];
            //name1.font = [self font:name1.font withSize:15];
        }
        
        if ([winningTeam.managerName isEqualToString:sideBet[@"managerName2"]]) {
            name2.textColor = getAppDelegate().goldText;
            //name2.font = [self font:name2.font withWeight:UIFontDescriptorTraitBold];
            //name2.font = [self font:name2.font withSize:17];
        }
        else {
            name2.textColor = [UIColor blackColor];
            //name2.font = [self font:name2.font withWeight:0];
            //name2.font = [self font:name2.font withSize:15];
        }
    }
    
    /*if ([team.managerName isEqualToString:getOptionValueForKey(@"managerName")])
        cell.backgroundColor = getAppDelegate().userBackground;
    else*/
        cell.backgroundColor = getAppDelegate().rowBackground;
    
    // extend the separator to the left edge
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
    
    return cell;
}

- (UIFont *) font:(UIFont *)font withWeight:(UIFontDescriptorSymbolicTraits) weight
{
    UIFontDescriptor *fontD = [font.fontDescriptor fontDescriptorWithSymbolicTraits:weight];
    return [UIFont fontWithDescriptor:fontD size:0];
}

- (UIFont *) font:(UIFont *)font withSize:(CGFloat) size
{
    UIFontDescriptor *fontD = [font.fontDescriptor fontDescriptorWithSize:size];
    return [UIFont fontWithDescriptor:fontD size:size];
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
