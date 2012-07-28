//
//  OAuthLoginViewController.m
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Nulana. All rights reserved.
//

#import "OAuthLoginViewController.h"

@interface OAuthLoginViewController ()

@end

@implementation OAuthLoginViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSMutableDictionary *dict = [NSMutableDictionary new];
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
	NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
	[dict setValue:@"75543842" forKey:@"oauth_nonce"];
	[dict setValue:timestampString forKey:@"oauth_timestamp"];
	[dict setValue:@"tG0lk2XlB63h" forKey:@"oauth_consumer_key"];
	[dict setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
	[dict setValue:@"1.0" forKey:@"oauth_version"];
	PluCommand *command = [[PluCommand alloc] initWithString:@"OAuth/request_token"];
	[[PluConnector instance] pluCommand:command withParameters:dict delegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)pluCommand:(PluCommand *)command finishedWithResult:(NSDictionary *)result
{
	NSLog(@"%@",result);
	if ([command.command isEqualToString:@"OAuth/request_token"]) {
//		[[PluConnector instance] setTokenKey:[result objectForKey:@"oauth_token"]];
//		[[PluConnector instance] setTokenSecret:[result objectForKey:@"oauth_token_secret"]];
//		NSLog(@"%@ %@",[[PluConnector instance] tokenKey], [[PluConnector instance] tokenSecret]);
	}
}

- (void)pluCommandFailed:(PluCommand *)command
{
	NSLog(@"command %@ failed", command.command);
}

@end
