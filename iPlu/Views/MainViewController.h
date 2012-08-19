//
//  MainViewController.h
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkConnector.h"
#import "OAuthProvider.h"
#import "TimelineCell.h"
#import "Popup.h"
#import "CacheProvider.h"
#import "PlurkViewController.h"
#import "ODRefreshControl.h"
#import "MNMBottomPullToRefreshManager.h"

@interface MainViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
MNMBottomPullToRefreshManagerClient,
MBProgressHUDDelegate,
TimelineCellDelegate,
OAuthDelegate,
CacheDelegate,
PlurkConnectorDelegate>{

	NSMutableArray *m_plurks;
	NSMutableDictionary *m_users;
	MBProgressHUD *HUD;
	ODRefreshControl *m_refreshControl;
	MNMBottomPullToRefreshManager *m_pullToRefreshManager;
	
	Popup *m_plurkPopup;
	Popup *m_menuPopup;
	TimelineCell *m_selectedCell;
	UIImageView *m_menuButton;
	UILabel *m_filterLabel;
	
	UserData *m_ownProfile;
	PlurkViewController *m_plurkViewController;
	
	BOOL m_isMenuShowed;
	BOOL m_isUpdating;
	int m_totalPlurksCount;
}

@property (nonatomic, retain) IBOutlet UITableView *timelineView;

@end
