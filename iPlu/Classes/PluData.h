//
//  PluData.h
//  iPlu
//
//  Created by Sema Belokovsky on 03.08.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PluData : NSObject {
	NSString *plurkId;
	NSString *qualifier;
	NSString *qualifierTranslated;
	int isUnread;
	int userId;
	int ownerId;
	int posted;
	int noComments;
	NSString *content;
	NSString *contentRaw;
	int responseCount;
	NSArray *limitedTo;
	BOOL favorite;
	int favoriteCount;
	NSArray *favorers;
	BOOL replurkable;
	BOOL replurked;
	int replurkerId;
	int replurkersCount;
	NSArray *replurkers;
}

@end
