//
//  LeavesView.m
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright 2010 Tom Brow. All rights reserved.
//

#import "LeavesView.h"

@interface LeavesView () 

@property (assign) CGFloat leafEdge;

@end

CGFloat distance(CGPoint a, CGPoint b);

@implementation LeavesView

@synthesize delegate;
@synthesize leafEdge, currentPageIndex, backgroundRendering, preferredTargetWidth;

//
//  Set the colors, shadows and maskToBounds properties for topPage, bottomPage and
//  all effects layers, and add each as a sublayer to its corresponding parent.
//
//  (What's not done here is sizing each layer's frame--that's done in setLayerFrames.)
//
- (void) setUpLayers {
	self.clipsToBounds = YES;
	
    //
    //  Build effects layers: top page shadow, top page reverse, etc.
    //
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
	
//	topPageReverse = [[CALayer alloc] init];
//	topPageReverse.backgroundColor = [[UIColor whiteColor] CGColor];
//	topPageReverse.masksToBounds = YES;
//	
//	topPageReverseImage = [[CALayer alloc] init];
//	topPageReverseImage.masksToBounds = YES;
//	topPageReverseImage.contentsGravity = kCAGravityRight;
//	
//	topPageReverseOverlay = [[CALayer alloc] init];
//	topPageReverseOverlay.backgroundColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.8] CGColor];
//	
//	topPageReverseShading = [[CAGradientLayer alloc] init];
//	topPageReverseShading.colors = [NSArray arrayWithObjects:
//									(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
//									(id)[[UIColor clearColor] CGColor],
//									nil];
//	topPageReverseShading.startPoint = CGPointMake(1,0.5);
//	topPageReverseShading.endPoint = CGPointMake(0,0.5);
	
	bottomPage = [[CALayer alloc] init];
	bottomPage.backgroundColor = [[UIColor whiteColor] CGColor];
	bottomPage.masksToBounds = YES;
	
//	bottomPageShadow = [[CAGradientLayer alloc] init];
//	bottomPageShadow.colors = [NSArray arrayWithObjects:
//							   (id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
//							   (id)[[UIColor clearColor] CGColor],
//							   nil];
//	bottomPageShadow.startPoint = CGPointMake(0,0.5);
//	bottomPageShadow.endPoint = CGPointMake(1,0.5);
	
    //
    //  Add sublayers to top, bottom, etc layers
    //
	[topPage addSublayer:topPageShadow];
	[topPage addSublayer:topPageOverlay];
	
//    [topPageReverse addSublayer:topPageReverseImage];
//	[topPageReverse addSublayer:topPageReverseOverlay];
//	[topPageReverse addSublayer:topPageReverseShading];
	
//    [bottomPage addSublayer:bottomPageShadow];
	
    //
    //  Add layers to view; next page (bottomPage) is below page we're looking at (topPage).
    //
	[self.layer addSublayer:topPage];
    [self.layer addSublayer:bottomPage];
//	[self.layer addSublayer:topPageReverse];
	
	self.leafEdge = 1.0;
}

//-------------------------Typical view initialization stuff-------------------------------
- (void) initialize {
	backgroundRendering = NO;
	pageCache = [[LeavesCache alloc] initWithPageSize:self.bounds.size];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setUpLayers];
		[self initialize];
    }
    return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self setUpLayers];
	[self initialize];
}

- (void)dealloc {
	[topPage release];
	[topPageShadow release];
	[topPageOverlay release];
//	[topPageReverse release];
//	[topPageReverseImage release];
//	[topPageReverseOverlay release];
//	[topPageReverseShading release];
	[bottomPage release];
//	[bottomPageShadow release];
	
	[pageCache release];
	
    [super dealloc];
}
//-----------------------------------------------------------------------------------------

//
//  Rebuild page cache and start from first page.
//
- (void) reloadData {
	[pageCache flush];
	numberOfPages = [pageCache.dataSource numberOfPagesInLeavesView:self];
	self.currentPageIndex = 0;
}

