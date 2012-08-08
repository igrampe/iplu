//
//  PluConnector.h
//  iPlu
//
//  Created by Sema Belokovsky on 23.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APPKEY @"tG0lk2XlB63h"
#define APPSECRET @"Zgtcy0XOCSvPUcAHvF9fDfLfT7yOn48k"
#define _oauth_signature_method @"oauth_signature_method"
#define _HMAC_SHA1 @"HMAC-SHA1"
#define _oauth_nonce @"oauth_nonce"
#define _oauth_consumer_key @"oauth_consumer_key"
#define _oauth_version @"oauth_version"
#define _oauth_timestamp @"oauth_timestamp"
#define _oauth_token @"oauth_token"

typedef enum {
	kHTMLError = 0,
	kInvalidToken = 1,
	kBadRequest = 400,
	kInvalidTimestamp = 40004,
	kInvalidAccesToken = 40106
} ErrorCode;

@interface PluCommand : NSObject

@property (nonatomic, retain) NSString *command;
@property (nonatomic, assign) NSString *method;

- (id)initWithString:(NSString *)string;

@end

@protocol PluConnectorDelegate <NSObject>

- (void)pluCommand:(PluCommand *)command finishedWithResult:(NSDictionary *)result;
- (void)pluCommandFailed:(PluCommand *)command withErrorCode:(ErrorCode)code;

@end

@interface PluConnector : NSObject <NSURLConnectionDataDelegate> {
	NSString *m_tokenKey;
	NSString *m_tokenSecret;
	id<PluConnectorDelegate> m_delegate;
}

@property (nonatomic, retain) NSString *tokenKey;
@property (nonatomic, retain) NSString *tokenSecret;
@property (nonatomic, assign) id<PluConnectorDelegate> delegate;

+ (PluConnector *)sharedInstance;
+ (NSDate *)dateWithPluDate:(NSString *)pluDate;
+ (NSString *)pluDateWithDate:(NSDate *)date;

- (void)pluCommand:(PluCommand *)command withParameters:(NSDictionary *)parameters delegate:(id<PluConnectorDelegate>)delegate;

@end
