
#import "TeamCharts.h"
#import "CorePlot-CocoaTouch.h" 
#import "TeamChartsView.h"
#import "Util.h"
#import "UIBuilder.h"
#import "CGPointUtils.h"
#import "SoundEffect.h"
#import "ChartValues.h"
#import "Team.h"
#import "TeamWeek.h"
#import "TeamManager.h"

enum {
	kPosition = 0,
	kPoints,
	kGoals
};

@interface TeamCharts () {
    BOOL refreshOnView;
}

@property (nonatomic, retain) NSTimer *snapshotTimer;

@end

@implementation TeamCharts

@synthesize dataForPosition, dataForPoints, dataForGoals, plotColours;
@synthesize selectionPlot, snapshotTimer;
@synthesize emptyGraph, positionChart, pointsChart, goalsChart, team;

#define X_AXIS_LENGTH 410

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void) dismiss {
    dismissModalViewController(self, YES);
}

- (void)orientationChanged:(NSNotification *)notification {
	if (isIPad()) {
        return;
    }

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	
	if (deviceOrientation == UIInterfaceOrientationPortrait)
		[self performSelector:@selector(dismiss) withObject:nil afterDelay:0.2];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return isIPad() ? YES : (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return isIPad() ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskLandscape;
}

#pragma mark -
#pragma mark Create Graph

-(void)viewDidLoad 
{
    [super viewDidLoad];

	self.navigationItem.title = @"Charts";
	if (isIPad())
        self.edgesForExtendedLayout = UIRectEdgeNone;

	NSString *mode = getOptionValueForKey(@"chart_mode");
	if (mode == nil || [mode isEqualToString:@"Position"]) {
        currentPlot = kPosition;
    }
    else if ([mode isEqualToString:@"Points"])
        currentPlot = kPoints;
	else
		currentPlot = kGoals;
			
	selectedIndex = NSUIntegerMax;

	CPTGraphHostingView *hostView = [self getHostView];
    hostView.collapsesLayers = NO;
	hostView.allowPinchScaling = NO;

	// load the loan data upfront
	[self loadData];
		
	// create all plots upfront
    [self createGraphs];
	
	// Create a plot for the selection marker
	self.selectionPlot = [[CPTScatterPlot alloc] init];
    selectionPlot.identifier = @"Selection";
	selectionPlot.cachePrecision = CPTPlotCachePrecisionDouble;
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth = 2.0f;
	lineStyle.lineColor = [CPTColor colorWithComponentRed:0.95 green:0.7 blue:0.2 alpha:1.0];	
	selectionPlot.dataLineStyle = lineStyle;
    selectionPlot.dataSource = self;

	// setup plot space range
	[self setPlotRange:currentPlot forYears:0];

	TeamChartsView *mainView = [self getMainView];
    [self refreshSwitcher];
	switch (currentPlot) {
		case kGoals: 
            hostView.hostedGraph = goalsChart;
            break;
		case kPoints:
            hostView.hostedGraph = pointsChart;
            break;
		case kPosition:
            hostView.hostedGraph = positionChart;
            break;
	}

    goalsChart.title = @"Goals";
	pointsChart.title = @"Point";
    positionChart.title = @"Position";

    NSArray *defaultChartValues = [NSArray arrayWithObjects:[NSNull null], nil];
	mainView.valueAnnotation.values = defaultChartValues;
	
	// create legend at the top
	[self createLegend];
	[self getMainView].legend.hidden = YES;
	
	//buttonSound = clickSound();
    buttonSound = nil;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (BOOL) prefersStatusBarHidden {
    return !isIPad();
}

- (NSString *) getTitle:(int) plotType {
    switch (currentPlot) {
        case kPoints: return @"Points";
        case kGoals: return @"Goals";
        case kPosition: return @"Position";
    }

    return nil;
}

- (int) getMaxBars {
	return 50;
}
									
- (TeamChartsView *) getMainView {
    return (TeamChartsView *) self.view;
}

- (CPTGraphHostingView *) getHostView {
    return (CPTGraphHostingView *) [self.view viewWithTag:1];
}

- (void) reloadGraph {
    self.navigationItem.title = @"Charts";

    [self loadData];

    CPTXYAxis *x = ((CPTXYAxisSet *) [self getGraph:kPosition].axisSet).xAxis;
    x.labelFormatter = [NSNumberFormatter new];
    [x setNeedsRelabel];
    [self setPlotRange:currentPlot forYears:0];

    NSArray *data = dataForGoals;
    NSMutableArray *defaultChartValues = [NSMutableArray arrayWithCapacity:data.count];
    for (int i = 0; i < data.count; i++)
        [defaultChartValues addObject:[NSNull null]];
    [self getMainView].valueAnnotation.values = defaultChartValues;
    if (currentPlot == kPosition)
        [self getMainView].valueAnnotation.values = [NSArray arrayWithObjects:[NSNull null], nil];
    [self createLegend];
    
    // settings may have changed, so handle any layout changes
    [self getMainView].legend.hidden = YES;
    [self getMainView].valueAnnotation.frame = CGRectMake([self getMainView].valueAnnotation.frame.origin.x, 38, [self getMainView].valueAnnotation.frame.size.width, [self getMainView].valueAnnotation.frame.size.height);
    [self getMainView].yearAnnotation.frame = CGRectMake([self getMainView].yearAnnotation.frame.origin.x, 58, [self getMainView].yearAnnotation.frame.size.width, [self getMainView].yearAnnotation.frame.size.height);
    [self refreshSwitcher];
    [[self getMainView] setNeedsLayout];
    
    [[self getGraph:currentPlot].axisSet setNeedsDisplay];
    [[self getGraph:currentPlot] reloadData];

	goalsChart.title = nil;
	pointsChart.title = @"";
    positionChart.title = [self getTitle:currentPlot];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	if (refreshOnView) {
		[self reloadGraph];
	}
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void) createLegend {
	// legend container view
	UIScrollView *legend = [self getMainView].legend;
	legend.delegate = self;

	// remove any existing legend entries
	for (UIView *v in legend.subviews)
		[v removeFromSuperview];
	
	if ([self isScatter:currentPlot]) {
        UIColor *legendColour = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
        legendColour = [UIColor colorWithRed:0.2 green:0.9 blue:0.2 alpha:1.0];
        UIView *legView = newView(CGRectZero, legendColour, nil, 0, 3);
        legView.tag = ((0 * 2) + 1) + 1;
        UILabel *legLabel = newLabel(CGRectZero, @"Position", [UIFont systemFontOfSize:11], [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]);
        legLabel.lineBreakMode = NSLineBreakByClipping;
        legLabel.minimumScaleFactor = 9 / 11.0;
        legLabel.tag = ((0 * 2) + 1) + 2;
        [legend addSubview:legView];
        [legend addSubview:legLabel];
	}
	else {
        UIColor *legendColour = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
        legendColour = [UIColor colorWithRed:0.2 green:0.9 blue:0.2 alpha:1.0];
        UIView *legView = newView(CGRectZero, legendColour, nil, 0, 3);
        legView.tag = ((0 * 2) + 1) + 1;
        UILabel *legLabel = newLabel(CGRectZero, (currentPlot == kPoints ? @"Points" : @"Goals"), [UIFont systemFontOfSize:11], [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]);
        legLabel.lineBreakMode = NSLineBreakByClipping;
        legLabel.minimumScaleFactor = 9 / 11.0;
        legLabel.tag = ((0 * 2) + 1) + 2;
        [legend addSubview:legView];
        [legend addSubview:legLabel];
    }
	[[self getMainView] setNeedsLayout];
}

- (CPTXYGraph *) getGraph:(int) plotType {
    if (plotType < 0)
        plotType = currentPlot;
    
    switch (plotType) {
        case kPoints: return pointsChart;
        case kPosition: return positionChart;
        case kGoals: return goalsChart;
    }
	return nil;
}

- (BOOL) isScatter:(int)plotType {
	return plotType == kPosition;
}

- (void) createGraphs {
	self.emptyGraph = [self createGraph:0];
	[self createPositionPlots];
	[self createPointsPlots];
	[self createGoalsPlots];
}

- (CPTXYGraph *) createGraph:(CGFloat) paddingTop {
    // Create graph from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [newGraph applyTheme:theme];
	
	newGraph.defaultPlotSpace.allowsUserInteraction = YES;
	newGraph.defaultPlotSpace.delegate = self;

	newGraph.titleDisplacement = CGPointMake(0, -10);
    CPTMutableTextStyle *titleStyle = [[CPTMutableTextStyle alloc] init];
    titleStyle.fontSize = 16;
    titleStyle.color = [CPTColor whiteColor];
    newGraph.titleTextStyle = titleStyle;
    newGraph.paddingLeft = 10.0;
	//newGraph.paddingTop = paddingTop;
    newGraph.paddingTop = 10;
	newGraph.paddingRight = 10.0;
	newGraph.paddingBottom = 40.0;
    newGraph.plotAreaFrame.paddingTop = paddingTop;
    newGraph.plotAreaFrame.paddingBottom = 38.0;
    newGraph.plotAreaFrame.paddingLeft = 38.0;
    newGraph.plotAreaFrame.paddingRight = 0.0;
			
	// Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) newGraph.axisSet;
	CPTXYAxis *x = axisSet.xAxis;
	x.orthogonalPosition = @0;
	x.minorTicksPerInterval = 4;
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth = 0.75;
	lineStyle.lineColor = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:0.3 alpha:0.5];
    x.majorGridLineStyle = lineStyle;
	x.titleLocation = @7.5f;
	x.titleOffset = 12.0f;
	x.labelFormatter = [NSNumberFormatter new];
    x.labelRotation = M_PI_4;
	//x.labelOffset = 20.0;
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.fontSize = 11.0;
	textStyle.color = [CPTColor whiteColor];
	x.labelTextStyle = textStyle;
	
	CPTXYAxis *y = axisSet.yAxis;
	y.minorTicksPerInterval = 0;
	y.orthogonalPosition = @0;
	lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth = 0.75;
	lineStyle.lineColor = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:0.3 alpha:0.5];
    y.majorGridLineStyle = lineStyle;
	y.labelFormatter = [NSNumberFormatter new];

    return newGraph;
}

