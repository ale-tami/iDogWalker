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


+ (instancetype) getInstance
{
    if (operations) {
        return operations;
    } else {
        
        return operations = [[self class] new];
    }
}

- (void) operationComplete:(NSObject *) objects withError:(NSError*) error;
{
    
}

@end
