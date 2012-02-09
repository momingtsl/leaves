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
    
    
    topRightPage = [[CALayer alloc] init];
	topRightPage.masksToBounds = YES;
	topRightPage.contentsGravity = kCAGravityLeft;
	topRightPage.backgroundColor = [[UIColor whiteColor] CGColor];
    topPageRightOverlay = [[CALayer alloc] init];
	topPageRightOverlay.backgroundColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
    
    bottomRightPage = [[CALayer alloc] init];
	bottomRightPage.backgroundColor = [[UIColor whiteColor] CGColor];
	bottomRightPage.masksToBounds = YES;
	
    [self.layer addSublayer:topPage];
    [self.layer addSublayer:topRightPage];
	[self.layer addSublayer:bottomPage];
	[self.layer addSublayer:bottomRightPage];
    
    [topPage addSublayer:topPageOverlay];
    [topRightPage addSublayer:topPageRightOverlay];
    
	self.leafEdge = 1.0;
}

- (void) setLayerFrames 
{	    
    NSLog(@"%f,%f,%f,%f", self.layer.bounds.origin.x, self.layer.bounds.origin.y,self.layer.bounds.size.width, self.layer.bounds.size.height);
    
    if([self isLandscape])
    {
        NSLog(@"Landscape Mode");
        topPage.frame = CGRectMake( self.layer.bounds.origin.x , 
                                   self.layer.bounds.origin.y, 
                                   self.layer.bounds.size.width /2 , 
                                   self.layer.bounds.size.height);
        topPageOverlay.frame = topPage.bounds;
        
        topRightPage.frame = CGRectMake( self.layer.bounds.origin.x + self.layer.bounds.size.width /2 , 
                                   self.layer.bounds.origin.y, 
                                   self.layer.bounds.size.width /2 , 
                                   self.layer.bounds.size.height);
        topPageRightOverlay.frame = topRightPage.bounds;
        
        bottomPage.frame = CGRectMake(self.layer.bounds.origin.x + leafEdge * self.layer.bounds.size.width + self.layer.bounds.size.width /2, 
                                      self.layer.bounds.origin.y, 
                                      self.layer.bounds.size.width/2, 
                                      self.layer.bounds.size.height);
        bottomRightPage.frame = CGRectMake(self.layer.bounds.origin.x + leafEdge * self.layer.bounds.size.width + self.layer.bounds.size.width /2 + self.layer.bounds.size.width/2, 
                                      self.layer.bounds.origin.y, 
                                      self.layer.bounds.size.width/2, 
                                      self.layer.bounds.size.height);
//        
        topRightPage.opacity = 1;
        bottomRightPage.opacity = 1;
//        [self.layer addSublayer:topRightPage];
//        [self.layer addSublayer:bottomRightPage];
        
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
        topRightPage.opacity = 0;
        bottomRightPage.opacity = 0;
//        [topRightPage removeFromSuperlayer];
//        [bottomRightPage removeFromSuperlayer];
    }
    
    
}

- (void) layoutSubviews {
	[super layoutSubviews];	
	
	//if (!CGSizeEqualToSize(pageSize, self.bounds.size)) {
        if([self isLandscape])
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
        
        if([self isLandscape])
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

- (void) getImages {
    if([self isLandscape])
    {
        NSLog(@"Landscape Mode");
        if (currentPageIndex < numberOfPages) {
            if (currentPageIndex > 0 && backgroundRendering)
                [pageCache precacheImageForPageIndex:currentPageIndex-1];
            
            topPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex];
            
            if (currentPageIndex + 1 < numberOfPages) {
                topRightPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex+1];
            }
            
            if([self isLandscape])
            {
                if (currentPageIndex +1 < numberOfPages - 1)
                    bottomPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex + 2];
                
                if (currentPageIndex +2 < numberOfPages - 1)
                    bottomRightPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex + 3];
            }
            else
            {
                if (currentPageIndex < numberOfPages - 1)
                    bottomPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex + 1];
            }
            
            [pageCache minimizeToPageIndex:currentPageIndex];
        } else {
            topPage.contents = nil;
            bottomPage.contents = nil;
        }
    }
    else
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
    topPageRightOverlay.opacity = MIN(1.0, 4*(1-aLeafEdge));
    [super setLeafEdge:aLeafEdge];
}

- (void)dealloc
{
    [topPageOverlay release];
    [super dealloc];
}

@end
