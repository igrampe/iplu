//
//  CacheProvider.m
//  iPlu
//
//  Created by Semen Belokovsky on 12.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import "CacheProvider.h"


#define AvatarServer @"http://avatars.plurk.com/"

@implementation CacheProvider (Private)

- (void)getResponses:(NSString *)plurkId fromResponse:(NSString *)fromResponse
{
	NSMutableDictionary *parameters = [[NSMutableDictionary new] autorelease];
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
	NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
	NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
	srand (time(NULL));
	NSString *onceString = [NSString stringWithFormat:@"%d",arc4random()%1000000000];
	[parameters setValue:onceString forKey:_oauth_nonce];
	[parameters setValue:timestampString forKey:_oauth_timestamp];
	[parameters setValue:APPKEY forKey:_oauth_consumer_key];
	[parameters setValue:_HMAC_SHA1 forKey:_oauth_signature_method];
	[parameters setValue:@"1.0" forKey:_oauth_version];
	[parameters setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:_oauth_token];
	[parameters setValue:plurkId forKey:_plurk_id];
	if (fromResponse) {
		[parameters setValue:fromResponse forKey:_fromResponse];
	}
	PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Responses_get];
	[[PlurkConnector sharedInstance] plurkCommand:command withParameters:parameters delegate:self];
}

@end

@implementation CacheProvider

@synthesize delegate = m_delegate;

static CacheProvider *m_sharedInstance;

+ (CacheProvider *)sharedInstance
{
	@synchronized(self) {
		if (m_sharedInstance == nil ) {
			[[self alloc] init];
		}
	}
	
	return m_sharedInstance;
}

- (id)init
{
	self = [super init];
	if (self) {
		m_parameters = [NSMutableDictionary new];
		m_users = [NSMutableDictionary new];
		m_plurks = [NSMutableDictionary new];
		m_sharedInstance = self;
	}
	return self;
}

#pragma mark - PlurkConnector Delegate

- (void)plurkCommand:(PlurkCommand *)command finishedWithResult:(NSDictionary *)result
{
	if ([command.command isEqualToString:APP_Timeline_getPlurk]) {
		PlurkData *plurk = [[PlurkData alloc] initWithDict:[result objectForKey:@"plurk"]];
		[self addPlurk:plurk byId:plurk.plurkId];
		[m_delegate cacheUpdatedWithObject:plurk];
	}
	if ([command.command isEqualToString:APP_Profile_getPublicProfile]) {
		UserData *user = [[UserData alloc] initWithDict:[result objectForKey:@"user_info"]];
		[self addUser:user byId:[user.userId stringValue]];
		[m_delegate cacheUpdatedWithObject:user];
	}
	if ([command.command isEqualToString:APP_Responses_get]) {
		
	}
}

- (void)plurkCommandFailed:(PlurkCommand *)command withErrorCode:(ErrorCode)code
{
	
}

#pragma mark - Actions

#pragma mark -- Plurks

- (PlurkData *)getPlurkById:(NSString *)plurkId
{
	PlurkData *plurk = [m_plurks objectForKey:plurkId];
	if (plurk == nil) {
		[m_parameters removeAllObjects];
		NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
		NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
		NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
		srand (time(NULL));
		NSString *onceString = [NSString stringWithFormat:@"%d",arc4random()%1000000000];
		[m_parameters setValue:onceString forKey:_oauth_nonce];
		[m_parameters setValue:timestampString forKey:_oauth_timestamp];
		[m_parameters setValue:APPKEY forKey:_oauth_consumer_key];
		[m_parameters setValue:_HMAC_SHA1 forKey:_oauth_signature_method];
		[m_parameters setValue:@"1.0" forKey:_oauth_version];
		[m_parameters setValue:plurkId forKey:_plurk_id];
		[m_parameters setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:@"oauth_token"];
		PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Timeline_getPlurk];
		[[PlurkConnector sharedInstance] plurkCommand:command withParameters:m_parameters delegate:self];
	}
	return plurk;
}

- (void)addPlurk:(PlurkData *)plurk byId:(NSString *)plurkId
{
	[m_plurks setValue:plurk forKey:plurkId];
}

- (void)updateResponses:(NSArray *)plurksId
{
	for (NSString *i in plurksId) {
		[self getResponses:i fromResponse:nil];
	}
}

#pragma mark -- Users

- (UserData *)getUserById:(NSString *)userId
{
	UserData *user = [m_users objectForKey:userId];
	if (user == nil) {
		[m_parameters removeAllObjects];
		NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
		NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
		NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
		srand (time(NULL));
		NSString *onceString = [NSString stringWithFormat:@"%d",arc4random()%1000000000];
		[m_parameters setValue:onceString forKey:_oauth_nonce];
		[m_parameters setValue:timestampString forKey:_oauth_timestamp];
		[m_parameters setValue:APPKEY forKey:_oauth_consumer_key];
		[m_parameters setValue:_HMAC_SHA1 forKey:_oauth_signature_method];
		[m_parameters setValue:@"1.0" forKey:_oauth_version];
		[m_parameters setValue:userId forKey:_user_id];
		[m_parameters setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:@"oauth_token"];
		PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Profile_getPublicProfile];
		[[PlurkConnector sharedInstance] plurkCommand:command withParameters:m_parameters delegate:self];
	}
	return user;
}

- (void)addUser:(UserData *)user byId:(NSString *)userId
{
	[m_users setObject:user forKey:userId];
}

#pragma mark -- Images

- (UIImage *)getImageByLink:(NSString *)link
{
	UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:link];
	if (image == nil) {
		if ([link isEqualToString:@"http://www.plurk.com/static/default_big.gif"]) {
			image = [UIImage imageNamed:@"default.gif"];
			[self addImage:image byLink:link];
		} else {
			[[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:link]
													  delegate:self];
		}
	}
	return image;
}

- (void)addImage:(UIImage *)image byLink:(NSString *)link
{
	
}

- (UIImage *)getImageByUserId:(NSString *)userId
{
	UIImage *image = [self getImageByUser:[self getUserById:userId]];
	return image;
}

- (UIImage *)getImageByUser:(UserData *)user
{
	UIImage *image = nil;
	if ([user.hasProfileImage intValue] == 1) {
		NSString *link = AvatarServer;
		if ([user.avatar isKindOfClass:[NSString class]]) {
			link  = [link stringByAppendingFormat:@"%@-big.jpg",user.userId];
		} else {
			link  = [link stringByAppendingFormat:@"%@-big%@.jpg",user.userId, user.avatar];
		}
		image = [self getImageByLink:link];
	} else {
		image = [self getImageByLink:@"http://www.plurk.com/static/default_big.gif"];
	}
	return image;
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image forURL:(NSURL *)url
{
	[m_delegate cacheUpdatedWithObject:image];
}

@end
