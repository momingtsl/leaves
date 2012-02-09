//
//  SlideRotateLeavesView.m
//  Leaves
//
//  Created by Chris Chan on 10/2/12.
//  Copyright (c) 2012 IGPSD Ltd. All rights reserved.
//

#import "SlideRotateLeavesView.h"

@implementation SlideRotateLeavesView


- (void) setUpLayers 
{
    [super setUpLayers];
	topPageOverlay = [[CALayer alloc] init];
	topPageOverlay.backgroundColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
    [topPage addSublayer:topPageOverlay];
}

- (void) setLayerFrames 
{	    
    NSLog(@"%f,%f,%f,%f", self.layer.bounds.origin.x, self.layer.bounds.origin.y,self.layer.bounds.size.width, self.layer.bounds.size.height);
    
    if(self.layer.bounds.size.width > self.layer.bounds.size.height)
    {
        NSLog(@"Landscape Mode");
        topPage.frame = CGRectMake( self.layer.bounds.origin.x , 
                                   self.layer.bounds.origin.y, 
                                   self.layer.bounds.size.width /2 , 
                                   self.layer.bounds.size.height);
        topPageOverlay.frame = topPage.bounds;
        
        bottomPage.frame = CGRectMake(self.layer.bounds.origin.x + leafEdge * self.layer.bounds.size.width + self.layer.bounds.size.width /2, 
                                      self.layer.bounds.origin.y, 
                                      self.layer.bounds.size.width/2, 
                                      self.layer.bounds.size.height);
    }
    else
    {
        NSLog(@"Portrait Mode");
        topPage.frame = self.layer.bounds;
        topPageOverlay.frame = topPage.bounds;
        bottomPage.frame = CGRectMake(self.layer.bounds.origin.x + leafEdge * self.layer.bounds.size.width, 
                                      self.layer.bounds.origin.y, 
                                      self.layer.bounds.size.width,
                                      self.layer.bounds.size.height);
    }
    
    
}

- (void) layoutSubviews {
	[super layoutSubviews];	
	
	//if (!CGSizeEqualToSize(pageSize, self.bounds.size)) {
        if(self.layer.bounds.size.width > self.layer.bounds.size.height)
        {
            pageSize = CGSizeMake(self.bounds.size.width /2, self.bounds.size.height);
        }
        else
        {
            pageSize = self.bounds.size;
        }
		
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
        
		[self setLayerFrames];
		
        [CATransaction commit];
        
        if(self.layer.bounds.size.width > self.layer.bounds.size.height)
        {
            pageCache.pageSize = CGSizeMake(self.bounds.size.width /2, self.bounds.size.height);
        }
        else
        {
            pageCache.pageSize = self.bounds.size;
        }
        
		[self getImages];
		[self updateTargetRects];
	//}
}

- (void) updateTargetRects {
	CGFloat targetWidth = [self targetWidth];
	nextPageRect = CGRectMake(self.bounds.size.width - targetWidth,
							  0,
							  targetWidth,
							  self.bounds.size.height);
	prevPageRect = CGRectMake(0,
							  0,
							  targetWidth,
							  self.bounds.size.height);
}

- (void) setLeafEdge:(CGFloat)aLeafEdge 
{
	topPageOverlay.opacity = MIN(1.0, 4*(1-aLeafEdge));
    [super setLeafEdge:aLeafEdge];
}

- (void)dealloc
{
    [topPageOverlay release];
    [super dealloc];
}

@end
