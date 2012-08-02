//
//  OAuthLoginViewController.h
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PluConnector.h"
#import "MBProgressHUD.h"

@interface OAuthLoginViewController : UIViewController <PluConnectorDelegate, UIWebViewDelegate, MBProgressHUDDelegate> {
	NSString *m_oauth_verifier;
	MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UIWebView *pluWebView;

@end
