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
#import "LeavesCache.h"

static const CGFloat kMaxScale = 3.0f;
static const CGFloat kMinScale = 1.0f;

CGFloat distance(CGPoint a, CGPoint b);

@implementation LeavesView

@synthesize mode;

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
	
    //[self setUpLayersForViewingMode];
    
	self.leafEdge = 1.0;
    
}

- (void) initialize {
	backgroundRendering = NO;
	pageCache = [[LeavesCache alloc] initWithPageSize:self.bounds.size];
    
    numberOfVisiblePages = 1;
    
    [self setupGuesture];
}

- (void)setupGuesture
{
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoom:)];
    [pinchGesture setDelegate:self];
    [self addGestureRecognizer:pinchGesture];
	
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [tapGesture setNumberOfTapsRequired:2];
	[tapGesture setDelegate:self];
    [self addGestureRecognizer:tapGesture];
    
    [self turnPinchOn:NO];
    [self turnTapOn:NO];

    // When app start zoom and PAN are not active, of course
	zoomActive = NO;
	panActive = NO;
    
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
		
        [pageCache minimizeToPageIndex:currentPageIndex viewMode:self.mode];
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

- (void)zoomingCurrentView:(NSUInteger)zoomLevel {
	if ([delegate respondsToSelector:@selector(leavesView:zoomingCurrentView:)]) {
		[delegate leavesView:self zoomingCurrentView:zoomLevel];
    }
}

- (void)doubleTapCurrentView:(NSUInteger)zoomLevel {
	if ([delegate respondsToSelector:@selector(leavesView:doubleTapCurrentView:)]) {
        [delegate leavesView:self doubleTapCurrentView:0];
    }
}

- (void) didTurnPageBackward {
	interactionLocked = NO;
	[self didTurnToPageAtIndex:currentPageIndex];
}

- (void) didTurnPageForward {
	interactionLocked = NO;
    
    self.currentPageIndex = self.currentPageIndex + numberOfVisiblePages;	
    
	[self didTurnToPageAtIndex:currentPageIndex];
}

- (BOOL) hasPrevPage {
    return self.currentPageIndex > (numberOfVisiblePages - 1);
}

- (BOOL) hasNextPage {
    return self.currentPageIndex < numberOfPages - numberOfVisiblePages;
}

- (BOOL) isLandscape 
{
    return self.layer.bounds.size.width > self.layer.bounds.size.height;
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
	currentPageIndex = aCurrentPageIndex;
    
    if (self.mode == LeavesViewModeFacingPages && aCurrentPageIndex % 2 != 0) {
        currentPageIndex = aCurrentPageIndex + 1;
    }
	
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
        

        self.currentPageIndex = self.currentPageIndex - numberOfVisiblePages;

		
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
        [self willTurnToPageAtIndex:currentPageIndex+numberOfVisiblePages];
		
		self.leafEdge = 0;
		duration = leafEdge;
		interactionLocked = YES;
        
		if (currentPageIndex+2 < numberOfPages && backgroundRendering)
        {
            [pageCache precacheImageForPageIndex:currentPageIndex+2];
        }

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

- (void)setMode:(LeavesViewMode)newMode
{
    mode = newMode;
    
    if (mode == LeavesViewModeSinglePage) {
        numberOfVisiblePages = 1;
        if (self.currentPageIndex > numberOfPages - 1) {
            self.currentPageIndex = numberOfPages - 1;
        }
        
    } else {
        numberOfVisiblePages = 2;
        if (self.currentPageIndex % 2 != 0) {
            self.currentPageIndex++;
        }
    }
    
    //[self setUpLayersForViewingMode];
    [self setNeedsLayout];
}

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

#pragma mark -
#pragma mark UIGestureRecognizer methods


//this method will adjust the anchor point of the gesture recognizer in order for it to zoom towards the direction chosen by the user
- (void)adjustAnchorPointForGestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		
        UIView *piece = gestureRecognizer.view;
		
		
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}




// This method will handle the PINCH / ZOOM gesture 
- (void)pinchZoom:(UIPinchGestureRecognizer *)gestureRecognizer
{
	
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {        
        // Record lastScale
        lastScale = [gestureRecognizer scale];
    }
    
    if (!zoomActive && [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];//directing the zoom in the right direction
        
        zoomActive = YES;
        if (zoomActive) {
			UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMove:)];
			[panGesture setMaximumNumberOfTouches:2];
			[panGesture setDelegate:self];
			[self addGestureRecognizer:panGesture];
			[panGesture release];
			
		}
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]); 
        newScale = MIN(newScale, kMaxScale / currentScale);   
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        
        [delegate leavesView:self zoomingCurrentView:[gestureRecognizer scale]];	    	
        zoomActive = NO;
        lastScale = [gestureRecognizer scale]; 
	}
}

// This method will handle the double TAP gesture and will reposition the view at 1:1 scale whether the user tries to zoom out too much
- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer {
	
	
	//restore center anchorpoint
	self.layer.anchorPoint=CGPointMake(0.5f, 0.5f);
	[gestureRecognizer view].transform = CGAffineTransformIdentity;
	
	[[gestureRecognizer view] setCenter:CGPointMake([gestureRecognizer view].frame.size.width / 2, [gestureRecognizer view].frame.size.height / 2)];
	
	zoomActive = NO;
	panActive = NO;
	
	NSArray *registeredGestures = self.gestureRecognizers;
	
	for (UIGestureRecognizer *gesture in registeredGestures) {
		if ([gesture isKindOfClass:[UIPanGestureRecognizer class]] ) {
			// Let remove the PAN / MOVE gesture recognizer
			[self removeGestureRecognizer:gesture];
		}
	}
	
	[delegate leavesView:self doubleTapCurrentView:0];		
	
	
}

- (void)doubleTap {
	
	self.layer.anchorPoint=CGPointMake(0.5, 0.5);
	self.transform = CGAffineTransformIdentity;
	
	zoomActive = NO;
	panActive = NO;
	
	NSArray *registeredGestures = self.gestureRecognizers;
	
	for (UIGestureRecognizer *gesture in registeredGestures) {
		if ([gesture isKindOfClass:[UIPanGestureRecognizer class]] ) {
			// Let remove the PAN / MOVE gesture recognizer
			[self removeGestureRecognizer:gesture];
		}
	}
	
	[delegate leavesView:self doubleTapCurrentView:0];
	
}

// This method will handle the PAN / MOVE gesture 
- (void)panMove:(UIPanGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[[gestureRecognizer view] superview]];
        [[gestureRecognizer view] setCenter:CGPointMake([[gestureRecognizer view] center].x + translation.x, [[gestureRecognizer view] center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[[gestureRecognizer view] superview]];
    }
}

#pragma Multi touch and zooming support

- (void)turnPinchOn:(BOOL)state {
    pinchGesture.delegate = state ? self : nil;
}

- (void)turnTapOn:(BOOL)state {
    tapGesture.delegate = state ? self : nil;
}


@end


CGFloat distance(CGPoint a, CGPoint b) {
	return sqrtf(powf(a.x-b.x, 2) + powf(a.y-b.y, 2));
}


