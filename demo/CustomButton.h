//
//  Created by Sascha Marc Paulus on 13.08.10.
//  Copyright 2010 paulusWebMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CustomButton : UIButton {
	
	NSIndexPath *indexPath;

}

@property(nonatomic,retain) NSIndexPath *indexPath;

@end
