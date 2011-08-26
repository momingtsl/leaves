//
//  SlideLeavesView.m
//  Leaves
//
//  Created by Diego Belfiore on 8/26/11.
//  2011 Tatami Software
//
//  Based on code from LeavesView by Tom Brow
//  Copyright 2011 Tom Brow. All rights reserved.
//

#import "SlideLeavesView.h"

@implementation SlideLeavesView

- (void) setUpLayers {
	self.clipsToBounds = YES;

	topPage = [[CALayer alloc] init];
	topPage.masksToBounds = YES;
	topPage.contentsGravity = kCAGravityLeft;
	topPage.backgroundColor = [[UIColor whiteColor] CGColor];
		
	bottomPage = [[CALayer alloc] init];
	bottomPage.backgroundColor = [[UIColor whiteColor] CGColor];
	bottomPage.masksToBounds = YES;
	
	[self.layer addSublayer:topPage];
    [self.layer addSublayer:bottomPage];
	
	self.leafEdge = 1.0;
}

- (void) setLayerFrames 
{
    topPage.frame = CGRectMake(self.layer.bounds.origin.x - (1-leafEdge) * self.layer.bounds.size.width, 
                               self.layer.bounds.origin.y, 
                               self.layer.bounds.size.width, 
                               self.layer.bounds.size.height);

    bottomPage.frame = CGRectMake(self.layer.bounds.origin.x + leafEdge * self.layer.bounds.size.width, 
                                  self.layer.bounds.origin.y, 
                                  self.layer.bounds.size.width, 
                                  self.layer.bounds.size.height);
}

- (void) getImages 
{
	if (currentPageIndex < numberOfPages) {
		if (currentPageIndex > 0 && backgroundRendering)
			[pageCache precacheImageForPageIndex:currentPageIndex-1];
        
		topPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex];

		if (currentPageIndex < numberOfPages - 1)
			bottomPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex + 1];
		
        [pageCache minimizeToPageIndex:currentPageIndex];
	} else {
		topPage.contents = nil;
		bottomPage.contents = nil;
	}
}

- (void) setLeafEdge:(CGFloat)aLeafEdge 
{
	leafEdge = aLeafEdge;
	[self setLayerFrames];
}

@end
