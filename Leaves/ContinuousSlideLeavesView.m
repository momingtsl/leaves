//
//  ContinuousSlideLeavesView.m
//  Leaves
//
//  Created by Nicola Brisotto
//
//  Based on code from LeavesView by Tom Brow
//  Copyright 2011 Tom Brow. All rights reserved.
//

#import "ContinuousSlideLeavesView.h"

@implementation ContinuousSlideLeavesView

- (void) setUpLayers 
{
    [super setUpLayers];
}

- (void) setLayerFrames 
{
    topPage.frame = self.layer.bounds;
    //NSLog(@"-------------------------------------------");
    //NSLog(@"setLayerFrames, leafEdge = %f", leafEdge);
    //NSLog(@"self.layer.bounds.origin.x = %f", self.layer.bounds.origin.x);
    bottomPage.frame = CGRectMake(self.layer.bounds.origin.x + (leafEdge) * self.layer.bounds.size.width, 
                                  self.layer.bounds.origin.y, 
                                  self.layer.bounds.size.width, 
                                  self.layer.bounds.size.height);
    topPage.frame = CGRectMake(self.layer.bounds.origin.x + (leafEdge - 1.0) * self.layer.bounds.size.width, 
                                  self.layer.bounds.origin.y, 
                                  self.layer.bounds.size.width, 
                                  self.layer.bounds.size.height);
    //NSLog(@"topPage.frame.origin.x = %f", topPage.frame.origin.x);
    //NSLog(@"bottomPage.frame.origin.x = %f", bottomPage.frame.origin.x);    
}

- (void) setLeafEdge:(CGFloat)aLeafEdge 
{
    [super setLeafEdge:aLeafEdge];
}

- (void)dealloc
{
    [super dealloc];
}

@end
