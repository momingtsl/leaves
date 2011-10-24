//
//  LeavesView.m
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright 2010 Tom Brow. All rights reserved.
//
//  Modified by Diego Belfiore
//  2011 Tatami Software
//

#import "LeavesView.h"


CGFloat distance(CGPoint a, CGPoint b);

@implementation LeavesView

@synthesize delegate;
@synthesize leafEdge, currentPageIndex, backgroundRendering, preferredTargetWidth;

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

- (void) initialize {
	backgroundRendering = NO;
    transactionWasPositive = NO;
	pageCache = [[LeavesCache alloc] initWithPageSize:self.bounds.size];
    //HACK
    UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(handleSingleDoubleTap:)];
    singleFingerDTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];
    
    UIPanGestureRecognizer* panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureMoveAround:)] autorelease];
    [panGesture setMaximumNumberOfTouches:1];
    //[panGesture setDelegate:self];
    [self addGestureRecognizer:panGesture];
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
	[bottomPage release];
	[pageCache release];
	
    [super dealloc];
}

- (void) reloadData {
	[pageCache flush];
	numberOfPages = [pageCache.dataSource numberOfPagesInLeavesView:self];
	self.currentPageIndex = 0;
}

- (void) getImages {
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

- (void) setLayerFrames {
    topPage.frame = CGRectMake(self.layer.bounds.origin.x - (1-leafEdge) * self.layer.bounds.size.width, 
                               self.layer.bounds.origin.y, 
                               self.layer.bounds.size.width, 
                               self.layer.bounds.size.height);
    
    bottomPage.frame = CGRectMake(self.layer.bounds.origin.x + leafEdge * self.layer.bounds.size.width, 
                                  self.layer.bounds.origin.y, 
                                  self.layer.bounds.size.width, 
                                  self.layer.bounds.size.height);
}

- (void) willTurnToPageAtIndex:(NSUInteger)index {
	if ([delegate respondsToSelector:@selector(leavesView:willTurnToPageAtIndex:)])
		[delegate leavesView:self willTurnToPageAtIndex:index];
}

- (void) didTurnToPageAtIndex:(NSUInteger)index {
	if ([delegate respondsToSelector:@selector(leavesView:didTurnToPageAtIndex:)])
		[delegate leavesView:self didTurnToPageAtIndex:index];
}

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

- (id<LeavesViewDataSource>) dataSource {
	return pageCache.dataSource;
	
}

- (void) setDataSource:(id<LeavesViewDataSource>)value {
	pageCache.dataSource = value;
}

- (void) setLeafEdge:(CGFloat)aLeafEdge {
    //
    //  setLeafEdge:0  =>  turn page
    //  setLeafEdge:1  =>  stay on current page
    //
	leafEdge = aLeafEdge;
	[self setLayerFrames];
}

- (void) setCurrentPageIndex:(NSUInteger)aCurrentPageIndex {
    NSLog(@"setCurrentPageIndex = %i", aCurrentPageIndex);
	currentPageIndex = aCurrentPageIndex;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	
	[self getImages];
	self.leafEdge = 1.0;
	
	[CATransaction commit];
}

- (void) setPreferredTargetWidth:(CGFloat)value {
	preferredTargetWidth = value;
	[self updateTargetRects];
}

#pragma mark Gesture Handling Methods
- (void) restoreFromPrevPageAnimation {
    self.currentPageIndex = self.currentPageIndex + 1;
    interactionLocked = NO;
}

- (void) goToNextPage {
	[CATransaction begin];
	float duration;
    
    [self willTurnToPageAtIndex:currentPageIndex+1];
    self.leafEdge = 0;
    duration = leafEdge;
    interactionLocked = YES;
    
    if (currentPageIndex+2 < numberOfPages && backgroundRendering)
        [pageCache precacheImageForPageIndex:currentPageIndex+2];
    
    [self performSelector:@selector(didTurnPageForward)
               withObject:nil 
               afterDelay:duration + 0.25];
    [CATransaction setValue:[NSNumber numberWithFloat:duration]
					 forKey:kCATransactionAnimationDuration];
	[CATransaction commit];
}

- (void) goToPrevPage {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    self.currentPageIndex = self.currentPageIndex - 1;
    self.leafEdge = 0.0;
    [CATransaction commit];
    
    
	[CATransaction begin];
	float duration;
    [self willTurnToPageAtIndex:currentPageIndex];
    self.leafEdge = 1.0;
    duration = 1 - leafEdge;
    interactionLocked = YES;
    
    [self performSelector:@selector(didTurnPageBackward)
               withObject:nil 
               afterDelay:duration + 0.25];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration]
					 forKey:kCATransactionAnimationDuration];
	[CATransaction commit];
}


