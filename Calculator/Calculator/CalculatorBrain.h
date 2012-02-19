//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Mahmood1 on 27. 01. 2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CalculatorBrain : NSObject

- (void) pushOperand: (double) operand;
- (double)performOperation: (NSString *) operation;
- (void) resetCalculator;
- (void) pushOperation: (NSString *) operation;
- (void) pushVariable: (NSString *) variable;
- (void) removeLastMember;

@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;


+ (NSSet *)variablesUsedInProgram:(id)program;
+ (BOOL)isOperation:(NSString*)operation;

@end
