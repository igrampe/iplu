//
//  UserData.h
//  iPlu
//
//  Created by Sema Belokovsky on 03.08.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kNotSaying = 0,
	kSingle,
	kMarried,
	kDivorced,
	kEngaged,
	kInRelationship,
	kComplicated,
	kWidowed,
	kUnstableRelationship,
	kOpenRelationship
} RelationshipType;

@interface UserData : NSObject {
	int ID;
	NSString *nickName;
	NSString *displayName;
	int hasProfileImage;
	NSString *avatar;
	NSString *location;
	NSString *defaultLang;
	NSString *dateOfBirth;
	int bdayPrivacy;
	NSString *fullName;
	int gender;
	NSString *pageTitle;
	float karma;
	int recruited;
	RelationshipType relationship;
}

@end
