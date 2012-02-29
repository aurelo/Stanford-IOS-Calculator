//
//  CalculatorProgramsTableViewController.h
//  Calculator
//
//  Created by Zlatko Gudasic on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorProgramsTableViewController;

@protocol CalculatorProgramsTableViewControllerDelegate
@optional
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                                 choseProgram:(id)program;
@end

@interface CalculatorProgramsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray* programs;
@property (nonatomic, weak) id <CalculatorProgramsTableViewControllerDelegate> delegate;

@end
