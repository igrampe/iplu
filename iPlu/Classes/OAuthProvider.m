//
//  OAuthProvider.m
//  iPlu
//
//  Created by Sema Belokovsky on 17.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "OAuthProvider.h"
#import "OAHMAC_SHA1SignatureProvider.h"

#define APPKEY @"tG0lk2XlB63h"
#define APPSECRET @"Zgtcy0XOCSvPUcAHvF9fDfLfT7yOn48k"

@implementation OAuthProvider
@synthesize delegate = m_delegate;
@synthesize tokenKey = m_tokenKey;

static OAuthProvider *m_sharedInstance;


+ (OAuthProvider *)sharedInstance
{
	@synchronized(self) {
		if (m_sharedInstance == nil ) {
			[[self alloc] init];
		}
	}
	return m_sharedInstance;
}

- (id)init {
	self = [super init];
	if (self) {
		m_parameters = [NSMutableDictionary new];
		m_viewController = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
		m_viewController.delegate = self;
		m_sharedInstance = self;
	}
	return self;
}

- (void)getToken
{
	[((UIViewController *)m_delegate) presentModalViewController:m_viewController animated:YES];
	[self getRequestToken];
}

- (void)getRequestToken
{
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
	NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
	srand (time(NULL));
	NSString *onceString = [NSString stringWithFormat:@"%d",rand()%1000000000];
	[m_parameters setValue:onceString forKey:@"oauth_nonce"];
	[m_parameters setValue:timestampString forKey:@"oauth_timestamp"];
	[m_parameters setValue:@"tG0lk2XlB63h" forKey:@"oauth_consumer_key"];
	[m_parameters setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
	[m_parameters setValue:@"1.0" forKey:@"oauth_version"];
	PluCommand *command = [[PluCommand alloc] initWithString:@"OAuth/request_token"];
	[[PluConnector sharedInstance] pluCommand:command withParameters:m_parameters delegate:self];
}

- (void)resetToken
{
	[AppSettingsHelper saveAccessTokenKey:@"" andSecret:@""];
	[[PluConnector sharedInstance] setTokenKey:@""];
	[[PluConnector sharedInstance] setTokenSecret:@""];
	[((UIViewController *)m_delegate) presentModalViewController:m_viewController animated:YES];
	[self getRequestToken];
}

- (void)verifierObtained:(NSString *)oauth_verifier
{
	[m_parameters removeAllObjects];
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
	NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
	NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
	srand (time(NULL));
	NSString *onceString = [NSString stringWithFormat:@"%d",rand()%1000000000];
	[m_parameters setValue:@"tG0lk2XlB63h" forKey:@"oauth_consumer_key"];
	[m_parameters setValue:onceString forKey:@"oauth_nonce"];
	[m_parameters setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
	[m_parameters setValue:timestampString forKey:@"oauth_timestamp"];
	[m_parameters setValue:@"1.0" forKey:@"oauth_version"];
	[m_parameters setValue:[[PluConnector sharedInstance] tokenKey] forKey:@"oauth_token"];
	[m_parameters setValue:[[PluConnector sharedInstance] tokenSecret] forKey:@"oauth_token_secret"];
	[m_parameters setValue:oauth_verifier forKey:@"oauth_verifier"];
	PluCommand *command = [[PluCommand alloc] initWithString:@"OAuth/access_token"];
	[[PluConnector sharedInstance] pluCommand:command withParameters:m_parameters delegate:self];
}

- (void)pluCommand:(PluCommand *)command finishedWithResult:(NSDictionary *)result
{
	if ([command.command isEqualToString:@"OAuth/request_token"]) {
		[[PluConnector sharedInstance] setTokenKey:[result objectForKey:@"oauth_token"]];
		[[PluConnector sharedInstance] setTokenSecret:[result objectForKey:@"oauth_token_secret"]];
		NSLog(@"%@ %@",[[PluConnector sharedInstance] tokenKey], [[PluConnector sharedInstance] tokenSecret]);
		m_tokenKey = [[PluConnector sharedInstance] tokenKey];
		[m_viewController showLoginPage];
	}
	if ([command.command isEqualToString:@"OAuth/access_token"]) {
		NSLog(@"Token: %@", result);
		[[PluConnector sharedInstance] setTokenKey:[result objectForKey:@"oauth_token"]];
		[[PluConnector sharedInstance] setTokenSecret:[result objectForKey:@"oauth_token_secret"]];
		[AppSettingsHelper saveAccessTokenKey:[[PluConnector sharedInstance] tokenKey]
									andSecret:[[PluConnector sharedInstance] tokenSecret]];
		[m_viewController dismissModalViewControllerAnimated:YES];
		[m_delegate tokenObtained];
	}
}

- (void)pluCommandFailed:(PluCommand *)command withErrorCode:(ErrorCode)code
{
	NSLog(@"Command %@ failed with code %d", command.command, code);
}

@end
