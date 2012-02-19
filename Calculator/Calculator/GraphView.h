//
//  GraphXYView.h
//  Calculator
//
//  Created by Mahmood1 on 09. 02. 2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource <NSObject>
- (CGFloat) calculateFunctionForX:(CGFloat)x withSender:(GraphView *) sender;
@end


@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

- (void) pinch: (UIPinchGestureRecognizer *) gesture; 
- (void) tap: (UITapGestureRecognizer *) gesture; 


@end
