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
@property (nonatomic, strong) NSMutableDictionary* sectionExpanded;

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
    //self.tableView.allowsSelection = NO;
    self.tableView.sectionHeaderHeight = 30;
    
    _months = [TeamManager getInstance].months;
    
    _sectionExpanded = [NSMutableDictionary new];
    for (NSInteger i = 0; i < _months.count; i++) {
        [_sectionExpanded setObject:@NO forKey:[NSNumber numberWithInteger:i]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // always 10 months in a season so use this to get the correct month considering they are listed in reverse order
    int monthNumber = [TeamManager getInstance].monthNumber;
    if (monthNumber > 0 && ((Month *)[TeamManager getInstance].months[10 - monthNumber]).managers.count > 0)
         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:(10 - monthNumber)] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)handleSectionHeaderTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        UIView *view = (UITableViewHeaderFooterView *) sender.view;
        NSNumber *expanded = [_sectionExpanded objectForKey:[NSNumber numberWithInteger:view.tag - 1]];
        [_sectionExpanded setObject:[NSNumber numberWithBool:![expanded boolValue]] forKey:[NSNumber numberWithInteger:view.tag - 1]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:view.tag - 1] withRowAnimation:UITableViewRowAnimationFade];
    }
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
    
    if (section > (10 - [TeamManager getInstance].monthNumber) && month.managers.count > 0)
        return [[_sectionExpanded objectForKey:[NSNumber numberWithInteger:section]] boolValue] ? month.managers.count : 1;
    
    return month.managers.count;
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
    Month *month = [_months objectAtIndex:section];
    return [[NSString stringWithFormat:@"     %@ (%@)", month.monthName, month.dateRange]  uppercaseString];
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
    
    if (indexPath.row == 0 && (indexPath.section > (10 - [TeamManager getInstance].monthNumber) ||
                                (indexPath.section == (10 - [TeamManager getInstance].monthNumber) && [[TeamManager getInstance] isLastWeekOfMonth])))
        cell.backgroundColor = [UIColor colorWithRed:255.0/255 green:215.0/255 blue:0 alpha:1.0];
    else if ([managerName isEqualToString:getOptionValueForKey(@"managerName")])
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *expanded = [_sectionExpanded objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    [_sectionExpanded setObject:[NSNumber numberWithBool:![expanded boolValue]] forKey:[NSNumber numberWithInteger:indexPath.section]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    
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
