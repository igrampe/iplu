//
//  MainViewController.m
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "MainViewController.h"
#import "AppSettingsHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorsProvider.h"

@implementation MainViewController
@synthesize timelineView = m_timelineView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[PlurkConnector sharedInstance] setTokenKey:[AppSettingsHelper getAccessTokenKey]];
		[[PlurkConnector sharedInstance] setTokenSecret:[AppSettingsHelper getAccessTokenSecret]];
		m_plurks = [NSMutableArray new];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if ([[[PlurkConnector sharedInstance] tokenKey] length] < 1) {
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
		[dict setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:@"oauth_token"];
		PlurkCommand *command = [[PlurkCommand alloc] initWithString:@"APP/Timeline/getPlurks"];
		[[PlurkConnector sharedInstance] plurkCommand:command withParameters:dict delegate:self];
	}
}

#pragma mark - PlurkConnector Delegate

- (void)plurkCommandFailed:(NSString *)request withErrorCode:(ErrorCode)code
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

- (void)plurkCommand:(PlurkCommand *)command finishedWithResult:(NSDictionary *)result
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
	[dict setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:_oauth_token];
	PlurkCommand *command = [[PlurkCommand alloc] initWithString:@"APP/Timeline/getPlurks"];
	[[PlurkConnector sharedInstance] plurkCommand:command withParameters:dict delegate:self];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"TimelineCell";
	TimelineCell *cell = (TimelineCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[TimelineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	} else {
		[cell hidePopup:NO];
	}
	cell.delegate = self;
	cell.content.text = [[m_plurks objectAtIndex:indexPath.row] objectForKey:@"content"];
	cell.name.text = [NSString stringWithFormat:@"%@",[[m_plurks objectAtIndex:indexPath.row] objectForKey:@"owner_id"]];
	[[cell.avatar layer] setMasksToBounds:YES];
	[[cell.avatar layer] setBorderColor:[UIColor grayColor].CGColor];
	[[cell.avatar layer] setBorderWidth:1];
	[[cell.avatar layer] setCornerRadius:25.0];
	
	NSString *qualifierTranslated = [[m_plurks objectAtIndex:indexPath.row] objectForKey:@"qualifier_translated"];
	NSString *qualifier = [[m_plurks objectAtIndex:indexPath.row] objectForKey:@"qualifier"];
	[[cell.qualifier layer] setMasksToBounds:YES];
	[[cell.qualifier layer] setCornerRadius:10];
	
	if ([qualifierTranslated isEqualToString:@""]) {
		cell.qualifier.hidden = YES;
	} else {
		NSString *firstCapChar = [[qualifierTranslated substringToIndex:1] capitalizedString];
		NSString *cappedString = [qualifierTranslated stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
		cell.qualifier.text = cappedString;
		cell.qualifier.hidden = NO;
		cell.qualifier.backgroundColor = (UIColor *)[[ColorsProvider sharedInstance]
										  colorForKey:qualifier
										  inPalette:@"qualifierPalette"];
	}
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TimelineCell *cell = (TimelineCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [cell heightForContent];
}

#pragma mark - UITableView Delegate

- (void)cell:(UITableViewCell *)cell touchedWithAction:(TimelineCellAction)action
{
	switch (action) {
		case kPopup: {
			NSLog(@"Popup");
			NSArray *visibleCells = [m_timelineView indexPathsForVisibleRows];
			for (NSIndexPath *i in visibleCells) {
				UITableViewCell *currentCell = [self tableView:m_timelineView cellForRowAtIndexPath:i];
				currentCell.selected = NO;
			}
		}
			break;
		case kShare:
			NSLog(@"Share");
			break;
			
		default:
			break;
	}
}

@end