- (void) createPositionPlots {
	self.positionChart = [self createScatterPlots:kPosition];
	positionChart.defaultPlotSpace.identifier = @"Position";
}

- (void) createPointsPlots {
    self.pointsChart = [self createBarPlots:kPoints];
	pointsChart.defaultPlotSpace.identifier = @"Points";
}

- (void) createGoalsPlots {
	self.goalsChart = [self createBarPlots:kGoals];
	goalsChart.defaultPlotSpace.identifier = @"Goals";
}

- (CPTXYGraph *) createScatterPlots:(int) plotType {
    CPTXYGraph *newGraph = [self createGraph:45.0];

	// Setup plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) newGraph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;

    // Create a plot area for income
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
    plot.identifier = NSLocalizedString(@"Position", nil);
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 2.0f;
    //lineStyle.lineColor = [CPTColor colorWithComponentRed:0.2 green:0.85 blue:0.2 alpha:1.0];
    lineStyle.lineColor = [CPTColor colorWithComponentRed:0.85 green:0.2 blue:0.2 alpha:1.0];
    plot.dataLineStyle = lineStyle;
    plot.dataSource = self;
    plot.plotSymbolMarginForHitDetection = 7.0;
    //CPTColor *areaColor1 = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    //CPTColor *areaColor2 = [CPTColor clearColor];
    //CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:areaColor2];
    //areaGradient1.angle = -90.0f;
    //CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
    plot.areaFill = nil;
    //plot.areaFill2 = nil;
    plot.areaBaseValue = @0;
    plot.opacity = (plotType == currentPlot) ? 1.0 : 0.0;
    
    CPTColor *areaColor1 = [CPTColor colorWithComponentRed:1.0 green:0.3 blue:0.3 alpha:0.8];
    CPTColor *areaColor2 = [CPTColor colorWithComponentRed:1.0 green:0.3 blue:0.3 alpha:0.4];
    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:areaColor2];
    areaGradient1.angle = -90.0f;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
    plot.areaFill = areaGradientFill;
    plot.areaBaseValue = @1.75;
    
    [newGraph addPlot:plot];

	return newGraph;
}

