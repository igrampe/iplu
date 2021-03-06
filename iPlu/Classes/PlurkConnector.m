//
//  PlurkConnector.m
//  iPlu
//
//  Created by Sema Belokovsky on 23.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "PlurkConnector.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "SBJsonParser.h"

#define APPKEY @"tG0lk2XlB63h"
#define APPSECRET @"Zgtcy0XOCSvPUcAHvF9fDfLfT7yOn48k"
#define APIURL @"http://www.plurk.com/"

#pragma mark - URL Dictionary

@interface NSDictionary(PlurkConnector)

- (NSString *)urlEncoded;
- (NSString *)normalizedUrlEncoded;

@end

static NSString *toString(id object)
{
	return [NSString stringWithFormat:@"%@", object];
}


static NSString *urlEncode(id object)
{
	NSString *string = toString(object);
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
	return [result autorelease];
}

@implementation NSDictionary(PlurkConnector)

- (NSString *)urlEncoded {
	NSMutableArray *parts = [NSMutableArray array];
	for (id key in self) {
		id value = [self objectForKey: key];
		NSString *part = [NSString stringWithFormat:@"%@=%@", urlEncode(key), urlEncode(value)];
		[parts addObject: part];
	}
	return [parts componentsJoinedByString:@"&"];
}

- (NSString *)normalizedUrlEncoded
{
	NSArray *normalizedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSMutableArray *parts = [NSMutableArray array];
	for (id key in normalizedKeys) {
		id value = [self objectForKey:key];
		NSString *part = [NSString stringWithFormat:@"%@%@%@", urlEncode(key), urlEncode(@"="),urlEncode(value)];
		[parts addObject: part];
	}
	return [parts componentsJoinedByString:urlEncode(@"&")];
}

@end

#pragma mark - plurkCommand

@implementation PlurkCommand

@synthesize command, method;

- (id)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		command = string;
		method = @"GET";
	}
	return self;
}

- (void)dealloc
{
	command = nil;
	method = nil;
	[super dealloc];
}

@end

#pragma mark - PluConnection

@interface PluConnection : NSURLConnection

@property (nonatomic, retain) PlurkCommand *command;
@property (nonatomic, assign) id<PlurkConnectorDelegate> sender;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, assign) long int totalFileSize;

- (id)initWithRequest:(NSURLRequest *)request command:(PlurkCommand *)cmd delegate:(id)delegate;

@end

@implementation PluConnection

@synthesize command, sender, response, data, totalFileSize;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
	self = [super initWithRequest:request delegate:delegate];
	if (self) {
		self.response = [NSURLResponse new];
		self.data = [NSMutableData new];
	}
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request command:(PlurkCommand *)cmd delegate:(id)delegate
{
	self = [self initWithRequest:request delegate:delegate];
	if (self) {
		self.command = cmd;
	}
	return self;
}

- (void)dealloc
{
	self.command = nil;
	self.response = nil;
	self.data = nil;
	[super dealloc];
}

@end

#pragma mark - PlurkConnector

@implementation PlurkConnector
@synthesize tokenKey = m_tokenKey;
@synthesize tokenSecret = m_tokenSecret;
@synthesize delegate = m_delegate;

static PlurkConnector *m_sharedInstance;

+ (PlurkConnector *)sharedInstance
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
		m_sharedInstance = self;
	}
	return self;
}

- (void)plurkCommand:(PlurkCommand *)command withParameters:(NSDictionary *)parameters delegate:(id<PlurkConnectorDelegate>)delegate
{
	NSString *apiUrl = [APIURL stringByAppendingFormat:@"%@",command.command];
	NSString *normEncodedParameters = [parameters normalizedUrlEncoded];
	NSString *baseString;
	baseString = [@"GET&" stringByAppendingFormat:@"%@&%@",urlEncode(apiUrl),normEncodedParameters];
	
	NSString *secret;
	if ([self.tokenSecret length]) {
		secret = [APPSECRET stringByAppendingFormat:@"&%@",self.tokenSecret];
	} else {
		secret = [APPSECRET stringByAppendingString:@"&"];
	}
	
	NSString *urlString;
	
	if ([parameters objectForKey:_offset]) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
		NSString *offsetString = [params objectForKey:_offset];
		offsetString = [offsetString stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
		
		[params setValue:offsetString forKey:_offset];
		
		urlString = [apiUrl stringByAppendingFormat:@"?%@&oauth_signature=%@", [params urlEncoded], urlEncode([OAHMAC_SHA1SignatureProvider signClearText:baseString withSecret:secret])];
	} else {
		urlString = [apiUrl stringByAppendingFormat:@"?%@&oauth_signature=%@", [parameters urlEncoded], urlEncode([OAHMAC_SHA1SignatureProvider signClearText:baseString withSecret:secret])];
	}

	 
//	NSLog(@"\nsign %@ \nby secret %@", baseString, secret);
	NSLog(@"send:\n%@",urlString);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
	m_delegate = delegate;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	PluConnection *connection = [[PluConnection alloc] initWithRequest:request command:command delegate:self];
	connection.sender = delegate;
	
	//NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (connection == nil) {
		NSLog(@"nil connection");
	}
}

