//
//  PlurkConnector.h
//  iPlu
//
//  Created by Sema Belokovsky on 23.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_Timeline_getPlurk @"APP/Timeline/getPlurk"
#define APP_Timeline_getPlurks @"APP/Timeline/getPlurks"
#define APP_Timeline_getPublicPlurks @"APP/Timeline/getPublicPlurks"

#define APP_Profile_getPublicProfile @"APP/Profile/getPublicProfile"
#define APP_Profile_getOwnProfile @"APP/Profile/getOwnProfile"

#define OAuth_access_token @"OAuth/access_token"
#define OAuth_request_token @"OAuth/request_token"

#define APPKEY @"tG0lk2XlB63h"
#define APPSECRET @"Zgtcy0XOCSvPUcAHvF9fDfLfT7yOn48k"
#define _oauth_signature_method @"oauth_signature_method"
#define _HMAC_SHA1 @"HMAC-SHA1"
#define _oauth_nonce @"oauth_nonce"
#define _oauth_consumer_key @"oauth_consumer_key"
#define _oauth_version @"oauth_version"
#define _oauth_timestamp @"oauth_timestamp"
#define _oauth_verifier @"oauth_verifier"
#define _oauth_token @"oauth_token"
#define _oauth_token_secret @"oauth_token_secret"
#define _plurk_id @"plurk_id"
#define _user_id @"user_id"
#define _offset @"offset"
#define _limit @"limit"

#define _parameters @"parameters"
#define _command @"command"
#define _filter @"filter"
#define _favorersDetail @"favorersDetail"
#define _replurkersDetail @"replurkersDetail"
#define _limitedDetail @"limitedDetail"

#define _connection @"connection"
#define _result @"result"
#define _errorCode @"errorCode"

typedef enum {
	kHTMLError = 0,
	kInvalidToken = 1,
	kBadRequest = 400,
	kInvalidTimestamp = 40004,
	kInvalidAccesToken = 40106
} ErrorCode;

@interface PlurkCommand : NSObject

@property (nonatomic, retain) NSString *command;
@property (nonatomic, assign) NSString *method;

- (id)initWithString:(NSString *)string;

@end

@protocol PlurkConnectorDelegate <NSObject>

- (void)plurkCommand:(PlurkCommand *)command finishedWithResult:(NSDictionary *)result;
- (void)plurkCommandFailed:(PlurkCommand *)command withErrorCode:(ErrorCode)code;

@end

@interface PlurkConnector : NSObject <NSURLConnectionDataDelegate> {
	NSString *m_tokenKey;
	NSString *m_tokenSecret;
	id<PlurkConnectorDelegate> m_delegate;
}

@property (nonatomic, retain) NSString *tokenKey;
@property (nonatomic, retain) NSString *tokenSecret;
@property (nonatomic, assign) id<PlurkConnectorDelegate> delegate;

+ (PlurkConnector *)sharedInstance;
+ (NSDate *)dateWithPluDate:(NSString *)pluDate;
+ (NSString *)pluDateWithDate:(NSDate *)date;

- (void)plurkCommand:(PlurkCommand *)command withParameters:(NSDictionary *)parameters delegate:(id<PlurkConnectorDelegate>)delegate;

@end