//
//  This gets called after we've turned a page. Sets the page contents for the current and next pages
//  and flushes everything from the page cache that's not needed.
//
- (void) getImages {
	if (currentPageIndex < numberOfPages) {
//
//  This is only used for multi-threading, so we'll leave it out for simplicity.
//
//		if (currentPageIndex > 0 && backgroundRendering)
//			[pageCache precacheImageForPageIndex:currentPageIndex-1];
        
        //
        //  Set the view contents for the topPage (the page we're looking at).
        //
		topPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex];
//		topPageReverseImage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex];
        
        //
        //  Set the bottomPage (next page) contents, if we haven't reached the end of the book.
        //
		if (currentPageIndex < numberOfPages - 1)
			bottomPage.contents = (id)[pageCache cachedImageForPageIndex:currentPageIndex + 1];
		
        //
        //  Get rid of everything in the pageCache except previous, current and next pages
        //  to keep the memory footprint low.
        //
        [pageCache minimizeToPageIndex:currentPageIndex];
	} else {
        //
        //  We've reached the end--no more pages to turn.
        //
		topPage.contents = nil;
//		topPageReverseImage.contents = nil;
		bottomPage.contents = nil;
	}
}

//
//  Sets up initial layer frame sizes on first call, then adjusts layer frames (along with drag) for 
//  animation on subsequent calls.
//
//  Tied to setleafEdge:
//    leafEdge = 0  =>  topPage.frame.size.width = 0                       => turn page
//    leafEdge = 1  =>  topPage.frame.size.width = self.bounds.size.width  =>  stay on current page
//
- (void) setLayerFrames {
//	topPage.frame = CGRectMake(self.layer.bounds.origin.x, 
//							   self.layer.bounds.origin.y, 
//							   leafEdge * self.bounds.size.width, 
//							   self.layer.bounds.size.height);
    
//    topPage.frame = self.layer.bounds;
    topPage.frame = CGRectMake(self.layer.bounds.origin.x - (1-leafEdge) * self.layer.bounds.size.width, 
                               self.layer.bounds.origin.y, 
                               self.layer.bounds.size.width, 
                               self.layer.bounds.size.height);
    
//	topPageReverse.frame = CGRectMake(self.layer.bounds.origin.x + (2*leafEdge-1) * self.bounds.size.width, 
//									  self.layer.bounds.origin.y, 
//									  (1-leafEdge) * self.bounds.size.width, 
//									  self.layer.bounds.size.height);
//	bottomPage.frame = self.layer.bounds;
    bottomPage.frame = CGRectMake(self.layer.bounds.origin.x + leafEdge * self.layer.bounds.size.width, 
                                  self.layer.bounds.origin.y, 
                                  self.layer.bounds.size.width, 
                                  self.layer.bounds.size.height);
//	topPageShadow.frame = CGRectMake(topPageReverse.frame.origin.x - 40, 
//									 0, 
//									 40, 
//									 bottomPage.bounds.size.height);
//	topPageReverseImage.frame = topPageReverse.bounds;
//	topPageReverseImage.transform = CATransform3DMakeScale(-1, 1, 1);
//	topPageReverseOverlay.frame = topPageReverse.bounds;
//	topPageReverseShading.frame = CGRectMake(topPageReverse.bounds.size.width - 50, 
//											 0, 
//											 50 + 1, 
//											 topPageReverse.bounds.size.height);
//	bottomPageShadow.frame = CGRectMake(leafEdge * self.bounds.size.width, 
//										0, 
//										40, 
//										bottomPage.bounds.size.height);
	topPageOverlay.frame = topPage.bounds;
}

//-------------------------------Delegate notifiers--------------------------------------
- (void) willTurnToPageAtIndex:(NSUInteger)index {
	if ([delegate respondsToSelector:@selector(leavesView:willTurnToPageAtIndex:)])
		[delegate leavesView:self willTurnToPageAtIndex:index];
}

- (void) didTurnToPageAtIndex:(NSUInteger)index {
	if ([delegate respondsToSelector:@selector(leavesView:didTurnToPageAtIndex:)])
		[delegate leavesView:self didTurnToPageAtIndex:index];
}
//-------------------------------Page turn utilities--------------------------------------
- (void) didTurnPageBackward {
	interactionLocked = NO;
	[self didTurnToPageAtIndex:currentPageIndex];
}