- (CPTXYGraph *) createBarPlots:(int)plotType {
    CPTXYGraph *newGraph = [self createGraph:0.0];

	// Setup plot space
	//CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
	//plotSpace.allowsUserInteraction = YES;
	
	CPTBarPlot *plot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor whiteColor] horizontalBars:NO];
    plot.identifier = (plotType == kPoints) ? @"Points" : @"Goals";
	plot.dataSource = self;
	plot.baseValue = @0;
	plot.barCornerRadius = 5.0f;
	plot.barWidth = @0.65;
	plot.labelOffset = 1.5f;
	plot.plotRange = nil;
	plot.opacity = (plotType == currentPlot) ? 1.0 : 0.0;
	[newGraph addPlot:plot];
	
	return newGraph;
}

- (NSArray *) getMinMaxYForPlotType:(int) plotType  {
	double currMinYValue, currMaxYValue, minYValue = MAXFLOAT, maxYValue = 0;

    NSArray *data = [self getData:plotType];
    if (plotType == kPosition) {
        currMinYValue = 1;
        currMaxYValue = TeamManager.managerNames.count;
    }
    else {
        currMinYValue = 0;
        if (data.count > 0)
            currMaxYValue = [[data valueForKeyPath:@"@max.intValue"] doubleValue];
        else
            currMaxYValue = 100;
    }

    minYValue = (currMinYValue < minYValue) ? currMinYValue : minYValue;
    maxYValue = (currMaxYValue > maxYValue) ? currMaxYValue : maxYValue;

	return [NSArray arrayWithObjects:[NSNumber numberWithDouble:minYValue], [NSNumber numberWithDouble:maxYValue], nil];
}

