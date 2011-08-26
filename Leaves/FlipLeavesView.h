//
//  FlipLeavesView.h
//  Leaves
//
//  Created by Diego Belfiore on 8/25/11.
//  2011 Tatami Software
//
//  Based on code from LeavesView.h/m by Tom Brow.
//  Copyright 2011 Tom Brow. All rights reserved.
//

#import "LeavesView.h"

@interface FlipLeavesView : LeavesView
{
	CALayer *topPageOverlay;
	CAGradientLayer *topPageShadow;

	CALayer *topPageReverse;
	CALayer *topPageReverseImage;
	CALayer *topPageReverseOverlay;
	CAGradientLayer *topPageReverseShading;
    
	CAGradientLayer *bottomPageShadow;    
}

@end
