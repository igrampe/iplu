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
<PluConnectorDelegate,
UITableViewDataSource,
UITableViewDelegate,
OAuthDelegate> {
	NSMutableArray *m_plurks;
	UITableView *m_timelineView;
}

@property (nonatomic, retain) IBOutlet UITableView *timelineView;

@end
