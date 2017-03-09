
#import <UIKit/UIKit.h>

@class ChartValues;

@interface TeamChartsView : UIView {
	UISegmentedControl *switcher;
	ChartValues *valueAnnotation;
	UILabel *yearAnnotation;
	UIScrollView *legend;
}

@property (nonatomic, retain) UISegmentedControl *switcher;
@property (nonatomic, retain) ChartValues *valueAnnotation;
@property (nonatomic, retain) UILabel *yearAnnotation;
@property (nonatomic, retain) UIScrollView *legend;

@end
