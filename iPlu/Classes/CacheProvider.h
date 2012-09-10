//
//  CacheProvider.h
//  iPlu
//
//  Created by Semen Belokovsky on 12.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlurkConnector.h"
#import "UserData.h"
#import "PlurkData.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>

@protocol CacheDelegate <NSObject>

- (void)cacheUpdatedWithObject:(NSObject *)object;

@end

@interface CacheProvider : NSObject <PlurkConnectorDelegate, SDWebImageManagerDelegate> {
	NSMutableDictionary *m_plurks;
	NSMutableDictionary *m_users;
	NSMutableDictionary *m_parameters;
	id<CacheDelegate> m_delegate;
}

@property (nonatomic, assign) id<CacheDelegate> delegate;

+ (CacheProvider *)sharedInstance;

- (PlurkData *)getPlurkById:(NSString *)plurkId;
- (void)addPlurk:(PlurkData *)plurk byId:(NSString *)plurkId;
- (void)updateResponses:(NSArray *)plurksId;

- (UserData *)getUserById:(NSString *)userId;
- (void)addUser:(UserData *)user byId:(NSString *)userId;

- (UIImage *)getImageByLink:(NSString *)link;
- (void)addImage:(UIImage *)image byLink:(NSString *)link;
- (UIImage *)getImageByUserId:(NSString *)userId;
- (UIImage *)getImageByUser:(UserData *)user;



@end
