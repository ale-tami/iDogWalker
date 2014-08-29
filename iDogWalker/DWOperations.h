//
//  DWOperations.h
//  iDogWalker
//
//  Created by Alejandro Tami on 26/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DWOperationsProtocol <NSObject>

+ (instancetype) sharedInstance;

@end

@protocol DWOperationsDelegate <NSObject>

- (void) operationCompleteFromOperation:(NSObject *) operation withObjects:(NSObject *) objects withError:(NSError*) error;

@end

@interface DWOperations : NSObject

+ (instancetype) sharedInstance;

@property id <DWOperationsDelegate> delegate;

@end
