//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Mahmood1 on 27. 01. 2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain () 
//@property (strong, nonatomic) NSMutableArray* operandStack;
@property (strong, nonatomic) NSMutableArray* programStack;
//@property (strong, nonatomic) NSSet* singleOperandOperations;
//@property (strong, nonatomic) NSSet* dualOperandOperations;
//@property (strong, nonatomic) NSSet* noOperandOperations;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
//@synthesize singleOperandOperations = _singleOperandOperations,
//dualOperandOperations = _dualOperandOperations, noOperandOperations = _noOperandOperations;

/*
 *** HELPER METHODS ***
*/

+ (BOOL) isVariable:(NSString*) programStackMember {
    // it's variable if it's not an operation
    return ![[self class] isOperation:programStackMember];
}

+ (BOOL) isSingleOperandOperation:(NSString *) programStackMember{
    NSSet* singleOperandOperations = [NSSet setWithObjects:@"sin", @"cos", @"sqrt", nil];
    return  [singleOperandOperations containsObject:programStackMember];
}

+ (BOOL) isDualOperandOperation:(NSString *) programStackMember{
    NSSet *dualOperandOperations = [NSSet setWithObjects:@"+", @"-", @"*", @"/", nil];
    return  [dualOperandOperations containsObject:programStackMember];
}

+ (BOOL) isNoOperandOperation:(NSString*) programStackMember {
    return [programStackMember isEqualToString:@"π"];
}

+ (BOOL) isLowerPrecedanceDualOperandOperation:(NSString *) operation {
    return ([operation isEqualToString:@"+"]||[operation isEqualToString:@"-"]);
}

+ (BOOL) isHigherPrecedanceDualOperandOperation:(NSString *) operation {
    return ([operation isEqualToString:@"*"]||[operation isEqualToString:@"/"]);
}

- (NSMutableArray*) programStack {
    
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}


- (id)program
{
    return [self.programStack copy];
}

+ (NSString *)descriptionOfTopStack:(NSMutableArray*)stack{
    NSString* result = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [(NSNumber*)topOfStack stringValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([self isNoOperandOperation:topOfStack] || [self isVariable:topOfStack]) {
            result = topOfStack;
        } else if ([self isSingleOperandOperation:topOfStack]) {
            result = [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopStack:stack]];
        } else if ([self isDualOperandOperation:topOfStack]) {
            NSString* secondOperand = [self descriptionOfTopStack:stack];
            NSString* firstOperand  = [self descriptionOfTopStack:stack];
            result = [NSString stringWithFormat:@"(%@ %@ %@)", firstOperand, topOfStack, secondOperand];             
        }
    }
    else {
        result = @"0";
    }
    
    return result;
}

+ (NSString *)descriptionOfTopStack:(NSMutableArray*)stack 
                 withOuterOperation:(NSString*)outerOperation{
    NSString* result = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [(NSNumber*)topOfStack stringValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([self isNoOperandOperation:topOfStack] || [self isVariable:topOfStack]) {
            result = topOfStack;
        } else if ([self isSingleOperandOperation:topOfStack]) {
            result = [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopStack:stack withOuterOperation:topOfStack]];
        } else if ([self isDualOperandOperation:topOfStack]) {
            NSString* secondOperand = [self descriptionOfTopStack:stack withOuterOperation:topOfStack];
            NSString* firstOperand  = [self descriptionOfTopStack:stack withOuterOperation:topOfStack];
            
            if (outerOperation) {
                if ([self isHigherPrecedanceDualOperandOperation:outerOperation]
                    &&
                    [self isLowerPrecedanceDualOperandOperation:topOfStack]
                    ) {
                    result = [NSString stringWithFormat:@"(%@ %@ %@)", firstOperand, topOfStack, secondOperand];                                 
                }                 
                else {
                    result = [NSString stringWithFormat:@"%@ %@ %@", firstOperand, topOfStack, secondOperand];             
                }
                
            } else {
                result = [NSString stringWithFormat:@"%@ %@ %@", firstOperand, topOfStack, secondOperand];             
            }

        }
    }
    else {
        result = @"0";
    }
    
    return result;
}


+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray* stack;
    
    NSString* programDescription = @"";
    
    if ([program isKindOfClass:[NSArray class]] ) {
        stack = [program mutableCopy];   
        programDescription = [self descriptionOfTopStack:stack withOuterOperation:nil];
        while (stack.count > 0) {
            programDescription = [NSString stringWithFormat:@"%@, %@", programDescription, [self descriptionOfTopStack:stack withOuterOperation:nil]];
        }

    }
    return programDescription;
}



- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] +
            [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] *
            [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        }        
        
        else if ([operation isEqualToString:@"sin"]){
            result = sin([self popOperandOffProgramStack:stack]);
        }
        else if ([operation isEqualToString:@"cos"]){
            result = cos([self popOperandOffProgramStack:stack]);
        }    
        else if ([operation isEqualToString:@"sqrt"]){
            result = sqrt([self popOperandOffProgramStack:stack]);
        }    
        else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }        
    

    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues{

    NSMutableArray* stack;
    NSString* stackMember;
    // get variables used in program
    NSSet* programVariables = [self variablesUsedInProgram:program];
    
    //if program uses variables and is array type, replace program variables with real values 
    if ([program isKindOfClass:[NSArray class]]&&programVariables&&variableValues) {
        stack = [program mutableCopy];

        for (int i = 0; i < stack.count; i++) {
            stackMember = [stack objectAtIndex:i];
            //if stack member is a variable
            if ([stackMember isKindOfClass:[NSString class]]&&![self isOperation:stackMember]) {
                
                //if stack member is a program variable replace it with real value if one is suplied
                if ([programVariables containsObject:stackMember])
                    [stack replaceObjectAtIndex:i withObject:[variableValues valueForKey:stackMember]];

            }
        }    

    }

    if (stack) {
        return [self runProgram:stack];
    } else {
        return [self runProgram:program];
    }
}


+ (NSSet *)variablesUsedInProgram:(id)program{
    NSMutableSet *variables;
    
    if ([program isKindOfClass:[NSArray class]]) {
        
        for (id operand in program) {
            //operand is variable if it's string that's not a operation
            if ([operand isKindOfClass:[NSString class]]&&![self isOperation:operand]) {

                if (!variables) variables = [NSMutableSet set];                
                [variables addObject:operand];
                
            }
        }
    }
    
    
    /*
    if (variables) {
        return [variables copy];
    } else {
        return nil;
    }
     */
    return [variables copy];
}


+ (BOOL)isOperation:(NSString*)operation{
    return (
            [operation isEqualToString:@"+"]||
            [operation isEqualToString:@"-"]||
            [operation isEqualToString:@"*"]||
            [operation isEqualToString:@"/"]||
            [operation isEqualToString:@"sin"]||
            [operation isEqualToString:@"cos"]||
            [operation isEqualToString:@"sqrt"]||
            [operation isEqualToString:@"π"]
           ) ;
}


- (double) popOperand {
    
    NSNumber* lastObjectOnStack = [self.programStack lastObject];
    // if last object on stack exists, remove it from stack
    // if we were dealing with empty stack lastObjectOnStack would be nil=false
    if (lastObjectOnStack) [self.programStack removeLastObject];
    return [lastObjectOnStack doubleValue];
    
}

- (void) pushOperand: (double) operand{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}


- (void) pushOperation: (NSString *) operation{
    [self.programStack addObject:operation];    
}

- (void) pushVariable: (NSString *) variable{
    [self.programStack addObject:variable];        
}

- (void) removeLastMember {
    if ([self.programStack lastObject]) [self.programStack removeLastObject];
}

/*
 
- (double) performOperation: (NSString *) operation{
    
    double result = 0;
    
    if ([operation isEqualToString:@"+"] ) {
        result = [self popOperand] + [self popOperand];
    }    
    else if ([@"*" isEqualToString:operation]){
        result = [self popOperand] * [self popOperand];
        
    } 
    else if ([@"-" isEqualToString:operation]){
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;        
    }    
    else if ([@"/" isEqualToString:operation]){
        double divisor = [self popOperand];
        if (divisor) result = [self popOperand] / divisor;        
    }      
    else if ([operation isEqualToString:@"sin"]){
        result = sin([self popOperand]);
    }
    else if ([operation isEqualToString:@"cos"]){
        result = cos([self popOperand]);
    }    
    else if ([operation isEqualToString:@"sqrt"]){
        result = sqrt([self popOperand]);
    }    
    else if ([operation isEqualToString:@"π"]) {
        result = M_PI;
    }
    else {
        result = 0;
    }
    
    [self pushOperand:result];
    
    return result;
}
*/

- (void) resetCalculator{
    [self.programStack removeAllObjects];
};

@end
