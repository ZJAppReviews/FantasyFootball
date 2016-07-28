//
//  WhoAreYaViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 26/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "WhoAreYaViewController.h"
#import "TeamManager.h"
#import "Util.h"

@interface WhoAreYaViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@end

@implementation WhoAreYaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (getOptionValueForKey(@"managerName"))
        [(UIPickerView *) _pickerView selectRow:[[TeamManager managerNames] indexOfObject:getOptionValueForKey(@"managerName")] inComponent:0 animated:NO];
    else {
        setOptionValueForKey(@"managerName", [TeamManager managerNames][0]);
        [[TeamManager getInstance] updatePosition:[TeamManager managerNames][0]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    setOptionValueForKey(@"managerName", [TeamManager managerNames][row]);
    [[TeamManager getInstance] updatePosition:[TeamManager managerNames][row]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
    return [TeamManager managerNames].count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow: (NSInteger) row forComponent: (NSInteger) component {
    return [TeamManager managerNames][row];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