- (void)setPlotRange:(int)plotType forYears:(float) years {
    NSArray *data = [self getData:plotType];
	
	// Setup plot space range
	double minX = 0, maxX;
	maxX = data.count;
	
    NSArray *minMaxY = [self getMinMaxYForPlotType:plotType];
	double minY = [[minMaxY objectAtIndex:0] doubleValue];
	double maxY = MIN(1000000000, [[minMaxY objectAtIndex:1] doubleValue] == 0 ? 100 : [[minMaxY objectAtIndex:1] doubleValue]);
    currentYMin = minY;

	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) [self getGraph:plotType].defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithDouble:minX] length:[NSNumber numberWithDouble:maxX]];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithDouble:minY] length:[NSNumber numberWithDouble:(maxY - minY) * ((plotType == kPosition) ? 1.05 : 1.35)]];
	
	// set up interval length for 'amount' axis
	CPTXYAxis *x = ((CPTXYAxisSet *) [self getGraph:plotType].axisSet).xAxis;
	CPTXYAxis *y = ((CPTXYAxisSet *) [self getGraph:plotType].axisSet).yAxis;
    
	x.orthogonalPosition = [NSNumber numberWithDouble:minY];
    if ([self isScatter:plotType]) {
        for (CPTScatterPlot *plot in [[self getGraph:plotType] allPlots])
            plot.areaBaseValue = [NSNumber numberWithDouble:minY];
    }

    x.visibleRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@3000.0];
    y.visibleRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithDouble:minY] length:[NSNumber numberWithDouble:(maxY - minY) * 1.2]];
    y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@3000.0];
    x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithDouble:minY] length:[NSNumber numberWithDouble:(maxY - minY) * 1.2]];
	
    NSUInteger interval = getYIntervalForChart(maxY);
    y.majorIntervalLength = [NSNumber numberWithUnsignedInteger:interval];
    x.majorIntervalLength = @1;
    x.minorTicksPerInterval = 0;
    x.labelExclusionRanges = [NSArray arrayWithObjects:[CPTPlotRange plotRangeWithLocation:@-0.1 length:@0.2],
                                                        [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithDouble:maxX-0.1] length:@100.0],
                                                        nil];
    
    x.labelingOrigin = [NSNumber numberWithDouble:0];
    
    if (plotType == kPosition && y.labelOffset != 5) {
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.fontSize = 12;
        textStyle.color = [CPTColor whiteColor];
        
        y.labelingPolicy = CPTAxisLabelingPolicyNone;
        
        NSMutableArray *xAxisLabels = [NSMutableArray array];
        for (int i = 0; i < TeamManager.managerNames.count; i++) {
            [xAxisLabels addObject:[NSString stringWithFormat:@"%lu", TeamManager.managerNames.count - i]];
        }
        
        NSUInteger labelLocation = 0;
        NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
        NSMutableArray *customTickLocations = [NSMutableArray array];
        for (int i = 0; i < [xAxisLabels count]; i++) {
            CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[xAxisLabels objectAtIndex:labelLocation++] textStyle:textStyle];
            newLabel.tickLocation = [NSNumber numberWithDouble:labelLocation];
            //newLabel.offset = 5;
            //newLabel.rotation = M_PI/4;
            [customLabels addObject:newLabel];
            [customTickLocations addObject:@(i+1)];
        } 
 
        y.majorTickLocations = [NSSet setWithArray:customTickLocations];
        y.axisLabels = [NSSet setWithArray:customLabels];
        y.labelOffset = 5;
    }
}

- (void) loadData {
    dataForPosition = [NSMutableArray arrayWithCapacity:team.weeks.count];
    dataForPoints = [NSMutableArray arrayWithCapacity:team.weeks.count];
    dataForGoals = [NSMutableArray arrayWithCapacity:team.weeks.count];
    [dataForPosition addObject:@0];
    [dataForPoints addObject:@0];
    [dataForGoals addObject:@0];
    
    for (TeamWeek *teamWeek in team.weeks) {
        [dataForPosition addObject:@(teamWeek.position)];
        [dataForPoints addObject:@(teamWeek.points)];
        [dataForGoals addObject:@(teamWeek.goals)];
    }
}

- (NSArray *) getData:(int) plotType {
    switch (plotType) {
        case kPosition: return dataForPosition;
        case kPoints: return dataForPoints;
        case kGoals: return dataForGoals;
    }
    return nil;
}

#pragma mark -
#pragma mark Switch Plots

- (NSArray *) scatterPlots {
	NSMutableArray *plots = [NSMutableArray arrayWithCapacity:4];

	for (CPTPlot *plot in [self getGraph:currentPlot].allPlots) {
		if (plot == selectionPlot)
			continue;

        [plots addObject:plot];
    }

	return plots;
}

- (NSArray *) plotsForPlotSpace:(int) plotType {
	NSMutableArray *plots = [NSMutableArray arrayWithCapacity:4];

	for (CPTPlot *plot in [self getGraph:plotType].allPlots) {
		if (plot == selectionPlot)
			continue;
		
        [plots addObject:plot];
    }

	return plots;
}

- (void) reloadCurrentPlots {
	if (currentPlot == kPoints || currentPlot == kGoals) return;

	for (CPTPlot *plot in [self plotsForPlotSpace:currentPlot])
		[plot reloadData];
}

- (NSUInteger) getCurrentMaxX {
	if (currentPlot == kPoints || currentPlot == kGoals) return 0;
	
	NSUInteger maxX = 0;
	for (CPTPlot *plot in [self plotsForPlotSpace:currentPlot]) {
		if (plot == selectionPlot)
			continue;
		
		maxX = [self numberOfRecordsForPlot:plot] > maxX ? [self numberOfRecordsForPlot:plot] : maxX;
	}
				
	return maxX;
}

- (NSUInteger) getCurrentMaxIntroX {
	if (currentPlot == kPoints || currentPlot == kGoals) return 0;
	
	NSUInteger maxX = 0;
	/*for (MyMortgage *mortgage in mortgages) {
		int introX = ([mortgage.initialTerm intValue] == 0) ? 0 : round([mortgage.initialTerm intValue] / 12.0);
		maxX = introX > maxX ? introX : maxX;
	}*/
				
	return maxX;
}

