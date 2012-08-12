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

@interface MainViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
PlurkConnectorDelegate,
OAuthDelegate,
MBProgressHUDDelegate,
TimelineCellDelegate,
CacheDelegate>{

	NSMutableArray *m_plurks;
	NSMutableDictionary *m_users;
	MBProgressHUD *HUD;
	Popup *m_plurkPopup;
	TimelineCell *m_selectedCell;
	UIImageView *m_ownerAvatar;
	Popup *m_menuPopup;
	BOOL m_isMenuShowed;
	NSMutableDictionary *m_parameters;
	UserData *m_ownProfile;
	PlurkViewController *m_plurkViewController;
	ODRefreshControl *m_refreshControl;
	BOOL m_isUpdating;
}

@property (nonatomic, retain) IBOutlet UITableView *timelineView;

@end
