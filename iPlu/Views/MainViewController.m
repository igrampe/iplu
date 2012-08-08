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
		m_timelineView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		m_plurks = [NSMutableArray new];
		NSLog(@"key %@ secret %@", [[PluConnector sharedInstance] tokenKey], [[PluConnector sharedInstance] tokenSecret]);
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
	self.view = m_timelineView;
}

- (void)viewDidAppear:(BOOL)animated
{
	if ([[[PluConnector sharedInstance] tokenKey] length] < 1) {
		[OAuthProvider sharedInstance].delegate = self;
		[[OAuthProvider sharedInstance] getToken];
	} else {
		NSMutableDictionary *dict = [NSMutableDictionary new];
		NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
		NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
		NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
		srand (time(NULL));
		NSString *onceString = [NSString stringWithFormat:@"%d",rand()%1000000000];
		[dict setValue:onceString forKey:@"oauth_nonce"];
		[dict setValue:timestampString forKey:@"oauth_timestamp"];
		[dict setValue:@"tG0lk2XlB63h" forKey:@"oauth_consumer_key"];
		[dict setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
		[dict setValue:@"1.0" forKey:@"oauth_version"];
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
		case kInvalidToken: {
			[OAuthProvider sharedInstance].delegate = self;
			[[OAuthProvider sharedInstance] resetToken];
		}
			break;
		default:
			break;
	}
}

- (void)pluCommand:(PluCommand *)command finishedWithResult:(NSDictionary *)result
{
	NSLog(@"result:\n%@",result);
	if ([command.command isEqualToString:@"APP/Timeline/getPlurks"]) {
		[m_plurks addObjectsFromArray:[(NSDictionary *)result objectForKey:@"plurks"]];
	}
	[m_timelineView reloadData];
}

- (void)tokenObtained
{
	
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
