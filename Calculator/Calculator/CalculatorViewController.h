//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Mahmood1 on 26. 01. 2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *userInputSummary;
@property (weak, nonatomic) IBOutlet UILabel *variablesDisplay;
@property (weak, nonatomic) IBOutlet UILabel *testVariableValuesDisplay;
@property (strong, nonatomic) NSDictionary *testVariableValues;

- (IBAction)digitPressed:(UIButton*)sender;
- (IBAction)operationPressed:(UIButton*)sender;
- (IBAction)variablePressed:(UIButton*)sender;
- (IBAction)enterPressed;
- (IBAction)resetCalculator;
- (IBAction)backspacePressed;
- (IBAction)undoPressed;
- (IBAction)setTestVariables:(UIButton *)sender;

@end