- (IBAction)handleSingleDoubleTap:(UIGestureRecognizer *)sender {
    if (interactionLocked)
        return;
    
    CGPoint tapPoint = [sender locationInView:sender.view.superview];
    NSLog(@"Gesture Touch = %f,%f", tapPoint.x, tapPoint.y);
    
    if (CGRectContainsPoint(nextPageRect, tapPoint) && [self hasNextPage]) {
        NSLog(@"touchedNextPage");
        [self goToNextPage];
    } else if (CGRectContainsPoint(prevPageRect, tapPoint) && [self hasPrevPage]) {
        NSLog(@"touchedPrevPage");
        [self goToPrevPage];
    } else {
        NSLog(@"touchedCentralArea");
        if ([delegate respondsToSelector:@selector(leavesViewDidTouchCentralArea:)])
            [delegate leavesViewDidTouchCentralArea:self];
    }
}

//We use the leftEdge to set the position of top and bottom page
// translation.x/self.bounds.size.width has range -1:1
// leftEdge has range 0:1
// when leftEdge is 0: top page is on the center and bottom page is on the right
// when leftEdge is 1: top page is on the left and bottom page is on the center
// 
// when the traslation is negative we are managing the next page transition: leftEdge 1->0
// when the traslation is positive we are managing the previous page transition: leftEdge 0->1

-(float)panToLeftEdge:(UIPanGestureRecognizer *)gesture {
    UIView *piece = [gesture view];
    CGPoint translation = [gesture translationInView:[piece superview]];
    float ret=0;

    if (translation.x > 0)
        ret = translation.x/self.bounds.size.width;
    else
        ret = 1.0 + translation.x/self.bounds.size.width;
    return ret;
}


-(void)panGestureMoveAround:(UIPanGestureRecognizer *)gesture;
{
    if (interactionLocked)
        return;
    
    //[self adjustAnchorPointForGestureRecognizer:gesture];
    UIView *piece = [gesture view];
    CGPoint translation = [gesture translationInView:[piece superview]];
    if (translation.x == 0.0)
        return;
    
    if (translation.x > 0 && !transactionWasPositive ) { // we are going to the prev page
            //
            //  User is flipping back by dragging from left. We handle this by knocking down
            //  currentPageIndex one peg and treating it like if we're on the previous page
            //  and moving forward. 
            //
        if (![self hasPrevPage]) //Do nothing we are on the first page
            return;
        
        transactionWasPositive = YES;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                             forKey:kCATransactionDisableActions];
        self.currentPageIndex = self.currentPageIndex - 1;
        self.leafEdge = 0.0;
        [CATransaction commit];
        NSLog(@"STARTING POSITIVE TRANSACTION %f, page index = %i", translation.x, self.currentPageIndex);
    } else if (translation.x < 0 && transactionWasPositive) {
        transactionWasPositive = NO;
        if (![self hasNextPage])
            return;
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.currentPageIndex = self.currentPageIndex + 1;
        NSLog(@"STARTING NEGATIVE TRANSACTION AFTER a POSITIVE ONE %f, page index = %i", translation.x, self.currentPageIndex);
        self.leafEdge = 1.0;
        [CATransaction commit];
    } else if ([gesture state] == UIGestureRecognizerStateChanged) {
        if (translation.x < 0 && ![self hasNextPage])
            return;
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.07]
                         forKey:kCATransactionAnimationDuration];
        self.leafEdge = [self panToLeftEdge:gesture];
        NSLog(@"State Changed leafEdge = %f", self.leafEdge);
        [CATransaction commit];
    } else { //Gesture END
        NSLog(@"UIGestureRecognizerState ???? ");
        [CATransaction begin];
        float duration;
        transactionWasPositive = NO;

        if ( translation.x/self.bounds.size.width < -0.1) {
            NSLog(@"NEXT PAGE");
            if (![self hasNextPage]) {
                [CATransaction commit];
                return;
            }
            [self willTurnToPageAtIndex:currentPageIndex+1];
            self.leafEdge = 0.0;
            duration = 1.0 - fabs(translation.x/self.bounds.size.width);
            interactionLocked = YES;
            
            if (currentPageIndex+2 < numberOfPages && backgroundRendering)
                [pageCache precacheImageForPageIndex:currentPageIndex+2];
            
            [self performSelector:@selector(didTurnPageForward)
                       withObject:nil 
                       afterDelay:duration];
            
        } else if ( translation.x/self.bounds.size.width > 0.0 && translation.x/self.bounds.size.width < 0.1 ) {
            //recover form a prev page under the trigger value
            interactionLocked = YES;
            duration = 1.0 - leafEdge;
            self.leafEdge = 0.0;
            [self performSelector:@selector(restoreFromPrevPageAnimation)
                       withObject:nil
                       afterDelay:duration];
        } else if ( translation.x/self.bounds.size.width > 0.1 || translation.x/self.bounds.size.width < 0) {
            NSLog(@"PREV PAGE");
            [self willTurnToPageAtIndex:currentPageIndex];
            self.leafEdge = 1.0;
            duration = 1 - leafEdge;
            interactionLocked = YES;
            
            [self performSelector:@selector(didTurnPageBackward)
                       withObject:nil 
                       afterDelay:duration];
        }
        
        [CATransaction setValue:[NSNumber numberWithFloat:duration]
                         forKey:kCATransactionAnimationDuration];
        [CATransaction commit];
    }
}


