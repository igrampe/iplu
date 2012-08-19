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
@synthesize timelineView;

#pragma mark - Init and Cleanup

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
		m_menuButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user.png"]];

		m_menuButton.frame = CGRectMake(320 - 60, 5, 50, 50);
		[m_menuButton.layer setMasksToBounds:YES];
		[m_menuButton.layer setCornerRadius:22.0];
		[m_menuButton.layer setBorderWidth:1.0];
		[m_menuButton.layer setBorderColor:[UIColor grayColor].CGColor];
		
		[m_menuButton setBackgroundColor:[UIColor whiteColor]];
		m_menuButton.userInteractionEnabled = YES;
		UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self
																			  action:@selector(toggleMenu:)];
		[m_menuButton addGestureRecognizer:tgr];
		
		m_menuPopup = [[Popup alloc] initWithNibName:@"VerticalMenuPopup"];
		
		m_filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, 40, 20)];
		m_filterLabel.text = NSLocalizedString(@"All", @"All");
		m_filterLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
		m_filterLabel.textColor = [UIColor whiteColor];
		m_filterLabel.textAlignment = UITextAlignmentCenter;
		[m_filterLabel.layer setCornerRadius:10];
		
		m_isUpdating = NO;
		m_totalPlurksCount = 0;
    }
    return self;
}

- (void)dealloc
{
	self.timelineView = nil;
	[super dealloc];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	m_menuPopup.frame = m_menuButton.frame;
	m_menuPopup.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	m_menuButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	m_filterLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	
	[self.navigationController.navigationBar addSubview:m_menuPopup.view];
	[self.navigationController.navigationBar addSubview:m_menuButton];
	[self.navigationController.navigationBar addSubview:m_filterLabel];
	
	m_refreshControl = [[ODRefreshControl alloc] initInScrollView:self.timelineView];
    [m_refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	m_pullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.timelineView withClient:self];
	[self.timelineView reloadData];
	[m_pullToRefreshManager tableViewReloadFinished];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[HUD hide:YES afterDelay:0];
	if ([[[PlurkConnector sharedInstance] tokenKey] length] < 1) {
		[OAuthProvider sharedInstance].delegate = self;
		[[OAuthProvider sharedInstance] getToken];
	} else {
		[self updateTimelineWithOffset:nil limit:0];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
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

#pragma  mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TimelineCell *cell = (TimelineCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [cell heightForContent];
}

- (void)toggleMenu:(id)sender
{
	if (m_isMenuShowed) {
		[self hideMenu:YES];
	} else {
		[self showMenu:YES];
	}
}

- (void)showMenu:(BOOL)animated
{
	if (animated) {
		[m_selectedCell hidePopup:NO];
		m_selectedCell = nil;
		m_menuPopup.frame = m_menuButton.frame;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		m_menuPopup.frame = CGRectMake(m_menuButton.frame.origin.x, m_menuButton.frame.origin.y, 50, 320);
		[UIView commitAnimations];
	} else {
		[m_selectedCell hidePopup:NO];
		m_selectedCell = nil;
		m_menuPopup.frame = CGRectMake(m_menuButton.frame.origin.x, m_menuButton.frame.origin.y, 50, 320);
	}
	m_isMenuShowed= YES;
}

- (void)hideMenu:(BOOL)animated
{
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		m_menuPopup.frame = m_menuButton.frame;
		[UIView commitAnimations];
	} else {
		m_menuPopup.frame = m_menuButton.frame;
	}
	m_isMenuShowed = NO;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [m_pullToRefreshManager tableViewReleased];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[m_selectedCell hidePopup:NO];
	if (m_isMenuShowed) {
		[self hideMenu:NO];
	}
	[m_pullToRefreshManager tableViewScrolled];
}

#pragma mark - MNMBottomPullToRefreshManagerClient

- (void)MNMBottomPullToRefreshManagerClientReloadTable
{
	[self updateTimelineWithOffset:[(PlurkData *)[m_plurks lastObject] posted] limit:m_totalPlurksCount + 20];
}

#pragma mark - ODRefreshControl

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
	[self updateTimelineWithOffset:nil limit:20];
}

#pragma mark - MBProgressHUD Delegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

#pragma mark - CacheProvider Delegate

- (void)cacheUpdated
{
	[self.timelineView reloadData];
	if (m_ownProfile) {
		m_menuButton.image = [[CacheProvider sharedInstance] getImageByUser:m_ownProfile];
	}
	
}

- (void)timelineUpdated
{
	m_isUpdating = NO;
	[self.timelineView reloadData];
	[m_refreshControl endRefreshing];
	[m_pullToRefreshManager tableViewReloadFinished];
	
}

- (void)getOwnProfile
{
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
	PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Profile_getOwnProfile];
	[[PlurkConnector sharedInstance] plurkCommand:command withParameters:dict delegate:self];
}

