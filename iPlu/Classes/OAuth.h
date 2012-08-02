//
//  OAuth.h
//  iPlu
//
//  Created by Sema Belokovsky on 17.07.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OAuthURL @"http://www.plurk.com/OAuth/"

@interface OAuth : NSObject {
	NSString *m_requestTokenKey;
	NSString *m_requestTokenSecret;
	NSString *m_AccessTokenKey;
	NSString *m_AccessTokenSecret;
}

- (void)getRequestToken;
- (void)openAuthorizationURL;
- (void)getAccessToken;

@end
