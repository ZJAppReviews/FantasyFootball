//
//  AnimatedUILabel.h
//  DebtManager
//
//  Created by Mark Riley on 22/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    kPercentWith2DecimalPlaces = 0,
    kPercentWith1DecimalPlace,
    kPercentWithNoDecimalPlaces,
    kCurrency
};

@protocol AnimatedNumericLabelDelegate<NSObject>

@optional
- (void)labelAnimationComplete;

@end

@interface AnimatedNumericLabel : UILabel {
    NSTimer *_progressTimer;
    double _targetValue, _value, _currentValue;
    int _type;
}

- (id)initWithFrame:(CGRect)frame andType:(int) type;
- (void)setText:(double)value animated:(BOOL)animated;
- (void) setDelegate:(id<AnimatedNumericLabelDelegate>) delegate;

@property (nonatomic) double currentValue;
@property (nonatomic) id<AnimatedNumericLabelDelegate> delegate;

@end