/*
 #pragma mark UIResponder methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionLocked)
		return;
	
	UITouch *touch = [event.allTouches anyObject];
	touchBeganPoint = [touch locationInView:self];
	
    //
    //  User is flipping back by dragging from left. We handle this by knocking down
    //  currentPageIndex one peg and treating it like if we're on the previous page
    //  and moving forward. 
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

	else if ([self touchedNextPage] && [self hasNextPage])
		touchIsActive = YES;
	
	else 
		touchIsActive = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!touchIsActive)
		return;
    
	UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
	[CATransaction begin];    
	[CATransaction setValue:[NSNumber numberWithFloat:0.07]
					 forKey:kCATransactionAnimationDuration];

    self.leafEdge = touchPoint.x / self.bounds.size.width;
    
	[CATransaction commit];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!touchIsActive)
		return;
    
	touchIsActive = NO;
	
	UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
    BOOL dragged = distance(touchPoint, touchBeganPoint) > [self dragThreshold];
	
	[CATransaction begin];
	float duration;

	if ((dragged && self.leafEdge < 0.5) || (!dragged && [self touchedNextPage])) {
		[self willTurnToPageAtIndex:currentPageIndex+1];
		self.leafEdge = 0;
		duration = leafEdge;
		interactionLocked = YES;
        
		if (currentPageIndex+2 < numberOfPages && backgroundRendering)
			[pageCache precacheImageForPageIndex:currentPageIndex+2];

		[self performSelector:@selector(didTurnPageForward)
				   withObject:nil 
				   afterDelay:duration + 0.25];
	}
	else {
        [self willTurnToPageAtIndex:currentPageIndex];
		self.leafEdge = 1.0;
		duration = 1 - leafEdge;
		interactionLocked = YES;
        
		[self performSelector:@selector(didTurnPageBackward)
				   withObject:nil 
				   afterDelay:duration + 0.25];
	}
    
	[CATransaction setValue:[NSNumber numberWithFloat:duration]
					 forKey:kCATransactionAnimationDuration];
	[CATransaction commit];
}
*/
- (void) layoutSubviews {
	[super layoutSubviews];	
	
	if (!CGSizeEqualToSize(pageSize, self.bounds.size)) {
		pageSize = self.bounds.size;
		
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
        
		[self setLayerFrames];
		
        [CATransaction commit];
        
		pageCache.pageSize = self.bounds.size;
		[self getImages];
		[self updateTargetRects];
	}
}

@end


CGFloat distance(CGPoint a, CGPoint b) {
	return sqrtf(powf(a.x-b.x, 2) + powf(a.y-b.y, 2));
}


