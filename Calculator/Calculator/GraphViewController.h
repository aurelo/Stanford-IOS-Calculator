//
//  GraphViewController.h
//  Calculator
//
//  Created by Mahmood1 on 11. 02. 2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController <UISplitViewControllerDelegate, SplitViewBarButtonItemPresenter>

@property (nonatomic, strong) id calculatorProgram;

@end
