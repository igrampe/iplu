//
//  PlurkData.h
//  iPlu
//
//  Created by Sema Belokovsky on 03.08.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlurkData : NSObject {

}

@property (nonatomic, retain) NSString *plurkId;
@property (nonatomic, retain) NSString *qualifier;
@property (nonatomic, retain) NSString *qualifierTranslated;
@property (nonatomic, retain) NSNumber *isUnread;
@property (nonatomic, retain) NSNumber *plurkType;
@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSNumber *ownerId;
@property (nonatomic, retain) NSNumber *posted;
@property (nonatomic, retain) NSNumber *noComments;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *contentRaw;
@property (nonatomic, retain) NSNumber *responseCount;
@property (nonatomic, retain) NSNumber *responsesSeen;
@property (nonatomic, retain) NSArray *limitedTo;
@property (nonatomic, retain) NSNumber *favorite;
@property (nonatomic, retain) NSNumber *favoriteCount;
@property (nonatomic, retain) NSArray *favorers;
@property (nonatomic, retain) NSNumber *replurkable;
@property (nonatomic, retain) NSNumber *replurked;
@property (nonatomic, retain) NSNumber *replurkerId;
@property (nonatomic, retain) NSNumber *replurkersCount;
@property (nonatomic, retain) NSArray *replurkers;

- (id)initWithDict:(NSDictionary *)dict;

@end