- (void) didTurnPageForward {
	interactionLocked = NO;
	self.currentPageIndex = self.currentPageIndex + 1;	
	[self didTurnToPageAtIndex:currentPageIndex];
}

- (BOOL) hasPrevPage {
	return self.currentPageIndex > 0;
}

- (BOOL) hasNextPage {
	return self.currentPageIndex < numberOfPages - 1;
}
//-------------------------------Interaction utilities-------------------------------------
- (BOOL) touchedNextPage {
	return CGRectContainsPoint(nextPageRect, touchBeganPoint);
}

- (BOOL) touchedPrevPage {
	return CGRectContainsPoint(prevPageRect, touchBeganPoint);
}

- (CGFloat) dragThreshold {
	// Magic empirical number
	return 10;
}

- (CGFloat) targetWidth {
	// Magic empirical formula
	if (preferredTargetWidth > 0 && preferredTargetWidth < self.bounds.size.width / 2)
		return preferredTargetWidth;
	else
		return MAX(28, self.bounds.size.width / 5);
}
//-----------------------------------------------------------------------------------------

//
//  Only gets called on init or if we want to set different interaction bounds for page
//  dragging points. Has nothing to do with animation.
//
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

#pragma mark accessors
//-------------------------pageCache acts as dataSource------------------------------------
- (id<LeavesViewDataSource>) dataSource {
	return pageCache.dataSource;
	
}

- (void) setDataSource:(id<LeavesViewDataSource>)value {
	pageCache.dataSource = value;
}
//-----------------------------------------------------------------------------------------

//
//  Sets shadow over top page according to page edge positon and moves along corresponding
//  effects layers.
//
//  setLeafEdge:0    =>  turn page
//  setLeafEdge:1.0  =>  stay on current page
//
- (void) setLeafEdge:(CGFloat)aLeafEdge {
	leafEdge = aLeafEdge;

    //
    //  Cast a shadow over visible part of topPage when dragging begins. Shadow gets 
    //  darker as the page is dragged further left, simulating a light source to the right.
    //
	topPageShadow.opacity = MIN(1.0, 4*(1-leafEdge));
//	bottomPageShadow.opacity = MIN(1.0, 4*leafEdge);
	topPageOverlay.opacity = MIN(1.0, 4*(1-leafEdge));
    
    //
    //  Move page edge and adjust effect layers accordingly.
    //
	[self setLayerFrames];
}

- (void) setCurrentPageIndex:(NSUInteger)aCurrentPageIndex {
	currentPageIndex = aCurrentPageIndex;
	
    //
    //  Begin animation block, disable all other layer actions.
    //
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	
    //
    //  Set the current, previsou & next page images and flush everything else from pageCache.
    //
	[self getImages];
	
    //
    //  Complete a page turn by removing topPageShadow (opacity = 0) and resetting 
    //  effects layer frames.
    //
	self.leafEdge = 1.0;
	
	[CATransaction commit];
}

//-------------------------------Interaction utility---------------------------------------
- (void) setPreferredTargetWidth:(CGFloat)value {
	preferredTargetWidth = value;
	[self updateTargetRects];
}
//-----------------------------------------------------------------------------------------

#pragma mark UIResponder methods

//
//  Set the touch point iff we're not moving beyond bounds. If we're flipping back, set
//  currentPageIndex one page back and look at this as flipping forward from the previous
//  page. (So conceptually we move forward & backwards, but in code we only move forward.)
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//
    //  Do nothing if we're in the middle of a drag.
    //
    if (interactionLocked)
		return;
	
    //
    //  Set the initial touch point for comparison on drag.
    //
	UITouch *touch = [event.allTouches anyObject];
	touchBeganPoint = [touch locationInView:self];
	
    //
    //  User is flipping back by dragging from left. We handle this by knocking down
    //  currentPageIndex one peg and treating it like if we're on the previous page
    //  and moving forward. 
    //
    //  (This is like ninja-master-level cleverness in how this is handled).
    //
	if ([self touchedPrevPage] && [self hasPrevPage]) {		
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
		self.currentPageIndex = self.currentPageIndex - 1;
		self.leafEdge = 0.0;
		[CATransaction commit];
		touchIsActive = YES;		
	} 

    //
    //  Touch landed in next page rectangle and there is a next page, so proceed.
    //
	else if ([self touchedNextPage] && [self hasNextPage])
		touchIsActive = YES;
	
    //
    //  User tried to flip past bounds (on either side) so ignore.
    //
	else 
		touchIsActive = NO;
}

