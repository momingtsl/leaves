//
//  SlideRotateLeavesView.h
//  Leaves
//
//  Created by Chris Chan on 10/2/12.
//  Copyright (c) 2012 IGPSD Ltd. All rights reserved.
//

#import "LeavesView.h"



@interface SlideRotateLeavesView : LeavesView
{
	CAGradientLayer *topPageOverlay;
    
}
- (void) updateTargetRects;

@end
