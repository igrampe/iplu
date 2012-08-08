//
//  OAuthLoginViewController.m
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "OAuthLoginViewController.h"
#import "AppSettingsHelper.h"

@implementation OAuthLoginViewController
@synthesize pluWebView;
@synthesize delegate = m_delegate;

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
	HUD.delegate = self;
}

- (void)showLoginPage
{
	[self.pluWebView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[@"http://www.plurk.com/m/authorize?oauth_token=" stringByAppendingString:[m_delegate tokenKey]]]]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[HUD hide:YES afterDelay:0];
	NSString *codeText = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('oauth_verifier').innerHTML"];
	if ([codeText length] > 0) {
		NSLog(@"Verifier obtained: %@", codeText);
		[m_delegate verifierObtained:codeText];
	}
}

@end
