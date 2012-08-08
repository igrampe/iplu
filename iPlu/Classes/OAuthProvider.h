//
//  OAuthProvider.h
//  iPlu
//
//  Created by Sema Belokovsky on 17.07.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthLoginViewController.h"
#import "AppSettingsHelper.h"
#import "PluConnector.h"

@protocol OAuthDelegate <NSObject>

- (void)tokenObtained;

@end

@interface OAuthProvider : NSObject <PluConnectorDelegate, LoginDelegate> {
	id<OAuthDelegate> m_delegate;
	OAuthLoginViewController *m_viewController;
	NSMutableDictionary *m_parameters;
	NSString *m_tokenKey;
}

@property (nonatomic, assign) id<OAuthDelegate> delegate;

+ (OAuthProvider *)sharedInstance;
- (void)resetToken;
- (void)getToken;

@end
