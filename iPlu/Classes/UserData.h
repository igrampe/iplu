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
	
}

@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSNumber *hasProfileImage;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *defaultLang;
@property (nonatomic, retain) NSString *dateOfBirth;
@property (nonatomic, retain) NSNumber *bdayPrivacy;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) NSNumber *gender;
@property (nonatomic, retain) NSString *pageTitle;
@property (nonatomic, retain) NSNumber *karma;
@property (nonatomic, retain) NSNumber *recruited;
@property (nonatomic, retain) NSNumber *relationship;

- (id)initWithDict:(NSDictionary *)dict;

@end
