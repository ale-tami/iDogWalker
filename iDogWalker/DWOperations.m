//
//  DWOperations.m
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "DWOperations.h"

@implementation DWOperations


static DWOperations *operations = nil;


+ (instancetype) sharedInstance
{
    if (operations) {
        return operations;
    } else {
        
        
//        operations = [NSClassFromString([[self class] description]) new];
//        return operations;
        
        return operations = [[self class] new];
    }
}

- (void) operationCompleteFromOperation:(DWOperations*) operation withObjects:(NSObject *) objects withError:(NSError*) error
{
    
}

@end
