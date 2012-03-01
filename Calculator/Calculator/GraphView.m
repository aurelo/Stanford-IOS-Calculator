//
//  GraphXYView.m
//  Calculator
//
//  Created by Mahmood1 on 09. 02. 2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"
#import "CalculatorBrain.h"


@implementation GraphView

@synthesize scale = _scale, dataSource = _dataSource, origin = _origin;
@synthesize delegate = _delegate;
@synthesize drawingWithPoints = _drawingWithPoints;


#define DEFAULT_SCALE 30

-(CGFloat) scale {    
    if (!_scale) {
        return DEFAULT_SCALE;
    }    
    else {
        return _scale;        
    }

}

- (void) setScale:(CGFloat)scale {
    if (_scale != scale) {
        _scale = scale;
        [self setNeedsDisplay];        
    }
}



- (void) setOrigin:(CGPoint)origin {
    if (!CGPointEqualToPoint(_origin, origin)) {
        _origin = origin;
        [self setNeedsDisplay];
    }
}


- (void) setDrawingWithPoints:(BOOL)drawingWithPoints{
    if (
        (drawingWithPoints && !_drawingWithPoints)
        ||
        (!drawingWithPoints && _drawingWithPoints)
        ) {
        _drawingWithPoints = drawingWithPoints,
        [self setNeedsDisplay];
    }
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) setOriginInContext: (CGContextRef) context {
    UIGraphicsPushContext(context);
    CGPoint midPoint;
    
    midPoint.x = self.bounds.origin.x + self.bounds.size.width / 2;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height / 2;     
    
    // if origin is not set, set it to middle point
    // save origin to user defaults only if it's not yero or middle point
    if  (CGPointEqualToPoint(self.origin, CGPointZero) == YES) {
        self.origin = midPoint;
    }
    
    UIGraphicsPopContext();    
}

- (void) pinch: (UIPinchGestureRecognizer *) gesture{
    
    if (gesture.state == UIGestureRecognizerStateEnded||
        gesture.state == UIGestureRecognizerStateChanged) {
        
        self.scale *= gesture.scale;
        
        //save new scale to user defaults
        [self.delegate graphView:self saveScale:self.scale];    
        
        gesture.scale = 1;// reset gestures scale to 1 (so future changes are incremental, not cumulative)        
    }
}

- (void) tap: (UITapGestureRecognizer *) gesture{
    //NSLog(@"Tap recognized: gesture=%@", gesture);
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        self.origin = [gesture locationInView:self];
        
        //save new origin to user defaults        
        [self.delegate graphView:self saveOrigin:self.origin];     
        
    }
    
}

- (void) pan: (UIPanGestureRecognizer *) gesture {
//    NSLog(@"Tap recognized: gesture=%@", gesture);    
    if (gesture.state == UIGestureRecognizerStateEnded
        ||gesture.state == UIGestureRecognizerStateChanged
        ) {
      //  self.origin = [gesture translationInView:self];
        CGPoint translation = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x + translation.x/2, self.origin.y + translation.y/2);
        
        //save new origin to user defaults
        [self.delegate graphView:self saveOrigin:self.origin];     
        
        [gesture setTranslation:CGPointZero inView:self];
    }
}
 
- (void)drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    // set origin for graph, default origin is the view bounds mid point
    [self setOriginInContext:context];
    
    CGFloat size = self.bounds.size.width / 2;
    if (self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height / 2;
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];
    
    //temporary
    size *= self.scale; // scale is percentage of full view size
    
    // transalate x from 0 origin point to graph system
    CGFloat pointX  = self.bounds.origin.x - self.origin.x;
    CGFloat pointXCalculated = pointX/self.scale;
    
    
    CGFloat pointYCalculated = [self.dataSource calculateFunctionForX:pointXCalculated withSender:self];
    
    // get starting y from starting x
    CGFloat pointY = self.bounds.origin.y + self.origin.y - pointYCalculated*self.scale;

    CGContextBeginPath(context); 
    CGContextMoveToPoint(context, pointX, pointY);
    //loop through x and draw y
    for (int i = self.bounds.origin.x; i < self.bounds.size.width; i++) {
        
        pointX  = self.bounds.origin.x - self.origin.x + i;
        pointXCalculated = pointX / self.scale;
        
        pointYCalculated = [self.dataSource calculateFunctionForX:pointXCalculated withSender:self];
        
        pointY = pointYCalculated * self.scale;        

        if (self.drawingWithPoints) {
            CGContextAddArcToPoint(context, self.bounds.origin.x + i,self.bounds.origin.y + self.origin.y - pointY
                                   , self.bounds.origin.x + i,self.bounds.origin.y + self.origin.y - pointY,
                                   0);
        }
        else
        {
        CGContextAddLineToPoint(context, self.bounds.origin.x + i, self.bounds.origin.y + self.origin.y - pointY);            
        }

    }
    CGContextSetLineWidth(context, 3.0);
    [[UIColor greenColor] setStroke];
    CGContextDrawPath(context,kCGPathStroke);
    
}


- (BOOL) splitViewController:(UISplitViewController *)svc 
    shouldHideViewController:(UIViewController *)vc
               inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}

@end
