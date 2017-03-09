//
//  BubbleViewCP.m
//  MyMortgage
//
//  Created by Mark Riley on 16/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChartValues.h"
#import "CorePlot-CocoaTouch.h" 
#import "CoreGraphics.h"
#import "Util.h"

@implementation ChartValues

@synthesize values, colour;

-(id)initWithFrame:(CGRect)newFrame andValues:(NSArray *) v andColour:(UIColor *) c {
	if (self = [super initWithFrame:newFrame]) {
		self.transform = CGAffineTransformScale(self.transform, 1.0, -1.0);
		self.values = v;
		self.colour = c;
	}
	
	return self;
}

-(id)initWithFrame:(CGRect)newFrame andValues:(NSArray *) v {
	if (self = [super initWithFrame:newFrame]) {
		self.transform = CGAffineTransformScale(self.transform, 1.0, -1.0);
		self.values = v;
		self.colour = [UIColor colorWithRed:0.0 green:0.0 blue:0.6 alpha:1.0];
	}
	
	return self;
}

-(id)initWithFrame:(CGRect)newFrame {
	if (self = [super initWithFrame:newFrame]) {
		self.transform = CGAffineTransformScale(self.transform, 1.0, -1.0);
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

/*- (void)drawInContext:(CGContextRef)context {

}*/

- (void)drawRect:(CGRect)rect
//-(void)renderAsVectorInContext:(CGContextRef)context
{
	//[super renderAsVectorInContext:context];
	
	if (self.hidden)
		return;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// flip layer
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	CGFloat outerMargin = 5.0f;
	CGRect outerRect = CGRectInset(self.bounds, outerMargin, outerMargin);
	
	// set up some useful variables
	NSUInteger sections = [values count];
	CGRect glossRect = CGRectMake(outerRect.origin.x, outerRect.origin.y, outerRect.size.width, outerRect.size.height / 2);
	//UIBezierPath *glossPath = [UIBezierPath bezierPathWithRoundedRect:glossRect byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) 
	//												 cornerRadii:CGSizeMake(outerRect.size.height / 2, outerRect.size.height / 2)];
	CGPathRef glossPath = createRoundedRectForRectWithCorners(glossRect, outerRect.size.height / 2, outerRect.size.height / 2, 0, 0);
	//UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:outerRect cornerRadius:outerRect.size.height / 2];
	CGPathRef outerPath = createRoundedRectForRect(outerRect, outerRect.size.height / 2);
	
	// colours
	CGColorRef colours[sections][2];
    //colours[0][0] = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0].CGColor;
    colours[0][0] = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0].CGColor;
	colours[0][1] = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1.0].CGColor;
    if (sections > 1) {
        //colours[1][0] = [UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1.0].CGColor;
        colours[1][0] = [UIColor colorWithRed:0.2 green:0.9 blue:0.2 alpha:1.0].CGColor;
        colours[1][1] = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0].CGColor;
    }
	/*colours[0][0] = [UIColor colorWithRed:0.2 green:0.2 blue:0.8 alpha:1.0].CGColor;
	colours[0][1] = [UIColor colorWithRed:0.0 green:0.0 blue:0.6 alpha:1.0].CGColor;
    if (sections > 1) {
        colours[1][0] = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0].CGColor;
        colours[1][1] = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1.0].CGColor;
    }
    if (sections > 2) {
        colours[2][0] = [UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1.0].CGColor;
        colours[2][1] = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0].CGColor;
    }
    if (sections > 3) {
        colours[3][0] = [UIColor colorWithRed:0.9 green:0.5 blue:0.1 alpha:1.0].CGColor;
        colours[3][1] = [UIColor colorWithRed:0.8 green:0.3 blue:0.0 alpha:1.0].CGColor;
    }
    if (sections > 4) {
        colours[4][0] = [UIColor colorWithRed:0.85 green:0.85 blue:0.1 alpha:1.0].CGColor;
        colours[4][1] = [UIColor colorWithRed:0.8 green:0.8 blue:0.0 alpha:1.0].CGColor;
    }
	for (int i = 5; i < sections; i++) {
		colours[i][0] = [CPTPieChart defaultPieSliceColorForIndex:i - 1].cgColor;
		colours[i][1] = [CPTPieChart defaultPieSliceColorForIndex:i - 1].cgColor;
	}*/
	//CGColorRef glossTop = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5].CGColor;
	//CGColorRef glossBottom = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.15].CGColor;
	//CGColorRef shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5].CGColor;
	
	// draw shadow
	/*CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context,  [UIColor blackColor].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 3.0, shadowColor);
    CGContextAddPath(context, outerPath);
    CGContextFillPath(context);
    CGContextRestoreGState(context);*/
		
	// fill the sections
	for (int i = 0; i < sections; i++) {
		//UIBezierPath *path;
		CGPathRef path;
		CGRect rect = CGRectMake(outerRect.origin.x + ((outerRect.size.width / sections) * i), outerRect.origin.y, outerRect.size.width / sections, outerRect.size.height);
		
		if (sections == 1)
			//path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.height / 2];
			path = createRoundedRectForRect(rect, rect.size.height / 2);
		else if (i == 0)
			//path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerTopLeft) 
			//										 cornerRadii:CGSizeMake(rect.size.height / 2, rect.size.height / 2)];
			path = createRoundedRectForRectWithCorners(rect, rect.size.height / 2, 0, 0, rect.size.height / 2);
		else if (i == (sections - 1))
			//path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerTopRight) 
			//										 cornerRadii:CGSizeMake(rect.size.height / 2, rect.size.height / 2)];
			path = createRoundedRectForRectWithCorners(rect, 0, rect.size.height / 2, rect.size.height / 2, 0);
		else
			//path = [UIBezierPath bezierPathWithRect:rect];
			path = createPathForRect(rect);
													 
		CGContextSaveGState(context);
		CGContextAddPath(context, path);
		CGContextClip(context);
        //self.colour = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
        self.colour = [UIColor colorWithRed:0.85 green:0.2 blue:0.2 alpha:1.0];
		drawLinearGradient(context, rect, ((sections == 1) ? (colour == nil ? colours[i][0] : colour.CGColor) : colours[i][0]),  ((sections == 1) ? (colour == nil ? colours[i][0] : colour.CGColor) : colours[i][0]));
		CGContextRestoreGState(context);
		
		CFRelease(path);
	}
	
    // stroke path
    /*CGContextSaveGState(context);
    CGContextSetLineWidth(context, 1.0);
    //CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextAddPath(context, outerPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);*/

	// add a gloss
	/*CGContextSaveGState(context);
	CGContextAddPath(context, glossPath);
	CGContextClip(context);
	drawLinearGradient(context, glossRect, glossTop, glossBottom);
	CGContextRestoreGState(context);*/
	
	// extra shiny at the top
	/*CGContextSaveGState(context);
	CGContextAddPath(context, glossPath);
	CGContextClip(context);
	drawLinearGradientAtLocation(context, glossRect, glossTop, glossBottom, 0.0, 0.2);
	CGContextRestoreGState(context);*/
	
	// set up the text style
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color = [CPTColor whiteColor];
	textStyle.fontSize = 13.0f;
	textStyle.fontName = @"Helvetica-Bold";
	
	// write the text values
	for (int i = 0; i < sections; i++) {
		NSNumber *value = [values objectAtIndex:i];
		CGRect rect = CGRectMake(outerRect.origin.x, outerRect.origin.y, outerRect.size.width / sections, outerRect.size.height);
	
		//NSString *label = [getGraphAmountFormatter() stringForObjectValue:[NSNumber numberWithInt:round([value intValue])]];
        NSString *label = [[NSNumber numberWithInt:round([value intValue])] stringValue];

		/*if (sections == 1)
			point = CGPointMake(rect.size.width * i + ((rect.size.width - size.width) / 2) - 1, (rect.size.height - size.height) / 2 + 1);
		else if (i == 0)
			point = CGPointMake(rect.size.width * i + ((rect.size.width - size.width) / 2) - 1 - (self.bounds.origin.x - outerRect.origin.x), (rect.size.height - size.height) / 2 + 1);
		else if (i == (sections - 1))
			point = CGPointMake(rect.size.width * i + ((rect.size.width - size.width) / 2) - 1 + (self.bounds.origin.x - outerRect.origin.x), (rect.size.height - size.height) / 2 + 1);
		else
			point = CGPointMake(rect.size.width * i + ((rect.size.width - size.width) / 2) - 1, (rect.size.height - size.height) / 2 + 1);*/
		//[textLayer.text drawAtPoint:CPAlignPointToUserSpace(context, point) withTextStyle:textStyle inContext:context];
		
		UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
		CGFloat actualFontSize;
		[[UIColor whiteColor] set];
        CGSize size = getSizeOfText(label, font, 8, &actualFontSize, rect.size.width-5, NSLineBreakByClipping);
        //font = [UIFont fontWithName:@"Helvetica-Bold" size:actualFontSize];
		
        CGPoint point = CGPointMake(rect.size.width * i + (rect.size.width - size.width) / 2 + 5, (self.bounds.size.height - size.height) / 2);
		//[label drawAtPoint:CPAlignPointToUserSpace(context, point) forWidth:rect.size.width-5 withFont:font minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        //NSMutableParagraphStyle *paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        //paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        point = CPTAlignPointToUserSpace(context, point);
        //CGRect textRect = CGRectMake(point.x, point.y, rect.size.width-5, size.height);
        //[label drawInRect:textRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:[UIColor whiteColor]}];
        drawTextWithVariableSize(label, point, rect.size.width-5, font, actualFontSize, NSLineBreakByClipping);
	}
	
	CGContextRestoreGState(context);
	
	CGPathRelease(glossPath);
	CGPathRelease(outerPath);
}

@end
