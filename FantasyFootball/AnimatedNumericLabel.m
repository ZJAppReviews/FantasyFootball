//
//  AnimatedUILabel.m
//  DebtManager
//
//  Created by Mark Riley on 22/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnimatedNumericLabel.h"
#import "Util.h"

@implementation AnimatedNumericLabel

@synthesize currentValue = _currentValue;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    _type = kCurrency;
    return self;
}

- (id)initWithFrame:(CGRect)frame andType:(int) type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _type = type;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _type = kPercentWith2DecimalPlaces;
    }
    return self;
}

- (void) updateText {
    if (_currentValue < _targetValue) {
        _currentValue = MIN(_currentValue + 1, _targetValue);
        
        self.text = [getCurrencyFormatter() stringFromNumber:[NSNumber numberWithDouble:MIN(_currentValue + 0.5, _targetValue)]];
    }
    else if (_currentValue > _targetValue) {
        _currentValue = MAX(_currentValue - 1, _targetValue);
        
        self.text = [getCurrencyFormatter() stringFromNumber:[NSNumber numberWithDouble:MAX(_currentValue - 0.5, _targetValue)]];
    }
    else {
        [_progressTimer invalidate];
        _progressTimer = nil;
        
        if ([_delegate respondsToSelector:@selector(labelAnimationComplete)])
            [_delegate labelAnimationComplete];
    }
}

- (void) setText:(double)value animated:(BOOL)animated
{
    if (animated)
	{
        _targetValue = value;
        if (_progressTimer == nil)
		{
            double absValue = ABS(value);
            double interval = (absValue < 10) ? 0.12 : (absValue < 25) ? 0.08 : (absValue < 50) ? 0.03 : 0.02;
            _progressTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateText) userInfo:nil repeats:YES];
        }
    }
	else
	{
        self.text = [getCurrencyFormatter() stringFromNumber:[NSNumber numberWithDouble:value]];
    }
}

- (void) dealloc {
    _delegate = nil;
}

@end
