//
//  WhoAreYaViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 26/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "WhoAreYaViewController.h"
#import "Util.h"

@interface WhoAreYaViewController ()

@end

@implementation WhoAreYaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (row) {
        case 0: setOptionValueForKey(@"managerName", @"Mr C Attrill"); break;
        case 1: setOptionValueForKey(@"managerName", @"Mr P Attrill"); break;
        case 2: setOptionValueForKey(@"managerName", @"Mr J Appleby"); break;
        case 3: setOptionValueForKey(@"managerName", @"Mr C Cowpertwait"); break;
        case 4: setOptionValueForKey(@"managerName", @"Mr S Dowe"); break;
        case 5: setOptionValueForKey(@"managerName", @"Mr C Emmerson"); break;
        case 6: setOptionValueForKey(@"managerName", @"Mr C Foxall"); break;
        case 7: setOptionValueForKey(@"managerName", @"Mr J Free"); break;
        case 8: setOptionValueForKey(@"managerName", @"Mr P Gill"); break;
        case 9: setOptionValueForKey(@"managerName", @"Mr J Hitchins"); break;
        case 10: setOptionValueForKey(@"managerName", @"Mr T Lewis"); break;
        case 11: setOptionValueForKey(@"managerName", @"Mr D Lin"); break;
        case 12: setOptionValueForKey(@"managerName", @"Mr M Mitchell"); break;
        case 13: setOptionValueForKey(@"managerName", @"Mr P Pritchard"); break;
        case 14: setOptionValueForKey(@"managerName", @"Mr J Ransley"); break;
        case 15: setOptionValueForKey(@"managerName", @"Mr M Riley"); break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
    return 16;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow: (NSInteger) row forComponent: (NSInteger) component {
    switch (row) {
        case 0: return @"Mr C Attrill";
        case 1: return @"Mr P Attrill";
        case 2: return @"Mr J Appleby";
        case 3: return @"Mr C Cowpertwait";
        case 4: return @"Mr S Dowe";
        case 5: return @"Mr C Emmerson";
        case 6: return @"Mr C Foxall";
        case 7: return @"Mr J Free";
        case 8: return @"Mr P Gill";
        case 9: return @"Mr J Hitchins";
        case 10: return @"Mr T Lewis";
        case 11: return @"Mr D Lin";
        case 12: return @"Mr M Mitchell";
        case 13: return @"Mr P Pritchard";
        case 14: return @"Mr J Ransley";
        case 15: return @"Mr M Riley";
    }
    
    return nil;
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
