//
//  PluConnector.m
//  iPlu
//
//  Created by Sema Belokovsky on 23.07.12.
//  Copyright (c) 2012 Nulana. All rights reserved.
//

#import "PluConnector.h"
#import "OAHMAC_SHA1SignatureProvider.h"

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

#pragma mark - PluCommand

@implementation PluCommand

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

@property (nonatomic, retain) PluCommand *command;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSMutableData *data;

- (id)initWithRequest:(NSURLRequest *)request command:(PluCommand *)cmd delegate:(id)delegate;

@end

@implementation PluConnection

@synthesize response, data;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
	self = [super initWithRequest:request delegate:delegate];
	if (self) {
		self.response = [NSURLResponse new];
		self.data = [NSMutableData new];
	}
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request command:(PluCommand *)cmd delegate:(id)delegate
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

#pragma mark - PluConnector

@implementation PluConnector
@synthesize tokenKey = m_tokenKey;
@synthesize tokenSecret = m_tokenSecret;

static PluConnector *m_instance;

+ (PluConnector *)instance
{
	@synchronized(self) {
		if (m_instance == nil ) {
			[[self alloc] init];
		}
	}
	
	return m_instance;
}

- (id)init {
	self = [super init];
	if (self) {
		m_instance = self;
	}
	return self;
}

- (void)pluCommand:(PluCommand *)command withParameters:(NSDictionary *)parameters delegate:(id<PluConnectorDelegate>)delegate
{
	NSString *apiUrl = [APIURL stringByAppendingFormat:@"%@",command.command];
	NSString *normEncodedParameters = [parameters normalizedUrlEncoded];
	NSString *baseString;
	baseString = [@"GET&" stringByAppendingFormat:@"%@&%@",urlEncode(apiUrl),normEncodedParameters];
	
	NSString *secret = [APPSECRET stringByAppendingString:@"&"];
	NSString *urlString = [urlEncode(apiUrl) stringByAppendingFormat:@"?%@&oauth_signature=%@", [parameters urlEncoded], urlEncode([OAHMAC_SHA1SignatureProvider signClearText:baseString withSecret:secret])];
	NSLog(@"\nsign %@ \nby secret %@", baseString, secret);
	NSLog(@"send: %@",urlString);
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	
	PluConnection *connection = [[PluConnection alloc] initWithRequest:request command:command delegate:self];
	
	if (connection == nil) {
		NSLog(@"nil connection");
	}
}

#pragma mark - NSURLCOnnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	((PluConnection *)connection).response  = [response retain];
	NSLog(@"receive: %@",response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[((PluConnection *)connection).data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSData *data = ((PluConnection *)connection).data;
	NSURLResponse *response = ((PluConnection *)connection).response;
	
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
