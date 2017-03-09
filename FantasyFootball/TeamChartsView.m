
#import "TeamChartsView.h"
#import "ChartValues.h"
#import "UIBuilder.h"
#import "Util.h"

@implementation TeamChartsView

@synthesize switcher, valueAnnotation, yearAnnotation, legend;

- (id)initWithCoder:(NSCoder*)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
		self.switcher = newSegmentedControl(CGRectMake(50, 271, 300, 26), [NSArray arrayWithObjects:NSLocalizedString(@"Position", @""), NSLocalizedString(@"Points", @""), NSLocalizedString(@"Goals", @""), nil],
											[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0], -1, NO);
        self.switcher.tag = 1001;
		[self addSubview:switcher];

		self.valueAnnotation = [[ChartValues alloc] initWithFrame:CGRectMake(0, 0, 220, 30)];
		valueAnnotation.hidden = YES;
		[self addSubview:valueAnnotation];
		
		self.yearAnnotation = newLabel(CGRectMake(0, 0, 220, 30), @"", [UIFont fontWithName:@"Helvetica-Bold" size:12.0f], [UIColor grayColor]);
		yearAnnotation.hidden = YES;
		yearAnnotation.textAlignment = NSTextAlignmentCenter;
		[self addSubview:yearAnnotation];
		
		self.legend = newScrollView(CGRectMake(10, 4, 460, 26), [UIColor clearColor], [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], 4, 8);
		[self addSubview:legend];
    }
    return self;
}

- (void) refreshSwitcher:(BOOL) includeBudgets {
    UIView *view = [self viewWithTag:1001];
    [view removeFromSuperview];
    
    self.switcher = newSegmentedControl(CGRectMake(50, 271, 300, 26), [NSArray arrayWithObjects:NSLocalizedString(@"Categories", @""), NSLocalizedString(@"Cash Flow", @""), (includeBudgets ? NSLocalizedString(@"Budgets", @"") : nil), nil],
                                        [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0], -1, NO);
    self.switcher.tag = 1001;
    [self addSubview:switcher];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
    CGRect rect = self.bounds;
	
	CGFloat xOffset = (rect.size.width / 2) - (300 / 2);
	switcher.frame = CGRectMake(xOffset, rect.size.height - 33, switcher.frame.size.width, switcher.frame.size.height);
    
    NSUInteger count = [valueAnnotation.values count];
	CGFloat width = count == 2 ? 120 : count == 3 ? 160 : count == 3 ? 220 : MIN((isIPad() ? 550 : 350), (count * 60));
	xOffset = (rect.size.width / 2) - (width / 2);
	valueAnnotation.frame = CGRectMake(xOffset, 15, width, valueAnnotation.frame.size.height);
	
	xOffset = (rect.size.width / 2) - (yearAnnotation.frame.size.width / 2);
	yearAnnotation.frame = CGRectMake(xOffset, 15 + 20, yearAnnotation.frame.size.width, yearAnnotation.frame.size.height);
	
	// legends
	legend.frame = CGRectMake(10, 4, rect.size.width - 20, 26);
	
	xOffset = count >= 4 ? 5 : count == 3 ? 47 * (rect.size.width / 480.0) : count == 2 ? 90 * (rect.size.width / 480.0) : 190 * (rect.size.width / 480.0);
	CGFloat gap;
	if (!isIPad()) {
        gap = count >= 6 ? 75 * (rect.size.width / 480.0) : count == 5 ? 90 * (rect.size.width / 480.0) : count == 4 ? 116 * (rect.size.width / 480.0) : count == 3 ? 135 * (rect.size.width / 480.0): 184 * (rect.size.width / 480.0);
    }
	else if (isLandscape()) {
		gap = count >= 13 ? 75 : count == 12 ? 39 * (rect.size.width / 480.0) : count == 11 ? 42 * (rect.size.width / 480.0) : count == 10 ? 46 * (rect.size.width / 480.0) : count == 9 ? 51 * (rect.size.width / 480.0) : count == 8 ? 57 * (rect.size.width / 480.0) : count == 7 ? 65 * (rect.size.width / 480.0) : count == 6 ? 75 * (rect.size.width / 480.0) : count == 5 ? 90 * (rect.size.width / 480.0) : count == 4 ? 116 * (rect.size.width / 480.0) : count == 3 ? 135 * (rect.size.width / 480.0): 184 * (rect.size.width / 480.0);
    }
    else {
        gap = count >= 11 ? 75 : count == 10 ? 46 * (rect.size.width / 480.0) : count == 9 ? 51 * (rect.size.width / 480.0) : count == 8 ? 57 * (rect.size.width / 480.0) : count == 7 ? 65 * (rect.size.width / 480.0) : count == 6 ? 75 * (rect.size.width / 480.0) : count == 5 ? 90 * (rect.size.width / 480.0) : count == 4 ? 116 * (rect.size.width / 480.0) : count == 3 ? 135 * (rect.size.width / 480.0): 184 * (rect.size.width / 480.0);
    }
	
    if (!isIPad())
        legend.contentSize = CGSizeMake(count <= 6 ? (rect.size.width - 20) : count * 76 * (rect.size.width / 480.0), 26);
    else
        legend.contentSize = CGSizeMake(count <= 6 ? (rect.size.width - 20) : count * 76, 26);
	for (int i = 0; i < count; i++) {
		UIView *legView = [legend viewWithTag:((i * 2) + 1) + 1];
		UIView *legLabel = [legend viewWithTag:((i * 2) + 1) + 2];
		
		legView.frame = CGRectMake(xOffset, 6, 20, 14);
		legLabel.frame = CGRectMake(xOffset+25, 5, count >= 6 ? 45 : count == 5 ? 60 : count == 4 ? 90 : count == 3 ? 120 : 160, 16);
		
		xOffset += gap;
	}

    /*if (isIPad() && summary) {
        [mail removeFromSuperview];
        [self addSubview:mail];
    }*/
}

@end
