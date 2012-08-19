//
//  PlurkData.m
//  iPlu
//
//  Created by Sema Belokovsky on 03.08.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "PlurkData.h"

@implementation PlurkData 

@synthesize plurkId;
@synthesize qualifier;
@synthesize qualifierTranslated;
@synthesize isUnread;
@synthesize plurkType;
@synthesize userId;
@synthesize ownerId;
@synthesize posted;
@synthesize noComments;
@synthesize content;
@synthesize contentRaw;
@synthesize responseCount;
@synthesize responsesSeen;
@synthesize limitedTo;
@synthesize favorite;
@synthesize favoriteCount;
@synthesize favorers;
@synthesize replurkable;
@synthesize replurked;
@synthesize replurkerId;
@synthesize replurkersCount;
@synthesize replurkers;

- (id)initWithDict:(NSDictionary *)dict
{
	self = [super init];
	if (self) {
		plurkId = [dict objectForKey:@"plurk_id"];
		qualifier = [dict objectForKey:@"qualifier"];
		qualifierTranslated = [dict objectForKey:@"qualifier_translated"];
		isUnread = [dict objectForKey:@"is_unread"];
		plurkType = [dict objectForKey:@"plurk_type"];
		userId = [dict objectForKey:@"user_id"];
		ownerId = [dict objectForKey:@"owner_id"];
		posted = [dict objectForKey:@"posted"];
		noComments = [dict objectForKey:@"no_comments"];
		content = [dict objectForKey:@"content"];
		contentRaw = [dict objectForKey:@"content_raw"];
		responseCount = [dict objectForKey:@"response_count"];
		responsesSeen = [dict objectForKey:@"responses_seen"];
		limitedTo = [dict objectForKey:@"limited_to"];
		favorite = [dict objectForKey:@"favorite"];
		favoriteCount = [dict objectForKey:@"favorite_count"];
		favorers = [dict objectForKey:@"favorers"];
		replurkable = [dict objectForKey:@"replurkable"];
		replurked = [dict objectForKey:@"replurked"];
		replurkerId = [dict objectForKey:@"replurker_id"];
		replurkersCount = [dict objectForKey:@"replurkers_count"];
		replurkers = [dict objectForKey:@"replurkers"];
	}
	return self;
}

- (void)dealloc
{
	plurkId = nil;
	qualifier = nil;
	qualifierTranslated = nil;
	isUnread = nil;
	plurkType = nil;
	userId = nil;
	ownerId = nil;
	posted = nil;
	noComments = nil;
	content = nil;
	contentRaw = nil;
	responseCount = nil;
	responsesSeen = nil;
	limitedTo = nil;
	favorite = nil;
	favoriteCount = nil;
	favorers = nil;
	replurkable = nil;
	replurked = nil;
	replurkerId = nil;
	replurkersCount = nil;
	replurkers = nil;
	[super dealloc];
}

- (NSNumber *)timestamp
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
	NSDate *date = [dateFormatter dateFromString:posted];
	NSTimeInterval timeInterval = [date timeIntervalSince1970];
	NSNumber *timestamp = [NSNumber numberWithLong:timeInterval];
	return timestamp;
}

@end
