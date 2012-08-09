//
//  ColorsProvider.h
//  iPlu
//
//  Created by Semen Belokovsky on 09.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorsProvider : NSObject {
	NSMutableDictionary *m_palettes;
}

+ (ColorsProvider *)sharedInstance;
- (UIColor *)colorForKey:(NSString *)key inPalette:(NSString *)palette;

@end
