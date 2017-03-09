
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "CorePlot-CocoaTouch.h" 

@class SoundEffect;
@class IndicatorView;
@class PeriodSummary;
@class TeamChartsView;
@class Team;

@interface TeamCharts : UIViewController <UIScrollViewDelegate, UITabBarDelegate, CPTPlotDataSource, CPTPlotSpaceDelegate> {
    CPTScatterPlot *selectionPlot;
	CPTXYGraph *emptyGraph, *pointsChart, *goalsChart, *positionChart;
	NSMutableArray *dataForPosition, *dataForPoints, *dataForGoals;
	NSMutableDictionary *plotColours;
	NSTimer *snapshotTimer;
		
	int currentPlot;
	NSUInteger selectedIndex;
	CGFloat initialDistance, previousDistance, currentYMin;
	SoundEffect	*buttonSound;
}

@property (retain, nonatomic) NSMutableArray *dataForPosition, *dataForPoints, *dataForGoals;
@property (nonatomic, retain) NSDictionary *plotColours;
@property (nonatomic, retain) CPTScatterPlot *selectionPlot;
@property (nonatomic, retain) CPTXYGraph *emptyGraph, *pointsChart, *goalsChart, *positionChart;

@property (nonatomic, retain) Team *team;

- (void) reloadGraph;
- (CPTXYGraph *) createGraph:(CGFloat) paddingTop;
- (CPTXYGraph *) getGraph:(int) plotType;
- (CPTGraphHostingView *) getHostView;
- (TeamChartsView *) getMainView;
- (int) getMaxBars;

@end