- (CPTPlot *) getCurrentMaxXPlot {
	if (currentPlot == kPoints || currentPlot == kGoals) return 0;

	CPTPlot *maxXPlot = nil;
	for (CPTPlot *plot in [self plotsForPlotSpace:currentPlot]) {
		if (plot == selectionPlot)
			continue;
		
		if (maxXPlot == nil)
			maxXPlot = plot;
		else if ([self numberOfRecordsForPlot:plot] >= [self numberOfRecordsForPlot:maxXPlot]) {
			if ([[self numberForPlot:plot field:CPTScatterPlotFieldX recordIndex:[self numberOfRecordsForPlot:plot] - 1] doubleValue] > [[self numberForPlot:maxXPlot field:CPTScatterPlotFieldX recordIndex:[self numberOfRecordsForPlot:maxXPlot] - 1] doubleValue])
				maxXPlot = plot;
		}
	}
	
	return maxXPlot;
}

- (NSArray *) getCurrentScatterData {
  	if (currentPlot == kPoints || currentPlot == kGoals) return nil;
	
	switch (currentPlot) {
		case kPosition: return dataForPosition;
	}
	
	return nil;
}

- (void) fadePlot: (CPTPlot *) plot toTransparent:(BOOL) transparent {
	plot.opacity = transparent ? 1.0 : 0.0;
	CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInAnimation.duration = 0.7f;
	fadeInAnimation.removedOnCompletion = NO;
	fadeInAnimation.fillMode = kCAFillModeForwards;
	fadeInAnimation.toValue = [NSNumber numberWithFloat:transparent ? 0.0 : 1.0];
	[plot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
}

- (void) position:(id) sender {
	float newRange = ((CPTXYPlotSpace *)[self getGraph:currentPlot].defaultPlotSpace).xRange.lengthDouble + ((CPTXYPlotSpace *) [self getGraph:currentPlot].defaultPlotSpace).xRange.locationDouble;
	switch (currentPlot) {
		case kPoints: 
			for (CPTPlot *plot in [self plotsForPlotSpace:kPoints])
				[self fadePlot:plot toTransparent:YES];
			newRange = 0;
			break;
		case kGoals: 
			for (CPTPlot *plot in [self plotsForPlotSpace:kGoals])
				[self fadePlot:plot toTransparent:YES];
			newRange = 0;
			break;
		case kPosition:
			return;
	}
	[buttonSound play];
	for (CPTPlot *plot in [self plotsForPlotSpace:kPosition])
		[self fadePlot:plot toTransparent:NO];
	currentPlot = kPosition;
    [self getGraph:currentPlot].title = [self getTitle:currentPlot];
	[self clearAnnotation];
	[self setPlotRange:currentPlot forYears:newRange];

	[self getHostView].hostedGraph = [self getGraph:currentPlot];
	
	for (CPTPlot *plot in [self plotsForPlotSpace:kPosition]) {
		//plot.delegate = self;
		[plot reloadData];
	}
    [self getMainView].valueAnnotation.values = [NSArray arrayWithObjects:[NSNull null], nil];

	[self createLegend];
	[self getMainView].legend.hidden = YES;

	setOptionValueForKey(@"chart_mode", @"Position");
}

- (void) points:(id) sender {
	switch (currentPlot) {
		case kPoints: return;
        case kGoals:
			for (CPTPlot *plot in [self plotsForPlotSpace:kGoals])
				[self fadePlot:plot toTransparent:YES];
			break;
		case kPosition: 
			for (CPTPlot *plot in [self plotsForPlotSpace:kPosition]) {
				[self fadePlot:plot toTransparent:YES];	
			}
			break;
	}
	[buttonSound play];
	for (CPTPlot *plot in [self plotsForPlotSpace:kPoints])
		[self fadePlot:plot toTransparent:NO];
	currentPlot = kPoints;
    [self getGraph:currentPlot].title = [self getTitle:currentPlot];
	[self clearAnnotation];
	[self setPlotRange:currentPlot forYears:0];

	[self getHostView].hostedGraph = pointsChart;

	for (CPTPlot *plot in [self plotsForPlotSpace:kPoints])
		[plot reloadData];
	[self getMainView].valueAnnotation.values = [NSArray arrayWithObjects:[NSNull null], nil];
	[self createLegend];
	[self getMainView].legend.hidden = YES;

	setOptionValueForKey(@"chart_mode", @"Points");
}

- (void) goals:(id) sender {
	switch (currentPlot) {
		case kGoals: return;
		case kPoints:
			for (CPTPlot *plot in [self plotsForPlotSpace:kPoints])
				[self fadePlot:plot toTransparent:YES];	
			break;
		case kPosition: 
			for (CPTPlot *plot in [self plotsForPlotSpace:kPosition]) {
				[self fadePlot:plot toTransparent:YES];	
			}
            break;
	}
	[buttonSound play];
	for (CPTPlot *plot in [self plotsForPlotSpace:kGoals])
		[self fadePlot:plot toTransparent:NO];
	currentPlot = kGoals;
    [self getGraph:currentPlot].title = [self getTitle:currentPlot];
	[self clearAnnotation];
    [self setPlotRange:currentPlot forYears:0];

	[self getHostView].hostedGraph = goalsChart;

	for (CPTPlot *plot in [self plotsForPlotSpace:kGoals])
		[plot reloadData];
	[self getMainView].valueAnnotation.values = [NSArray arrayWithObjects:[NSNull null], nil];
	[self createLegend];
	[self getMainView].legend.hidden = YES;

	setOptionValueForKey(@"chart_mode", @"Goals");
}

- (void) switcher:(id) sender {
	switch (((UISegmentedControl *) sender).selectedSegmentIndex) {
		case 0:
            [self position:nil]; break;
		case 1:
            [self points:nil]; break;
        case 2:
            [self goals:nil]; break;
	}
}

- (void) refreshSwitcher {
    switch (currentPlot) {
        case kPosition:
            [self getMainView].switcher.selectedSegmentIndex = 0;
            break;
        case kPoints:
            [self getMainView].switcher.selectedSegmentIndex = 1;
            break;
        case kGoals:
            [self getMainView].switcher.selectedSegmentIndex = 2;
            break;
    }
    [[self getMainView].switcher addTarget:self action:@selector(switcher:) forControlEvents:UIControlEventValueChanged];
    [[self getMainView] setNeedsLayout];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if ([(NSString *)plot.identifier isEqualToString:@"Selection"])
        return (selectedIndex < NSUIntegerMax) ? 3 : 0;
    
    return [dataForPosition count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
    NSArray *data = [self getData:currentPlot];
    NSNumber *num = [NSNumber numberWithDouble:0];
    
    if ([plot isKindOfClass:[CPTBarPlot class]]) {
        switch (fieldEnum) {
            case CPTBarPlotFieldBarLocation:
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
                break;
            case CPTBarPlotFieldBarTip:
                num = index == 0 ? nil : [data objectAtIndex:index];
                break;
        }
    }
    else if ([(NSString *)plot.identifier isEqualToString:@"Selection"]) {
        switch (fieldEnum) {
            case CPTScatterPlotFieldX: {
                num = [self numberForPlot:[self getCurrentMaxXPlot] field:CPTScatterPlotFieldX recordIndex:selectedIndex];
                break;
            }
            case CPTScatterPlotFieldY: {
                num = [NSNumber numberWithDouble:currentYMin];
                if (index == 1)
                    return num;
                
                if (data.count <= selectedIndex)
                    return num;
                
                //num = [data objectAtIndex:selectedIndex];
                num = @(TeamManager.managerNames.count + 1 - [[data objectAtIndex:selectedIndex] intValue]);
                if ([num intValue] == TeamManager.managerNames.count + 1)
                    num = @0;
                break;
            }
        }
    }
    else if ([(NSString *)plot.graph.defaultPlotSpace.identifier isEqualToString:@"Position"]) {
        switch (fieldEnum) {
            case CPTScatterPlotFieldX: {
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
                break;
            }
            case CPTScatterPlotFieldY: {
                if (index == 0 && fieldEnum == CPTScatterPlotFieldY)
                    return nil;
                
                num = @(TeamManager.managerNames.count + 1 - [[data objectAtIndex:index] intValue]);
                break;
            }
        }
    }

    return num;
}

- (CPTLayer *) dataLabelForPlot:(CPTBarPlot *)plot recordIndex:(NSUInteger) index {
    if (currentPlot == kPosition || index == 0)
        return nil;
    
    if ([[dataForPoints objectAtIndex:index] intValue] == 0)
        return nil;
    
    NSArray *data = [self getData:currentPlot];
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontSize = 10;
    textStyle.color = [CPTColor whiteColor];
    return [[CPTTextLayer alloc] initWithText:[[data objectAtIndex:index] stringValue] style:textStyle];
    
	return nil;
}

- (CPTFill *) barFillForBarPlot:(CPTBarPlot *) barPlot recordIndex:(NSUInteger) index {
	if (index == 0)
		return nil;
    
    NSArray *data = [self getData:currentPlot];
    
    double balance = [[data objectAtIndex:index] doubleValue];
	if (balance < 0.01)
		return nil;

    //CPTColor *areaColor1 = [[plotColours valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long) (index-1)]] valueForKey:@"barHigh"];
	//CPTColor *areaColor2 = [[plotColours valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long) (index-1)]] valueForKey:@"barLow"];
	
	//CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:[CPTColor greenColor] endingColor:[CPTColor greenColor]];
    
    CPTColor *barHigh = [CPTColor colorWithComponentRed:1.0 green:0.3 blue:0.3 alpha:1.0];
    CPTColor *barLow = [CPTColor colorWithComponentRed:1.0 green:0.3 blue:0.3 alpha:1.0];
    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:barHigh endingColor:barLow];
	areaGradient1.angle = -90.0f;
	return [CPTFill fillWithGradient:areaGradient1];
}

#pragma mark -
#pragma mark Plot Delegate Methods

-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)index {
    if ([(NSString *)plot.identifier isEqualToString:@"Position"]) {
        /*CPTPlotSymbol *symbol = [CPTPlotSymbol diamondPlotSymbol];
        symbol = [CPTPlotSymbol starPlotSymbol];
        symbol.size = CGSizeMake(8.0, 8.0);
        [symbol setFill:[CPTFill fillWithColor:[CPTColor redColor]]];
        //[symbol setFill:[CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.85 green:0.2 blue:0.2 alpha:1.0]]];
        
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineWidth = 1.0;
        lineStyle.lineColor = [CPTColor redColor];
        symbol.lineStyle = lineStyle;
        
        return symbol;*/
        return nil;
    }
    
	if (index == 1 || ![(NSString *)plot.identifier isEqualToString:@"Selection"])
		return nil;
	
    NSArray *data = [self getData:currentPlot];
	if (data.count <= selectedIndex)
		return nil;

	CPTPlotSymbol *symbol = [[CPTPlotSymbol alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeEllipse;
	
	symbol.size = CGSizeMake(14.0, 14.0);
	CPTGradient *gradientFill = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithComponentRed:1.0 green:1.0 blue:0.0 alpha:1.0] endingColor:[CPTColor colorWithComponentRed:0.7 green:0.4 blue:0.1 alpha:1.0]];
	gradientFill.gradientType = CPTGradientTypeAxial;
	gradientFill.angle = 315;
	symbol.fill = [CPTFill fillWithGradient:gradientFill];
	
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 0.5;
    lineStyle.lineColor = [CPTColor colorWithComponentRed:0.7 green:0.4 blue:0.1 alpha:1.0];
	symbol.lineStyle = lineStyle;
		
	return symbol;
}

