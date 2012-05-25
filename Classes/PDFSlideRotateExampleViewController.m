//
//  PDFSlideRotateExampleViewController.m
//  Leaves
//
//  Created by Chris Chan on 10/2/12.
//  Copyright (c) 2012 IGPSD Ltd. All rights reserved.
//

#import "PDFSlideRotateExampleViewController.h"
#import "SlideRotateLeavesView.h"

@implementation PDFSlideRotateExampleViewController

- (void)initialize 
{
    leavesView = [[SlideRotateLeavesView alloc] initWithFrame:CGRectZero];
    leavesView.mode = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? LeavesViewModeSinglePage : LeavesViewModeFacingPages;
}


@end
