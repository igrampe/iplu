//
//  OAuth.m
//  iPlu
//
//  Created by Sema Belokovsky on 17.07.12.
//  Copyright (c) 2012 Nulana. All rights reserved.
//

#import "OAuth.h"
#import "OAHMAC_SHA1SignatureProvider.h"

#define APPKEY @"tG0lk2XlB63h"
#define APPSECRET @"Zgtcy0XOCSvPUcAHvF9fDfLfT7yOn48k"

@implementation OAuth

- (void)getRequestToken
{
	//NSTimeInterval timestampInterval = [[NSDate date] timeIntervalSince1970];
    //NSNumber *timestamp = [NSNumber numberWithDouble:timestampInterval];
	
	//NSString *hash = [OAHMAC_SHA1SignatureProvider signClearText:@"" withSecret:APPSECRET];
	//[ServerController sendRequest:@""];
}

- (void)openAuthorizationURL
{
	
}

- (void)getAccessToken
{
	
}

@end