- (void) clearAnnotation {
	TeamChartsView *mainView = [self getMainView];
	if (mainView.valueAnnotation) {
		if (!mainView.valueAnnotation.hidden) {

		}
		mainView.valueAnnotation.hidden = YES;
		mainView.yearAnnotation.hidden = YES;
	}
}

- (void) showAnnotationForRecordIndex:(float)index {
    if (index == 0)
        return;
    
    NSMutableArray *yValues = [NSMutableArray array];

    NSArray *data = [self getCurrentScatterData];
    [yValues addObject:[data objectAtIndex:index]];

	if ([self isScatter:currentPlot]) {
		switch (currentPlot) {
			case kPosition:
                [self getMainView].valueAnnotation.colour = [UIColor colorWithRed:0.0 green:0.0 blue:0.6 alpha:1.0];
                break;
		}
	}
	
	[self getGraph:currentPlot].title = nil;
	TeamChartsView *mainView = [self getMainView];
	mainView.valueAnnotation.values = yValues;
	[mainView.valueAnnotation setNeedsDisplay];
	
	NSString *text = [NSString stringWithFormat:@"Week %d", (int) index];
	mainView.yearAnnotation.text = text;
	
	mainView.valueAnnotation.hidden = NO;
	mainView.yearAnnotation.hidden = NO;
	
	//[mainView setNeedsDisplay];
	[mainView.valueAnnotation setNeedsDisplay];
	[mainView.yearAnnotation setNeedsDisplay];
}

