//
//  AppSettingsHelper.h
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettingsHelper : NSObject

+ (void)saveAccessTokenKey:(NSString *)key andSecret:(NSString *)secret;
+ (NSString *)getAccessTokenKey;
+ (NSString *)getAccessTokenSecret;

@end
