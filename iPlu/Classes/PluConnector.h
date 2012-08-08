//
//  PluConnector.h
//  iPlu
//
//  Created by Sema Belokovsky on 23.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kHTMLError = 0,
	kInvalidToken = 1,
	kInvalidTimestamp = 40004
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