-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy: (CGPoint)proposedDisplacementVector {
	return proposedDisplacementVector;
}

/*-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate {
    if (currentPlot != kPoints)
        return newRange;

	long maxX = [dataForPoints count] - [self getMaxBars];
	
    CPTPlotRange *amendedRange = newRange;
	if (((currentPlot == kPoints) && [dataForPoints count] < [self getMaxBars])) {
        amendedRange = [CPTPlotRange plotRangeWithLocation:@0 length:newRange.length];
        return amendedRange;
	}

	if (newRange.locationDouble < 0)
		amendedRange = [CPTPlotRange plotRangeWithLocation:@0 length:newRange.length];
	else if (newRange.locationDouble > maxX) {
		amendedRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithLong:maxX] length:newRange.length];
	}

	return amendedRange;
}*/

#pragma mark -
#pragma mark Pinch & Zoom, Hold & Drag

-(void)setSelectedIndexFromDouble:(double)newIndex {
    newIndex = MAX(0, newIndex);
	if (selectedIndex != newIndex) {
		if (newIndex < (NSUIntegerMax - 1)) {
			newIndex = round(newIndex);
			//NSLog(@"newIndex: %f, currentMaxX: %d", newIndex, [self getCurrentMaxX]);
			if (newIndex >= [self getCurrentMaxX])
				newIndex = [self getCurrentMaxX] - 1;
			
		}	

		//[slideSound play];
		selectedIndex = newIndex;
		//NSLog(@"selectedIndex: %d", selectedIndex);
		[selectionPlot reloadData];
	}
}

-(void)showSnapshotAtPoint:(NSNumber *) xNumber {
	NSDecimal plotPoint[2];
	float xValue = [xNumber floatValue] - [self getGraph:currentPlot].paddingLeft - [self getGraph:currentPlot].plotAreaFrame.paddingLeft;
	[[self getGraph:currentPlot].defaultPlotSpace plotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:CGPointMake(xValue, 0)];
	[self setSelectedIndexFromDouble:CPTDecimalDoubleValue(plotPoint[0])];
	
	[self showAnnotationForRecordIndex:selectedIndex];
}

