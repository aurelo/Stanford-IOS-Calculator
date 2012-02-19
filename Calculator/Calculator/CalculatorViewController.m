//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Mahmood1 on 26. 01. 2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController()  
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (strong, nonatomic) CalculatorBrain* brain;



@end



@implementation CalculatorViewController

@synthesize display, userIsInTheMiddleOfEnteringANumber, brain = _brain;
@synthesize userInputSummary = _userInputSummary;
@synthesize variablesDisplay = _variablesDisplay;
@synthesize testVariableValuesDisplay = _testVariableValuesDisplay;
@synthesize testVariableValues = _testVariableValues;

int const TOTAL_NUM_OF_LETTERS = 30;

- (CalculatorBrain*) brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

/*
******   PRIVATE HELPER METHODS   ******
*/

- (void) displayReset {
    self.display.text =@"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
}


- (void) updateVariablesDisplay {
    self.variablesDisplay.text = @""; 
    NSNumber* variableValue;
    NSSet* variablesUsedInProgram = [CalculatorBrain variablesUsedInProgram:self.brain.program];

    
    if (variablesUsedInProgram) {
        
        for (NSString* programVariable in variablesUsedInProgram) {
            variableValue = [self.testVariableValues objectForKey:programVariable];
            if (variableValue) {
                self.variablesDisplay.text = [self.variablesDisplay.text stringByAppendingString:[NSString stringWithFormat:@" %@ = %@", programVariable, variableValue]];
            }
        }
       
    }

}

- (void) updateTestVariableValuesDisplay {
    
    self.testVariableValuesDisplay.text = @"";
    
    NSNumber* testVariableValue;
    
    for (NSString* testVariableKey in self.testVariableValues) {
        testVariableValue = [self.testVariableValues objectForKey:testVariableKey];
        self.testVariableValuesDisplay.text = [self.testVariableValuesDisplay.text stringByAppendingString:[NSString stringWithFormat:@" %@ = %@", testVariableKey, testVariableValue]];
    }
}

- (void) runProgram{
    double result = [CalculatorBrain runProgram:self.brain.program
                            usingVariableValues:self.testVariableValues];
    
    self.display.text = [NSString stringWithFormat:@"%g=", result];
    [self updateVariablesDisplay];
}


- (void) handleUserInputSummary: (NSString*) stringToAppend{
    //add space and then what user typed
//    self.userInputSummary.text = [self.userInputSummary.text stringByAppendingString:@" "];
//    self.userInputSummary.text = [self.userInputSummary.text stringByAppendingString:stringToAppend];
    
    // append only up to max number of characters
    NSUInteger strLength = self.userInputSummary.text.length;
    
    if (strLength > TOTAL_NUM_OF_LETTERS) 
           self.userInputSummary.text = [self.userInputSummary.text substringFromIndex:(strLength - TOTAL_NUM_OF_LETTERS)];
    
}


- (IBAction)enterPressed {
    // remainder - text doubleValue conversion will correctly convert "5=" to "5"
    // = is being added to result of operation
    [[self brain] pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userInputSummary.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];    
}

- (IBAction)resetCalculator {
    self.userInputSummary.text = @"";
    self.testVariableValues = nil;//[NSDictionary dictionaryWithObjectsAndKeys: nil];
    self.variablesDisplay.text = @"";
    self.testVariableValuesDisplay.text = @"";
    
    [self displayReset];
    
    // reset model
    [self.brain resetCalculator];
}

- (IBAction)backspacePressed {
    
    //allow backspacing only in the middle of entering a string
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        return;
    }
    

    //input summary has space between each character, so we delete two charcters from the end
    self.userInputSummary.text = [self.userInputSummary.text substringToIndex:(self.userInputSummary.text.length - 2)];
    
    if (self.display.text.length > 1) {
        self.display.text = [self.display.text substringToIndex:(self.display.text.length - 1)];

    }
    else {
        [self displayReset];
        //self.userInputSummary.text = @"";        
    }
}

- (IBAction)undoPressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self backspacePressed];
    } else {
        [self.brain removeLastMember];
        //TODO update display properly using descriptionOfProgram
        if (self.userInputSummary.text.length > 1) self.userInputSummary.text = [self.userInputSummary.text substringToIndex:(self.userInputSummary.text.length - 2)];
    }
}

- (IBAction)setTestVariables:(UIButton *)sender {
    
    NSString* key1 = @"x";
    NSString* key2 = @"a";
    NSString* key3 = @"b";    
    
    NSNull* nilObject = [NSNull null];
    
    if ([[sender currentTitle] isEqualToString:@"Test 1"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                    nilObject, key1
                                   ,nilObject, key2
                                   ,nilObject, key3
                                   , nil];
    }   else if ([[sender currentTitle] isEqualToString:@"Test 2"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithDouble:1], key1
                                   ,[NSNumber numberWithDouble:2], key2
                                   ,[NSNumber numberWithDouble:3], key3
                                   , nil];    
    }   else if ([[sender currentTitle] isEqualToString:@"Test 3"]) {
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithDouble:1.5], key1
                               ,[NSNumber numberWithDouble:100], key2
                               ,[NSNumber numberWithDouble:3.56], key3
                               , nil];    
}
    
    [self runProgram];
    [self updateTestVariableValuesDisplay];
    
}

- (IBAction)digitPressed:(UIButton*)sender {
    
    // if user types dot (.) and there's already a dot don't allow it
    NSRange dotRange = [self.display.text rangeOfString:@"."];
    BOOL digitPressedIsDot = [[sender currentTitle] isEqualToString:@"."];
    
    if ((digitPressedIsDot) && (dotRange.location != NSNotFound)){
        return;
    }
    
    if (userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:[sender currentTitle]];
    }
    else
    {
        
        // if user started entering string and the first letter is dot (.) append 0 in front
        if   (digitPressedIsDot) {
            self.display.text = @"0.";   
        }
        else {
            self.display.text = [sender currentTitle];
        }
        
        userIsInTheMiddleOfEnteringANumber = YES;
    }
    

}


- (IBAction)operationPressed:(UIButton*)sender {
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    NSString* operation = [sender currentTitle];
    
    // append user input to label displaying everything usery typed
    [self handleUserInputSummary:operation];

    // calculate result for pressed operation
    //double result = [self.brain performOperation:operation];
    
    [self.brain pushOperation:operation];
    self.userInputSummary.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];    
    
    [self runProgram];
}

- (IBAction)variablePressed:(UIButton*)sender {
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }    
    
    [self.brain pushVariable:[sender currentTitle]];
    self.userInputSummary.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];    

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showGraph"]) {
        //UIViewController *graphController = segue.destinationViewController;
        GraphViewController *graphController = segue.destinationViewController;
        graphController.program = self.brain.program;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setUserInputSummary:nil];
    [self setVariablesDisplay:nil];
    [self setTestVariableValuesDisplay:nil];
    [super viewDidUnload];
}
@end