- (void)updateTimelineWithOffset:(NSString *)offset
						   limit:(int)limit
{
	if (!m_isUpdating) {
		m_isUpdating = YES;
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
		if (offset) {
			NSString *pluDate = [PlurkConnector pluDateWithDate:[PlurkConnector dateWithPluDate:offset]];
			[dict setValue:pluDate forKey:_offset];
		}
		if (limit) {
			[dict setValue:[NSString stringWithFormat:@"%d",limit] forKey:_limit];
		}
		[dict setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:_oauth_token];
		PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Timeline_getPlurks];
		[[PlurkConnector sharedInstance] plurkCommand:command withParameters:dict delegate:self];
	}
}

- (void)updateTimelineWithOffset:(NSString *)offset
						   limit:(int)limit
				 favorersDetails:(int)favorersDetails
				   limitedDetail:(int)limitedDetail
				replurkersDetail:(int)replurkersDetail
{
	if (!m_isUpdating) {
		m_isUpdating = YES;
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
		PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Timeline_getPlurks];
		[[PlurkConnector sharedInstance] plurkCommand:command withParameters:dict delegate:self];
	}
	
}

#pragma mark - PlurkConnector Delegate

- (void)plurkCommandFailed:(PlurkCommand *)command withErrorCode:(ErrorCode)code
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
			NSLog(@"%@",command.command);
			if ([command.command isEqualToString:APP_Profile_getOwnProfile]) {
				[self getOwnProfile];
			}
			if ([command.command isEqualToString:APP_Timeline_getPlurks]) {
				[self updateTimelineWithOffset:nil limit:0];
			}
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
		[m_users removeAllObjects];
		NSArray *plurks = [(NSDictionary *)result objectForKey:@"plurks"];
		for (NSDictionary *i in plurks) {
			NSString *plurkId = [i objectForKey:@"plurk_id"];
			PlurkData *plurk = [[CacheProvider sharedInstance] getPlurkById:plurkId];
			if (!plurk) {
				plurk = [[PlurkData alloc] initWithDict:i];
				[[CacheProvider sharedInstance] addPlurk:plurk byId:plurk.plurkId];
				[m_plurks addObject:plurk];
			}
		}
		NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending: NO];
		[m_plurks sortUsingDescriptors:[NSArray arrayWithObject:sortOrder]];
		m_totalPlurksCount = [m_plurks count];
		NSDictionary *users = [(NSDictionary *)result objectForKey:@"plurk_users"];
		for (NSString *i in [users allKeys]) {
			UserData *user = [[UserData alloc] initWithDict:[users objectForKey:i]];
			[m_users setValue:user forKey:i];
			[[CacheProvider sharedInstance] addUser:user byId:i];
		}
		[self timelineUpdated];
	}
	if ([command.command isEqualToString:APP_Profile_getOwnProfile]) {
		m_ownProfile = [[UserData alloc] initWithDict:[result objectForKey:@"user_info"]];
		self.title = m_ownProfile.displayName;
		m_menuButton.image = [[CacheProvider sharedInstance] getImageByUser:m_ownProfile];
		
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[result objectForKey:@"unread_count"] intValue]];

	}
}

- (void)tokenObtained
{
	[HUD hide:YES afterDelay:0];
//	HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
//	HUD.delegate = self;
//	NSMutableDictionary *dict = [NSMutableDictionary new];
//	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
//	NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
//	NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
//	srand (time(NULL));
//	NSString *onceString = [NSString stringWithFormat:@"%d",rand()%1000000000];
//	[dict setValue:onceString forKey:_oauth_nonce];
//	[dict setValue:timestampString forKey:_oauth_timestamp];
//	[dict setValue:APPKEY forKey:_oauth_consumer_key];
//	[dict setValue:_HMAC_SHA1 forKey:_oauth_signature_method];
//	[dict setValue:@"1.0" forKey:_oauth_version];
//	[dict setValue:[[PlurkConnector sharedInstance] tokenKey] forKey:_oauth_token];
//	PlurkCommand *command = [[PlurkCommand alloc] initWithString:APP_Profile_getPublicProfile];
//	[[PlurkConnector sharedInstance] plurkCommand:command withParameters:dict delegate:self];
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



#pragma mark - TimelineCell Delegate

- (void)timelineCell:(TimelineCell *)timelineCell touchedWithEvent:(TimelineCellEvent)event
{
	switch (event) {
		case kTimelineCellEventAvatarTapped:
			if (timelineCell.isPopup) {
				[self hidePopup:YES];
			} else {
				if (m_isMenuShowed) {
					[self hideMenu:NO];
				}
				[m_selectedCell hidePopup:NO];
				m_selectedCell = timelineCell;
				[self showPopupInCell:timelineCell];
			}
			break;
		case kTimelineCellEventCellTapped:
			[m_selectedCell hidePopup:NO];
			if (m_isMenuShowed) {
				[self hideMenu:NO];
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

@end