-(void)showSnapshotWithTimer:(NSTimer *) timer {
	NSNumber *xNumber = [timer userInfo];
	[[self getGraph:currentPlot] addPlot:selectionPlot];
	[self showSnapshotAtPoint:xNumber];
	
	[self.snapshotTimer invalidate];
	self.snapshotTimer = nil;
}

- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)point {
	previousDistance = 0;
	
	if (self.snapshotTimer != nil) 
		[self.snapshotTimer invalidate];
	self.snapshotTimer = nil;

	if (selectedIndex < NSUIntegerMax) {
		selectedIndex = NSUIntegerMax;
		[[self getGraph:currentPlot] removePlot:selectionPlot];
		switch (currentPlot) {
			case kPoints:
                [self getGraph:currentPlot].title = @""; break;
			case kPosition: {
                [self getGraph:currentPlot].title = [self getTitle:currentPlot]; break;
            }
		}
		//[self getMainView].scatterToggle.hidden = ![self isScatter:currentPlot];
		[self clearAnnotation];
	}
		
	NSSet *touches = [event allTouches]; 
    if (((UITouch *)[touches anyObject]).tapCount == 2) { 
		if (currentPlot == kPoints || currentPlot == kGoals)
			return YES;
		
        [self setPlotRange:currentPlot forYears:0];
		[self reloadCurrentPlots];

		return NO; 
    }
	return YES;
} 

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)point 
{ 
	previousDistance = 0;
	if (selectedIndex < NSUIntegerMax)
		return NO;
	
    NSSet *touches = [event allTouches]; 
    if ([touches count] > 1) { 
        NSArray *twoTouches = [touches allObjects]; 
        UITouch *first = [twoTouches objectAtIndex:0]; 
        UITouch *second = [twoTouches objectAtIndex:1]; 
        initialDistance = distanceBetweenPoints([first locationInView:[self.view viewWithTag:1]], [second locationInView:[self.view viewWithTag:1]]); 
        previousDistance = initialDistance; 
        return NO; 
    } 
	else {
		if (currentPlot == kPoints || currentPlot == kGoals)
			return YES;
			
		[self clearAnnotation];
		
		if (self.snapshotTimer == nil)
			self.snapshotTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(showSnapshotWithTimer:) userInfo:[NSNumber numberWithFloat:point.x] repeats:NO];
	}

	return YES;
} 

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint: (CGPoint)point 
{ 
	if (currentPlot == kGoals || currentPlot == kPoints)
		return NO;

	if (self.snapshotTimer != nil)
		[self.snapshotTimer invalidate];
	self.snapshotTimer = nil;
	
    NSSet *touches = [event allTouches]; 
    if ([touches count] > 1) { 
		[self clearAnnotation];
		
        NSArray *twoTouches = [touches allObjects]; 
        UITouch *first = [twoTouches objectAtIndex:0]; 
        UITouch *second = [twoTouches objectAtIndex:1]; 
        CGFloat currentDistance = distanceBetweenPoints([first locationInView:[self.view viewWithTag:1]], [second locationInView:[self.view viewWithTag:1]]); 
		if (previousDistance == 0 || currentDistance == previousDistance) {
			previousDistance = currentDistance;
			return NO;
		}
		
		float pinchLength = fabs(previousDistance - currentDistance);
		BOOL expandRange = previousDistance > currentDistance;
		float xRangeLength = ((CPTXYPlotSpace *) space).xRange.lengthDouble + ((CPTXYPlotSpace *) space).xRange.locationDouble;
		
		float pinchFactor = pinchLength / X_AXIS_LENGTH;
		float xRangeAdjustment = xRangeLength * pinchFactor;
		xRangeAdjustment = expandRange ? xRangeAdjustment : xRangeAdjustment * -1;
		float newXRangeLength = fmax(3.1, xRangeLength + xRangeAdjustment);

		[self setPlotRange:currentPlot forYears:newXRangeLength];

		NSArray *allPlots = [self plotsForPlotSpace:currentPlot]; 
		for (CPTPlot *plot in allPlots) 
			[plot reloadData];
		
        previousDistance = currentDistance; 
        return NO; 
    } 
	else if (selectedIndex < NSUIntegerMax) {
		[self showSnapshotAtPoint:[NSNumber numberWithFloat:point.x]];
	}
	return NO;
} 

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(id)event {
	previousDistance = 0;
	
	if (self.snapshotTimer != nil) 
		[self.snapshotTimer invalidate];
	self.snapshotTimer = nil;
	
	if (selectedIndex < NSUIntegerMax) {
		selectedIndex = NSUIntegerMax;
		[[self getGraph:currentPlot] removePlot:selectionPlot];
		switch (currentPlot) {
			case kPoints:
                [self getGraph:currentPlot].title = @""; break;
			case kPosition: {
                [self getGraph:currentPlot].title = [self getTitle:currentPlot]; break;
            }
		}
		//[buttonSound play];
		//for (CPTPlot *plot in [self plotsForPlotSpace:kPosition])
		//	[self fadePlot:plot toTransparent:NO];
		
		//[self getMainView].scatterToggle.hidden = ![self isScatter:currentPlot];
		[self clearAnnotation];
	}
	
    return YES;
}

#pragma mark -
#pragma mark Destruction

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

