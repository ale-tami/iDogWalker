//
//  DWOperations.h
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DWOperationsDelegate <NSObject>

- (void) operationComplete:(NSObject *) objects withError:(NSError*) error;


@end

@interface DWOperations : NSObject

+ (instancetype) getInstance;

@property id <DWOperationsDelegate> delegate;

@end
