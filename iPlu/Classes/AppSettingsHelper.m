//
//  AppSettingsHelper.m
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "AppSettingsHelper.h"

#define AccessToken @"accessToken"
#define AccessTokenSecret @"accessTokenSecret"

@implementation AppSettingsHelper

+ (void)saveAccessTokenKey:(NSString *)key andSecret:(NSString *)secret
{
	[[NSUserDefaults standardUserDefaults] setObject:key forKey:AccessToken];
	[[NSUserDefaults standardUserDefaults] setObject:secret forKey:AccessTokenSecret];
}

+ (NSString *)getAccessTokenKey
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:AccessToken];
}

+ (NSString *)getAccessTokenSecret
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:AccessTokenSecret];
}


@end
