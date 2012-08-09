//
//  OAuthProvider.m
//  iPlu
//
//  Created by Sema Belokovsky on 17.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "OAuthProvider.h"
#import "OAHMAC_SHA1SignatureProvider.h"

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
	[m_parameters setValue:onceString forKey:_oauth_nonce];
	[m_parameters setValue:timestampString forKey:_oauth_timestamp];
	[m_parameters setValue:APPKEY forKey:_oauth_consumer_key];
	[m_parameters setValue:_HMAC_SHA1 forKey:_oauth_signature_method];
	[m_parameters setValue:@"1.0" forKey:_oauth_version];
	PlurkCommand *command = [[PlurkCommand alloc] initWithString:@"OAuth/request_token"];
	[[PlurkConnector sharedInstance] plurkCommand:command withParameters:m_parameters delegate:self];
}

- (void)resetToken
{
	[AppSettingsHelper saveAccessTokenKey:@"" andSecret:@""];
	[[PlurkConnector sharedInstance] setTokenKey:@""];
	[[PlurkConnector sharedInstance] setTokenSecret:@""];
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
	[m_parameters setValue:APPKEY forKey:_oauth_consumer_key];
	[m_parameters setValue:onceString forKey:_oauth_nonce];
	[m_parameters setValue:_HMAC_SHA1 forKey:_oauth_signature_method];
	[m_parameters setValue:timestampString forKey:_oauth_timestamp];
	[m_parameters setValue:@"1.0" forKey:_oauth_version];
	[m_parameters setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:@"oauth_token"];
	[m_parameters setValue:[[PlurkConnector sharedInstance] tokenSecret] forKey:@"oauth_token_secret"];
	[m_parameters setValue:oauth_verifier forKey:@"oauth_verifier"];
	PlurkCommand *command = [[PlurkCommand alloc] initWithString:@"OAuth/access_token"];
	[[PlurkConnector sharedInstance] plurkCommand:command withParameters:m_parameters delegate:self];
}

- (void)plurkCommand:(PlurkCommand *)command finishedWithResult:(NSDictionary *)result
{
	if ([command.command isEqualToString:@"OAuth/request_token"]) {
		[[PlurkConnector sharedInstance] setTokenKey:[result objectForKey:@"oauth_token"]];
		[[PlurkConnector sharedInstance] setTokenSecret:[result objectForKey:@"oauth_token_secret"]];
		m_tokenKey = [[PlurkConnector sharedInstance] tokenKey];
		[m_viewController showLoginPage];
	}
	if ([command.command isEqualToString:@"OAuth/access_token"]) {
//		NSLog(@"Token: %@", result);
		[[PlurkConnector sharedInstance] setTokenKey:[result objectForKey:@"oauth_token"]];
		[[PlurkConnector sharedInstance] setTokenSecret:[result objectForKey:@"oauth_token_secret"]];
		[AppSettingsHelper saveAccessTokenKey:[[PlurkConnector sharedInstance] tokenKey]
									andSecret:[[PlurkConnector sharedInstance] tokenSecret]];
		[m_viewController dismissModalViewControllerAnimated:YES];
		[m_delegate tokenObtained];
	}
}

- (void)plurkCommandFailed:(PlurkCommand *)command withErrorCode:(ErrorCode)code
{
	switch (code) {
		case kInvalidTimestamp:
			[self resetToken];
			break;
			
		default:
			break;
	}
	NSLog(@"Command %@ failed with code %d", command.command, code);
}

@end