- (void)sendConnection:(NSDictionary *)dict
{
	
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	((PluConnection *)connection).response = [response retain];
	((PluConnection *)connection).totalFileSize = response.expectedContentLength;
	NSLog(@"%@",response.MIMEType);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[((PluConnection *)connection).data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self performSelectorInBackground:@selector(parseRespondInBackground:) withObject:(PluConnection *)connection];
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSLog(@"ERROR: %@",error);
}

- (void)parseRespondInBackground:(PluConnection *)connection
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	NSData *data = connection.data;
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSLog(@"receive:\n%@", dataString);
	
	NSMutableDictionary *result = [[NSMutableDictionary new] autorelease];
	
	if ([connection.response.MIMEType isEqualToString:@"application/json"]) {
		SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
		NSDictionary *jsonObject = [jsonParser objectWithData:data];
		[jsonParser release];
		jsonParser = nil;
		if ([jsonObject objectForKey:@"error_text"]) {
			NSString *errorCodeString = [[dataString substringFromIndex:1] substringToIndex:5];
			[result setValue:connection forKey:_connection];
			[result setValue:errorCodeString forKey:_errorCode];
			[self performSelectorOnMainThread:@selector(parseErrorComplete:) withObject:result waitUntilDone:YES];
		} else {
			[result setValue:connection forKey:_connection];
			[result setValue:jsonObject forKey:_result];
			[self performSelectorOnMainThread:@selector(parseSuccesComplete:) withObject:result waitUntilDone:YES];
		}
	}
	if ([((PluConnection *)connection).response.MIMEType isEqualToString:@"text/html"]) {
		if ([dataString rangeOfString:@"DOCTYPE"].length > 0) {
			int codePosition = ([dataString rangeOfString:@"<title>"].location + [dataString rangeOfString:@"<title>"].length);
			NSString *errorCodeString = [[dataString substringFromIndex:codePosition] substringToIndex:3];
			[result setValue:connection forKey:_connection];
			[result setValue:errorCodeString forKey:_errorCode];
			[self performSelectorOnMainThread:@selector(parseErrorComplete:) withObject:result waitUntilDone:YES];
		} else {
			if ([dataString rangeOfString:@"error_text"].length > 0) {
				NSString *errorCodeString = [[dataString substringFromIndex:16] substringToIndex:5];
				[result setValue:connection forKey:_connection];
				[result setValue:errorCodeString forKey:_errorCode];
				[self performSelectorOnMainThread:@selector(parseErrorComplete:) withObject:result waitUntilDone:YES];
			} else {
				NSMutableDictionary *object = [NSMutableDictionary new];
				NSArray *parameters = [dataString componentsSeparatedByString:@"&"];
				for (NSString *i in parameters) {
					NSArray *keyValue = [i componentsSeparatedByString:@"="];
					[object setValue:[keyValue lastObject] forKey:[keyValue objectAtIndex:0]];
				}
				[result setValue:connection forKey:_connection];
				[result setValue:object forKey:_result];
				[self performSelectorOnMainThread:@selector(parseSuccesComplete:) withObject:result waitUntilDone:YES];
			}
		}
	}
	
	[pool drain];
}

- (void)parseSuccesComplete:(NSDictionary *)object
{
	PluConnection *connection = [object objectForKey:_connection];
	NSDictionary *result = [object objectForKey:_result];
	id<PlurkConnectorDelegate> delegate = connection.sender;
	[delegate plurkCommand:connection.command finishedWithResult:result];
}

- (void)parseErrorComplete:(NSDictionary *)object
{
	PluConnection *connection = [object objectForKey:_connection];
	NSString *errorCode = [object objectForKey:_errorCode];
	id<PlurkConnectorDelegate> delegate = connection.sender;
	[delegate plurkCommandFailed:connection.command withErrorCode:[errorCode intValue]];
}

+ (NSDate *)dateWithPluDate:(NSString *)pluDate
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
	return [dateFormatter dateFromString:pluDate];
}

+ (NSString *)pluDateWithDate:(NSDate *)date
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	return [dateFormatter stringFromDate:date];

}

@end
