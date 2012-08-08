//
//  OAuthLoginViewController.h
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@protocol LoginDelegate <NSObject>

- (void)verifierObtained:(NSString *)oauth_verifier;
@property (nonatomic, retain) NSString *tokenKey;

@end

@interface OAuthLoginViewController : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate> {
	MBProgressHUD *HUD;
	id<LoginDelegate> m_delegate;
}

@property (nonatomic, retain) IBOutlet UIWebView *pluWebView;
@property (nonatomic, assign) id<LoginDelegate> delegate;

- (void)showLoginPage;

@end
