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

@interface MainViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
PlurkConnectorDelegate,
OAuthDelegate,
MBProgressHUDDelegate,
TimelineCellDelegate> {
	NSMutableArray *m_plurks;
	NSMutableArray *m_users;
	IBOutlet UITableView *m_timelineView;
	MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UITableView *timelineView;

@end