//
//  Move effect layers along with drag.
//
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //
    //  Filter out movements we shouldn't respond to.
    //
	if (!touchIsActive)
		return;
    
    //
    //  Notice we're taking our touch point from event.allTouches and not from touches.
    //
	UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
    //
    //  Begin animation block.
    //
	[CATransaction begin];
    
    //
    //  This is how long it takes the animation to move between identified touch points.
    //
	[CATransaction setValue:[NSNumber numberWithFloat:0.07]
					 forKey:kCATransactionAnimationDuration];
	//
    //  Move the effects layers along with the drag.
    //
    self.leafEdge = touchPoint.x / self.bounds.size.width;
    
	[CATransaction commit];
}

//
//  Compute animation duration, notify delegates and roll the animation.
//
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //
    //  Filter out movements we shouldn't respond to.
    //
	if (!touchIsActive)
		return;
    
	touchIsActive = NO;
	
	UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
    //
    //  Determine if page drag was far enough to indicate a page turn.
    //
    BOOL dragged = distance(touchPoint, touchBeganPoint) > [self dragThreshold];
	
    //
    //  Begin animation block.
    //
	[CATransaction begin];
	float duration;

	if ((dragged && self.leafEdge < 0.5) || (!dragged && [self touchedNextPage])) {
        
        //
        //  Notify delegate of pre-event.
        //
		[self willTurnToPageAtIndex:currentPageIndex+1];
        
        //
        //  setLeafEdge:0  =>  turn page (cf, comments above setLeafEdge).
        //
		self.leafEdge = 0;
		duration = leafEdge;
		interactionLocked = YES;
        
//
//  Only used for multi-threading, so ignore for now.
//
//		if (currentPageIndex+2 < numberOfPages && backgroundRendering)
//			[pageCache precacheImageForPageIndex:currentPageIndex+2];

        //
        //  Notify delegate & enable interaction once animation is completed.
        //
		[self performSelector:@selector(didTurnPageForward)
				   withObject:nil 
				   afterDelay:duration + 0.25];
	}
	else {
		//
        //  Notify delegate of pre-event.
        //
        [self willTurnToPageAtIndex:currentPageIndex];
        
        //
        //  setLeafEdge:1  =>  stay on current page
        //
        //  If we initiated touch on left margin, then this actually means we're turning the page
        //  back to the previous page (rather than 'moving forward' to stay on current page).
        //
		self.leafEdge = 1.0;
		duration = 1 - leafEdge;
		interactionLocked = YES;
        
        //
        //  Notify delegate & enable interaction once animation is completed.
        //
		[self performSelector:@selector(didTurnPageBackward)
				   withObject:nil 
				   afterDelay:duration + 0.25];
	}
    
	[CATransaction setValue:[NSNumber numberWithFloat:duration]
					 forKey:kCATransactionAnimationDuration];
	[CATransaction commit];
}

//
//  Resets all the effects layers if the view's frame is resized.
//  LeavesViewController uses initWithFrame:CGRectZero so this always fires on load.
//
- (void) layoutSubviews {
	[super layoutSubviews];	
	
	if (!CGSizeEqualToSize(pageSize, self.bounds.size)) {
		pageSize = self.bounds.size;
		
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
        
        //
        //  Set initial size/position for all effects layers.
        //
		[self setLayerFrames];
		
        [CATransaction commit];
        
        //
        //  Setup page cache.
        //
		pageCache.pageSize = self.bounds.size;
		[self getImages];
		[self updateTargetRects];
	}
}

@end

//---------------------------------CG Math utility-----------------------------------------
CGFloat distance(CGPoint a, CGPoint b) {
	return sqrtf(powf(a.x-b.x, 2) + powf(a.y-b.y, 2));
}
//-----------------------------------------------------------------------------------------

