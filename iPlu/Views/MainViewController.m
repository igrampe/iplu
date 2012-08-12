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
#import "UserData.h"
#import "CacheProvider.h"

@implementation MainViewController
@synthesize timelineView = m_timelineView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[PlurkConnector sharedInstance] setTokenKey:[AppSettingsHelper getAccessTokenKey]];
		[[PlurkConnector sharedInstance] setTokenSecret:[AppSettingsHelper getAccessTokenSecret]];
		m_plurks = [NSMutableArray new];
		m_users = [NSMutableDictionary new];
		m_plurkPopup = [[Popup alloc] initWithNibName:@"HorizontalPopup"];
		m_isMenuShowed = NO;
		m_parameters = [NSMutableDictionary new];
		m_ownerAvatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user.png"]];
		m_ownerAvatar.frame = CGRectMake(320 - 60, 5, 50, 50);
		[m_ownerAvatar.layer setMasksToBounds:YES];
		[m_ownerAvatar.layer setCornerRadius:22.0];
		[m_ownerAvatar.layer setBorderWidth:1.0];
		[m_ownerAvatar.layer setBorderColor:[UIColor grayColor].CGColor];
		
		[m_ownerAvatar setBackgroundColor:[UIColor whiteColor]];
		m_ownerAvatar.userInteractionEnabled = YES;
		UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menu:)];
		[m_ownerAvatar addGestureRecognizer:tgr];
		m_menuPopup = [[Popup alloc] initWithNibName:@"VerticalMenuPopup"];
		m_isUpdating = NO;

    }
    return self;
}

- (void)menu:(id)sender
{
	if (m_isMenuShowed) {
		if (sender == self) {
			m_menuPopup.frame = m_ownerAvatar.frame;
		} else {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.5];
			m_menuPopup.frame = m_ownerAvatar.frame;
			[UIView commitAnimations];
		}
		
	} else {
		[m_selectedCell hidePopup:NO];
		m_selectedCell = nil;
		m_menuPopup.frame = m_ownerAvatar.frame;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		m_menuPopup.frame = CGRectMake(m_ownerAvatar.frame.origin.x, m_ownerAvatar.frame.origin.y, 50, 320);
		[UIView commitAnimations];
	}
	m_isMenuShowed = !m_isMenuShowed;
	
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	m_menuPopup.frame = m_ownerAvatar.frame;
	[self.navigationController.navigationBar addSubview:m_menuPopup.view];
	[self.navigationController.navigationBar addSubview:m_ownerAvatar];
	
	m_refreshControl = [[ODRefreshControl alloc] initInScrollView:self.timelineView];
    [m_refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
	[self updateTimeline:0];
}

- (void)timelineUpdated
{
	[m_refreshControl endRefreshing];
	m_isUpdating = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[HUD hide:YES afterDelay:0];
	if ([[[PlurkConnector sharedInstance] tokenKey] length] < 1) {
		[OAuthProvider sharedInstance].delegate = self;
		[[OAuthProvider sharedInstance] getToken];
	} else {
		[self updateTimeline:0];
	}
}

- (void)getOwnProfile
{
	[m_parameters removeAllObjects];
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
	[m_parameters setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:_oauth_token];
	PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Profile_getOwnProfile];
	[[PlurkConnector sharedInstance] plurkCommand:command withParameters:m_parameters delegate:self];
}

- (void)updateTimeline:(int)offset
{
	if (!m_isUpdating) {
		m_isUpdating = YES;
		[m_parameters removeAllObjects];
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
		if (offset) {
			[m_parameters setValue:[NSString stringWithFormat:@"%d",offset] forKey:@"offset"];
		}
		[m_parameters setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:_oauth_token];
		PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Timeline_getPlurks];
		[[PlurkConnector sharedInstance] plurkCommand:command withParameters:m_parameters delegate:self];
	}
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

#pragma mark - PlurkConnector Delegate

