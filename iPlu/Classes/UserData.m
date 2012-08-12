//
//  UserData.m
//  iPlu
//
//  Created by Sema Belokovsky on 03.08.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "UserData.h"

@implementation UserData

@synthesize userId;
@synthesize nickName;
@synthesize displayName;
@synthesize hasProfileImage;
@synthesize avatar;
@synthesize location;
@synthesize defaultLang;
@synthesize dateOfBirth;
@synthesize bdayPrivacy;
@synthesize fullName;
@synthesize gender;
@synthesize pageTitle;
@synthesize karma;
@synthesize recruited;
@synthesize relationship;

- (id)initWithDict:(NSDictionary *)dict
{
	self = [super init];
	if (self) {
		userId = [dict objectForKey:@"id"];
		nickName = [dict objectForKey:@"nick_name"];
		displayName = [dict objectForKey:@"display_name"];
		hasProfileImage = [dict objectForKey:@"has_profile_image"];
		avatar = [dict objectForKey:@"avatar"];
		location = [dict objectForKey:@"location"];
		defaultLang = [dict objectForKey:@"default_lang"];
		dateOfBirth = [dict objectForKey:@"date_of_birth"];
		bdayPrivacy = [dict objectForKey:@"bday_privacy"];
		fullName = [dict objectForKey:@"full_name"];
		gender = [dict objectForKey:@"gender"];
		pageTitle = [dict objectForKey:@"page_title"];
		karma = [dict objectForKey:@"karma"];
		recruited = [dict objectForKey:@"recruited"];
		relationship = [dict objectForKey:@"relationship"];
	}
	return self;
}

- (NSString *)description
{
	return [userId stringValue];
}

- (void)dealloc
{
	userId = nil;
	nickName = nil;
	displayName = nil;
	hasProfileImage = nil;
	avatar = nil;
	location = nil;
	defaultLang = nil;
	dateOfBirth = nil;
	bdayPrivacy = nil;
	fullName = nil;
	gender = nil;
	pageTitle = nil;
	karma = nil;
	recruited = nil;
	relationship = nil;
	[super dealloc];
}

@end
