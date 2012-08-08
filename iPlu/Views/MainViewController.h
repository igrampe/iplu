//
//  MainViewController.h
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PluConnector.h"
#import "OAuthProvider.h"

@interface MainViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
PluConnectorDelegate,
OAuthDelegate,
MBProgressHUDDelegate> {
	NSMutableArray *m_plurks;
	IBOutlet UITableView *m_timelineView;
	MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UITableView *timelineView;

@end
