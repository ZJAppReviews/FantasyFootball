//
//  BubbleViewCP.h
//  MyMortgage
//
//  Created by Mark Riley on 16/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "CorePlot-CocoaTouch.h"

//@interface ChartValues : CPLayer {
@interface ChartValues : UIView {
	NSArray *values;
	UIColor *colour;
}

@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) UIColor *colour;

-(id)initWithFrame:(CGRect)newFrame andValues:(NSArray *) values;
-(id)initWithFrame:(CGRect)newFrame andValues:(NSArray *) values andColour:(UIColor *) colour;

@end
