//
//  GraphViewController.m
//  Calculator
//
//  Created by Mahmood1 on 11. 02. 2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"
#import "TitlePresenter.h"
#import "CalculatorProgramsTableViewController.h"

@interface GraphViewController () <GraphViewDataSource, CalculatorProgramsTableViewControllerDelegate, GraphViewDelegate>
  @property (nonatomic, weak) IBOutlet GraphView * graphView;
  @property (nonatomic, weak) IBOutlet UIToolbar *toolbar;        // to put splitViewBarButtonitem in
 // @property (strong, nonatomic) UIPopoverController *masterPopoverController;
 @property (weak, nonatomic) IBOutlet UILabel *descriptionOfProgram;
 @property (nonatomic) BOOL drawingWithPoints;

@end

@implementation GraphViewController
@synthesize descriptionOfProgram = _descriptionOfProgram;

@synthesize graphView = _graphView, calculatorProgram = _calculatorProgram;
@synthesize toolbar = _toolbar;

@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
//@synthesize masterPopoverController = _masterPopoverController;
@synthesize drawingWithPoints = _drawingWithPoints;


- (void) setDrawingWithPoints:(BOOL)drawingWithPoints{
    if (
        (drawingWithPoints && !_drawingWithPoints)
        ||
         (!drawingWithPoints && _drawingWithPoints)
        ) {
        _drawingWithPoints = drawingWithPoints,
        [self.graphView setNeedsDisplay];
    }
}


- (IBAction)pointLineSwitch:(UISwitch *)sender {
        self.drawingWithPoints = sender.on;
}



#define GRAPH_STATE_KEY @"com.example.graph.state"
#define GRAPH_STATE_SCALE @"scale"
#define GRAPH_STATE_ORIGIN_X @"originX"
#define GRAPH_STATE_ORIGIN_Y @"originY"

- (void) setGraphViewScaleAndOriginFromDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *graphState = [defaults objectForKey:GRAPH_STATE_KEY];
    if (graphState) {
        self.graphView.scale = [[graphState objectForKey:GRAPH_STATE_SCALE] floatValue];
        CGPoint defaultsOrigin;
        defaultsOrigin.x = [[graphState objectForKey:GRAPH_STATE_ORIGIN_X] floatValue];
        defaultsOrigin.y = [[graphState objectForKey:GRAPH_STATE_ORIGIN_Y] floatValue];
        self.graphView.origin = defaultsOrigin;
    }
}

- (void) zeroOutGraphView {
    self.graphView.origin = CGPointZero;
    self.graphView.scale  = 0; 
}


- (IBAction)switchGraphViewPointAndOrigin:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self setGraphViewScaleAndOriginFromDefaults];
    } else if(sender.selectedSegmentIndex == 1) {
        [self zeroOutGraphView];
    }
}



- (void) setCalculatorProgram:(id)program {
    if (_calculatorProgram != program) {
        _calculatorProgram = program;
        self.descriptionOfProgram.text = [CalculatorBrain descriptionOfProgram:_calculatorProgram];
        [self.graphView setNeedsDisplay];
    }
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}





-(void) setUp {
    
    self.title = [CalculatorBrain descriptionOfProgram:self.calculatorProgram];
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    tgr.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tgr];
    
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    self.graphView.dataSource = self;
    self.graphView.delegate = self;
    // setup graph view origin and scale from user defaults
    [self setGraphViewScaleAndOriginFromDefaults];
    
    self.splitViewController.delegate = self;
}

- (void)awakeFromNib  // always try to be the split view's delegate
{
    [super awakeFromNib];
    [self setUp];
    
}


- (void) setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    [self setUp];
}

- (CGFloat) calculateFunctionForX:(CGFloat)x withSender:(GraphView *) sender{
    
    return [CalculatorBrain runProgram:self.calculatorProgram usingVariableValues:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:x] forKey:@"x"]];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view
- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    
    
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;

}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    id master = [self.splitViewController.viewControllers objectAtIndex:0];
    
    if ([master conformsToProtocol:@protocol(TitlePresenter)]) {
        barButtonItem.title = [master returnTitle];
    }
    else
    {
        barButtonItem.title = @"Popup master";
    }

    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

#pragma mark - Actions
#define GRAPH_KEY @"com.example.graph.favorites"
- (IBAction)addToFavourites {
    
    // if program is not set return
    if (!self.calculatorProgram) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *favorites = [[defaults dictionaryForKey:GRAPH_KEY] mutableCopy];
    if (!favorites) favorites = [NSMutableDictionary dictionary];
    
    NSString * key = [CalculatorBrain descriptionOfProgram:self.calculatorProgram];
    NSArray * program = self.calculatorProgram;
    
    // if we dont already have graph saved on favorites
    if (![favorites objectForKey:key]){
        [favorites  setObject:program forKey:key];
        //NSDictionary *newFavorite = [NSDictionary dictionaryWithObject:program forKey:key];
        //[favorites addEntriesFromDictionary:newFavorite];
        [defaults setObject:favorites forKey:GRAPH_KEY];
        [defaults synchronize];
    }
}
#pragma mark - prepare for segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showFavorites"]) {
        NSDictionary * favorites = [[NSUserDefaults standardUserDefaults] objectForKey:GRAPH_KEY];
        CalculatorProgramsTableViewController *destinationVC = segue.destinationViewController;
        destinationVC.programs = [favorites allValues];
        destinationVC.delegate = self;
        
    }
}

#pragma mark - delegation protocols implementation
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                                 choseProgram:(id)program{
    self.calculatorProgram = program;
}
       


-(void) graphView:(GraphView *)sender saveOrigin:(CGPoint)origin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *graphState = [[defaults dictionaryForKey:GRAPH_STATE_KEY] mutableCopy];
    if (!graphState) graphState = [NSMutableDictionary dictionaryWithCapacity:3];
    [graphState setObject:[NSNumber numberWithFloat:origin.x] forKey:GRAPH_STATE_ORIGIN_X];
    [graphState setObject:[NSNumber numberWithFloat:origin.y] forKey:GRAPH_STATE_ORIGIN_Y];    
    [defaults setObject:graphState forKey:GRAPH_STATE_KEY];
    [defaults synchronize];
}

- (void) graphView:(GraphView *)sender saveScale:(CGFloat)scale {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *graphState = [[defaults dictionaryForKey:GRAPH_STATE_KEY] mutableCopy];
    if (!graphState) graphState = [NSMutableDictionary dictionaryWithCapacity:3];
    [graphState setObject:[NSNumber numberWithFloat:scale] forKey:GRAPH_STATE_SCALE];
    [defaults setObject:graphState forKey:GRAPH_STATE_KEY];
    [defaults synchronize];    
}



- (void)viewDidUnload {
    [self setDescriptionOfProgram:nil];
    [super viewDidUnload];
}
@end
