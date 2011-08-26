//
//  FlipLeavesView.h
//  Leaves
//
//  Created by Diego Belfiore on 8/25/11.
//  2011 Tatami Software
//
//  Using code from LeavesView.h/m by Tom Brow.
//  Copyright 2011 Tom Brow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FlipLeavesView.h"

@implementation FlipLeavesView

- (void) setUpLayers {
	self.clipsToBounds = YES;
	
	topPage = [[CALayer alloc] init];
	topPage.masksToBounds = YES;
	topPage.contentsGravity = kCAGravityLeft;
	topPage.backgroundColor = [[UIColor whiteColor] CGColor];
	
	topPageOverlay = [[CALayer alloc] init];
	topPageOverlay.backgroundColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];

	topPageShadow = [[CAGradientLayer alloc] init];
	topPageShadow.colors = [NSArray arrayWithObjects:
							(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
							(id)[[UIColor clearColor] CGColor],
							nil];
	topPageShadow.startPoint = CGPointMake(1,0.5);
	topPageShadow.endPoint = CGPointMake(0,0.5);

	topPageReverse = [[CALayer alloc] init];
	topPageReverse.backgroundColor = [[UIColor whiteColor] CGColor];
	topPageReverse.masksToBounds = YES;
	
	topPageReverseImage = [[CALayer alloc] init];
	topPageReverseImage.masksToBounds = YES;
	topPageReverseImage.contentsGravity = kCAGravityRight;
	
	topPageReverseOverlay = [[CALayer alloc] init];
	topPageReverseOverlay.backgroundColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.8] CGColor];
	
	topPageReverseShading = [[CAGradientLayer alloc] init];
	topPageReverseShading.colors = [NSArray arrayWithObjects:
									(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
									(id)[[UIColor clearColor] CGColor],
									nil];
	topPageReverseShading.startPoint = CGPointMake(1,0.5);
	topPageReverseShading.endPoint = CGPointMake(0,0.5);
	
	bottomPage = [[CALayer alloc] init];
	bottomPage.backgroundColor = [[UIColor whiteColor] CGColor];
	bottomPage.masksToBounds = YES;
	
	bottomPageShadow = [[CAGradientLayer alloc] init];
	bottomPageShadow.colors = [NSArray arrayWithObjects:
							   (id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
							   (id)[[UIColor clearColor] CGColor],
							   nil];
	bottomPageShadow.startPoint = CGPointMake(0,0.5);
	bottomPageShadow.endPoint = CGPointMake(1,0.5);

	[topPage addSublayer:topPageShadow];
	[topPage addSublayer:topPageOverlay];

    [topPageReverse addSublayer:topPageReverseImage];
	[topPageReverse addSublayer:topPageReverseOverlay];
	[topPageReverse addSublayer:topPageReverseShading];

    [bottomPage addSublayer:bottomPageShadow];
	
    [self.layer addSublayer:bottomPage];
	[self.layer addSublayer:topPage];
	[self.layer addSublayer:topPageReverse];
	
	self.leafEdge = 1.0;
}

- (void) setLayerFrames {
	topPage.frame = CGRectMake(self.layer.bounds.origin.x, 
							   self.layer.bounds.origin.y, 
							   leafEdge * self.bounds.size.width, 
							   self.layer.bounds.size.height);    
    
	topPageReverse.frame = CGRectMake(self.layer.bounds.origin.x + (2*leafEdge-1) * self.bounds.size.width, 
									  self.layer.bounds.origin.y, 
									  (1-leafEdge) * self.bounds.size.width, 
									  self.layer.bounds.size.height);
	bottomPage.frame = self.layer.bounds;

	topPageShadow.frame = CGRectMake(topPageReverse.frame.origin.x - 40, 
									 0, 
									 40, 
									 bottomPage.bounds.size.height);
	topPageReverseImage.frame = topPageReverse.bounds;
	topPageReverseImage.transform = CATransform3DMakeScale(-1, 1, 1);
	topPageReverseOverlay.frame = topPageReverse.bounds;
	topPageReverseShading.frame = CGRectMake(topPageReverse.bounds.size.width - 50, 
											 0, 
											 50 + 1, 
											 topPageReverse.bounds.size.height);
	bottomPageShadow.frame = CGRectMake(leafEdge * self.bounds.size.width, 
										0, 
										40, 
										bottomPage.bounds.size.height);
	topPageOverlay.frame = topPage.bounds;
}

- (void) getImages {
	if (currentPageIndex < numberOfPages) {
		if (currentPageIndex > 0 && backgroundRendering)
			[pageCache precacheImageForPageIndex:currentPageIndex-1];
        
		topPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex];
		topPageReverseImage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex];
        
		if (currentPageIndex < numberOfPages - 1)
			bottomPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex + 1];

        [pageCache minimizeToPageIndex:currentPageIndex];
	} else {
		topPage.contents = nil;
		topPageReverseImage.contents = nil;
		bottomPage.contents = nil;
	}
}

- (void) setLeafEdge:(CGFloat)aLeafEdge {
	leafEdge = aLeafEdge;
    
	topPageShadow.opacity = MIN(1.0, 4*(1-leafEdge));
	bottomPageShadow.opacity = MIN(1.0, 4*leafEdge);
	topPageOverlay.opacity = MIN(1.0, 4*(1-leafEdge));
    
	[self setLayerFrames];
}

- (void)dealloc 
{
//	[topPage release];
	[topPageShadow release];
	[topPageOverlay release];
	[topPageReverse release];
	[topPageReverseImage release];
	[topPageReverseOverlay release];
	[topPageReverseShading release];
//	[bottomPage release];
	[bottomPageShadow release];
	
//	[pageCache release];
	
    [super dealloc];
}

@end
