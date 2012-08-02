//
//  MainViewController.h
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PluConnector.h"
#import "OAuthLoginViewController.h"

@interface MainViewController : UINavigationController
<PluConnectorDelegate,
UITableViewDataSource,
UITableViewDelegate> {
	OAuthLoginViewController *m_oAuthViewController;
}

@end