- (void)plurkCommandFailed:(NSString *)request withErrorCode:(ErrorCode)code
{
	[HUD hide:YES afterDelay:0];
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
			[self updateTimeline:0];
			break;
		default:
			break;
	}

}

- (void)plurkCommand:(PlurkCommand *)command finishedWithResult:(NSDictionary *)result
{
	[HUD hide:YES afterDelay:0];
	NSLog(@"result:\n%@",result);
	if ([command.command isEqualToString:APP_Timeline_getPlurks]) {
		[m_plurks removeAllObjects];
		[m_users removeAllObjects];
		NSArray *plurks = [(NSDictionary *)result objectForKey:@"plurks"];
		for (NSDictionary *i in plurks) {
			PlurkData *plurk = [[PlurkData alloc] initWithDict:i];
			[[CacheProvider sharedInstance] addPlurk:plurk byId:plurk.plurkId];
			[m_plurks addObject:plurk];
		}
		NSDictionary *users = [(NSDictionary *)result objectForKey:@"plurk_users"];
		for (NSString *i in [users allKeys]) {
			UserData *user = [[UserData alloc] initWithDict:[users objectForKey:i]];
			[m_users setValue:user forKey:i];
			[[CacheProvider sharedInstance] addUser:user byId:i];
		}
//		[self getOwnProfile];
		[self timelineUpdated];
	}
	if ([command.command isEqualToString:APP_Profile_getOwnProfile]) {
		m_ownProfile = [[UserData alloc] initWithDict:[result objectForKey:@"user_info"]];
		self.title = m_ownProfile.displayName;
		m_ownerAvatar.image = [[CacheProvider sharedInstance] getImageByUser:m_ownProfile];
		
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[result objectForKey:@"unread_count"] intValue]];

	}
	[self.timelineView reloadData];
}

- (void)tokenObtained
{
	[HUD hide:YES afterDelay:0];
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
	PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Profile_getPublicProfile];
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
	static NSString *cellIdentifier = @"TimelineCell";
	TimelineCell *cell = (TimelineCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[TimelineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		[cell hidePopup:NO];
	}
	cell.delegate = self;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.plurk = [m_plurks objectAtIndex:indexPath.row];
	cell.name.text = [[m_users objectForKey:[cell.plurk.ownerId stringValue]] displayName];
	[cell.avatar setImage:[[CacheProvider sharedInstance] getImageByUserId:[cell.plurk.ownerId stringValue]]];
	[cell updateView];
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

- (void)showPopupInCell:(TimelineCell *)cell
{
	cell.popup = m_plurkPopup;
	[cell showPopup:YES];
}

- (void)hidePopup:(BOOL)animated
{
	[m_selectedCell hidePopup:animated];
	m_selectedCell = nil;
}

- (void)cacheUpdated
{
	[self.timelineView reloadData];
	if (m_ownProfile) {
		m_ownerAvatar.image = [[CacheProvider sharedInstance] getImageByUser:m_ownProfile];
	}
	
}

#pragma mark - UITableView Delegate

- (void)timelineCell:(TimelineCell *)timelineCell touchedWithEvent:(TimelineCellEvent)event
{
	switch (event) {
		case kTimelineCellEventAvatarTapped:
			if (timelineCell.isPopup) {
				[self hidePopup:YES];
			} else {
				if (m_isMenuShowed) {
					[self menu:self];
				}
				[m_selectedCell hidePopup:NO];
				m_selectedCell = timelineCell;
				[self showPopupInCell:timelineCell];
			}
			break;
		case kTimelineCellEventCellTapped:
			[m_selectedCell hidePopup:NO];
			if (m_isMenuShowed) {
				[self menu:self];
			}
			if (m_plurkViewController == nil) {
				m_plurkViewController = [[PlurkViewController alloc] initWithNibName:@"PlurkViewController" bundle:nil];
			}
			[self.navigationController pushViewController:m_plurkViewController animated:YES];
			break;
		default:
			break;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[m_selectedCell hidePopup:NO];
	if (m_isMenuShowed) {
		[self menu:self];
	}
}

@end
