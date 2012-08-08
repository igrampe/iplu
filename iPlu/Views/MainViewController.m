//
//  MainViewController.m
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "MainViewController.h"
#import "AppSettingsHelper.h"

@implementation MainViewController
@synthesize timelineView = m_timelineView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[PluConnector sharedInstance] setTokenKey:[AppSettingsHelper getAccessTokenKey]];
		[[PluConnector sharedInstance] setTokenSecret:[AppSettingsHelper getAccessTokenSecret]];
		m_timelineView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		m_plurks = [NSMutableArray new];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	m_timelineView.dataSource = self;
	m_timelineView.delegate = self;
	m_timelineView.frame = self.view.frame;
	[self.view addSubview:m_timelineView];
	
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if ([[[PluConnector sharedInstance] tokenKey] length] < 1) {
		[OAuthProvider sharedInstance].delegate = self;
		[[OAuthProvider sharedInstance] getToken];
	} else {
		HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
		HUD.delegate = self;
		NSMutableDictionary *dict = [NSMutableDictionary new];
		NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
		NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
		NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
		srand (time(NULL));
		NSString *onceString = [NSString stringWithFormat:@"%d",rand()%1000000000];
		[dict setValue:onceString forKey:_oauth_nonce];
		[dict setValue:timestampString forKey:_oauth_timestamp];
		[dict setValue:APPKEY forKey:_oauth_consumer_key];
		[dict setValue:_HMAC_SHA1 forKey:_oauth_signature_method];
		[dict setValue:@"1.0" forKey:_oauth_version];
		[dict setValue:[[PluConnector sharedInstance] tokenKey] forKey:@"oauth_token"];
		PluCommand *command = [[PluCommand alloc] initWithString:@"APP/Timeline/getPlurks"];
		[[PluConnector sharedInstance] pluCommand:command withParameters:dict delegate:self];
	}
}

#pragma mark - PluConnector Delegate

- (void)pluCommandFailed:(NSString *)request withErrorCode:(ErrorCode)code
{
	switch (code) {
		case kHTMLError:
			break;
		case kInvalidAccesToken: {
			[OAuthProvider sharedInstance].delegate = self;
			[[OAuthProvider sharedInstance] resetToken];
		}
			break;
		case kInvalidTimestamp:
			NSLog(@"Invalid timestamp");
			break;
		default:
			break;
	}
	[HUD hide:YES afterDelay:0];
}

- (void)pluCommand:(PluCommand *)command finishedWithResult:(NSDictionary *)result
{
	NSLog(@"result:\n%@",result);
	if ([command.command isEqualToString:@"APP/Timeline/getPlurks"]) {
		[m_plurks removeAllObjects];
		[m_plurks addObjectsFromArray:[(NSDictionary *)result objectForKey:@"plurks"]];
	}
	[self.timelineView reloadData];
	[HUD hide:YES afterDelay:0];
}

- (void)tokenObtained
{
	HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
	HUD.delegate = self;
	NSMutableDictionary *dict = [NSMutableDictionary new];
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
	NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
	NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
	srand (time(NULL));
	NSString *onceString = [NSString stringWithFormat:@"%d",rand()%1000000000];
	[dict setValue:onceString forKey:_oauth_nonce];
	[dict setValue:timestampString forKey:_oauth_timestamp];
	[dict setValue:APPKEY forKey:_oauth_consumer_key];
	[dict setValue:_HMAC_SHA1 forKey:_oauth_signature_method];
	[dict setValue:@"1.0" forKey:_oauth_version];
	[dict setValue:[[PluConnector sharedInstance] tokenKey] forKey:_oauth_token];
	PluCommand *command = [[PluCommand alloc] initWithString:@"APP/Timeline/getPlurks"];
	[[PluConnector sharedInstance] pluCommand:command withParameters:dict delegate:self];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = [@"TimelineCell" stringByAppendingFormat:@"_%d_%d", indexPath.section, indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	cell.textLabel.text = [[m_plurks objectAtIndex:indexPath.row] objectForKey:@"content"];
	return cell;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [m_plurks count];
}

#pragma mark - UITableView Delegate


@end
