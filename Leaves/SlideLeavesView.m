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

- (void) setUpLayers 
{
    [super setUpLayers];
	topPageOverlay = [[CALayer alloc] init];
	topPageOverlay.backgroundColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
    [topPage addSublayer:topPageOverlay];
}

- (void) setLayerFrames 
{	    
    topPage.frame = self.layer.bounds;
    topPageOverlay.frame = topPage.bounds;

    bottomPage.frame = CGRectMake(self.layer.bounds.origin.x + leafEdge * self.layer.bounds.size.width, 
                                  self.layer.bounds.origin.y, 
                                  self.layer.bounds.size.width, 
                                  self.layer.bounds.size.height);
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
