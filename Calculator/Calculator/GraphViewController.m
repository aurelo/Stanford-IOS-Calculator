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

@interface GraphViewController () <GraphViewDataSource>
  @property (nonatomic, weak) IBOutlet GraphView * graphView;
@end

@implementation GraphViewController

@synthesize graphView = _graphView, program = _program;

- (void) setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    
    self.title = [CalculatorBrain descriptionOfProgram:self.program];
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    tgr.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tgr];
    
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    self.graphView.dataSource = self;
}

- (CGFloat) calculateFunctionForX:(CGFloat)x withSender:(GraphView *) sender{
    
    return [CalculatorBrain runProgram:self.program usingVariableValues:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:x] forKey:@"x"]];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
