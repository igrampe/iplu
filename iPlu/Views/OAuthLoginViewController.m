//
//  OAuthLoginViewController.m
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "OAuthLoginViewController.h"

@interface OAuthLoginViewController ()

@end

@implementation OAuthLoginViewController
@synthesize pluWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
	HUD.delegate = self;
	HUD.labelText = @"Loading";
	[self login];
}

- (void)login
{
	NSMutableDictionary *dict = [NSMutableDictionary new];
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
	NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
	[dict setValue:@"64654232" forKey:@"oauth_nonce"];
	[dict setValue:timestampString forKey:@"oauth_timestamp"];
	[dict setValue:@"tG0lk2XlB63h" forKey:@"oauth_consumer_key"];
	[dict setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
	[dict setValue:@"1.0" forKey:@"oauth_version"];
	PluCommand *command = [[PluCommand alloc] initWithString:@"OAuth/request_token"];
	[[PluConnector instance] pluCommand:command withParameters:dict delegate:self];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)pluCommand:(PluCommand *)command finishedWithResult:(NSDictionary *)result
{
	if ([command.command isEqualToString:@"OAuth/request_token"]) {
		[[PluConnector instance] setTokenKey:[result objectForKey:@"oauth_token"]];
		[[PluConnector instance] setTokenSecret:[result objectForKey:@"oauth_token_secret"]];
		NSLog(@"%@ %@",[[PluConnector instance] tokenKey], [[PluConnector instance] tokenSecret]);
		[self.pluWebView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[@"http://www.plurk.com/m/authorize?oauth_token=" stringByAppendingString:[[PluConnector instance] tokenKey]]]]];
	}
	if ([command.command isEqualToString:@"OAuth/access_token"]) {
		NSLog(@"Token: %@", result);
		[[PluConnector instance] setTokenKey:[result objectForKey:@"oauth_token"]];
		[[PluConnector instance] setTokenSecret:[result objectForKey:@"oauth_token_secret"]];
		[self dismissModalViewControllerAnimated:YES];
	}
	[HUD hide:YES afterDelay:2];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

	NSString *codeText = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('oauth_verifier').innerHTML"];
	if ([codeText length] > 0) {
		NSLog(@"YES! %@", codeText);
		m_oauth_verifier = codeText;
		
		NSMutableDictionary *dict = [NSMutableDictionary new];
		NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
		NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
		NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
		[dict setValue:@"tG0lk2XlB63h" forKey:@"oauth_consumer_key"];
		[dict setValue:@"64654232" forKey:@"oauth_nonce"];
		[dict setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
		[dict setValue:timestampString forKey:@"oauth_timestamp"];
		[dict setValue:@"1.0" forKey:@"oauth_version"];
		[dict setValue:[[PluConnector instance] tokenKey] forKey:@"oauth_token"];
		[dict setValue:[[PluConnector instance] tokenSecret] forKey:@"oauth_token_secret"];
		[dict setValue:m_oauth_verifier forKey:@"oauth_verifier"];
		PluCommand *command = [[PluCommand alloc] initWithString:@"OAuth/access_token"];
		[[PluConnector instance] pluCommand:command withParameters:dict delegate:self];
	} else {
		NSLog(@"NO!");
	}
}

- (void)pluCommandFailed:(PluCommand *)command
{
	NSLog(@"command %@ failed", command.command);
}

@end
