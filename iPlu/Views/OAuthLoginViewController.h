//
//  OAuthLoginViewController.h
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Nulana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PluConnector.h"

@interface OAuthLoginViewController : UIViewController <PluConnectorDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
