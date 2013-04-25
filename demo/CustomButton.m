//
//  Created by Sascha Marc Paulus on 13.08.10.
//  Copyright 2010 paulusWebMedia. All rights reserved.
//

#import "CustomButton.h"


@implementation CustomButton

@synthesize indexPath;

- (id) init
{
	self = [super init];
	if(self!=nil)
	{
		indexPath = [[NSIndexPath alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[indexPath release];
	[super dealloc];
}

@end
