//
//  ColorsProvider.m
//  iPlu
//
//  Created by Semen Belokovsky on 09.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import "ColorsProvider.h"

#define ColorWithRGBA(_r, _g, _b, _a) \
[UIColor colorWithRed:(_r) / 255.0f green:(_g) / 255.0f blue:(_b) / 255.0f alpha:(_a) / 255.0f]

@implementation ColorsProvider

static ColorsProvider *m_sharedInstance;

+ (ColorsProvider *)sharedInstance
{
	@synchronized(self) {
		if (m_sharedInstance == nil ) {
			[[self alloc] init];
		}
	}
	
	return m_sharedInstance;
}

- (id)init
{
	self = [super init];
	if (self) {
		m_palettes = [NSMutableDictionary new];
		[self createQualifierPalette];
		m_sharedInstance = self;
	}
	return self;
}

- (void)createQualifierPalette
{
	NSMutableDictionary *qualifierPalette = [NSMutableDictionary new];
	[qualifierPalette setObject:ColorWithRGBA(229, 124, 67, 255) forKey:@"is"];
	[qualifierPalette setObject:ColorWithRGBA(217, 161, 91, 255) forKey:@"says"];
	[qualifierPalette setObject:ColorWithRGBA(104, 156, 193, 255) forKey:@"thinks"];
	[qualifierPalette setObject:ColorWithRGBA(45, 131, 190, 255) forKey:@"feels"];
	[qualifierPalette setObject:ColorWithRGBA(46, 78, 158, 255) forKey:@"wonders"];
	[qualifierPalette setObject:ColorWithRGBA(82, 82, 82, 255) forKey:@"was"];
	[qualifierPalette setObject:ColorWithRGBA(119, 119, 119, 255) forKey:@"has"];
	[qualifierPalette setObject:ColorWithRGBA(131, 97, 188, 255) forKey:@"asks"];
	[qualifierPalette setObject:ColorWithRGBA(224, 91, 233, 255) forKey:@"hopes"];
	[qualifierPalette setObject:ColorWithRGBA(180, 109, 185, 255) forKey:@"will"];
	[qualifierPalette setObject:ColorWithRGBA(122, 154, 55, 255) forKey:@"needs"];
	[qualifierPalette setObject:ColorWithRGBA(91, 176, 23, 255) forKey:@"wishes"];
	[qualifierPalette setObject:ColorWithRGBA(141, 178, 65, 255) forKey:@"wants"];
	[qualifierPalette setObject:ColorWithRGBA(17, 17, 17, 255) forKey:@"hates"];
	[qualifierPalette setObject:ColorWithRGBA(98, 14, 14, 255) forKey:@"gives"];
	[qualifierPalette setObject:ColorWithRGBA(167, 73, 73, 255) forKey:@"shares"];
	[qualifierPalette setObject:ColorWithRGBA(203, 39, 40, 255) forKey:@"likes"];
	[qualifierPalette setObject:ColorWithRGBA(178, 12, 12, 255) forKey:@"loves"];
	[m_palettes setObject:qualifierPalette forKey:@"qualifierPalette"];
}

- (UIColor *)colorForKey:(NSString *)key inPalette:(NSString *)palette
{
	return [[m_palettes objectForKey:palette] objectForKey:key];
}

@end
