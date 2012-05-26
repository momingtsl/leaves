//
//  PDFExampleViewController.m
//  Leaves
//
//  Created by Tom Brow on 4/19/10.
//  Copyright 2010 Tom Brow. All rights reserved.
//

#import "PDFExampleViewController.h"
#import "Utilities.h"

@implementation PDFExampleViewController

- (id)init {
    if (self = [super init]) {
		CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("paper.pdf"), NULL, NULL);
		pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
		CFRelease(pdfURL);
    }
    return self;
}

- (void)dealloc {
	CGPDFDocumentRelease(pdf);
    
    tiledLayer.contents = nil;
    tiledLayer.delegate=nil;
    [tiledLayer removeFromSuperlayer];
    
    [super dealloc];
}

- (void) displayPageNumber:(NSUInteger)pageNumber {
	self.navigationItem.title = [NSString stringWithFormat:
								 @"Page %u of %u", 
								 pageNumber, 
								 CGPDFDocumentGetNumberOfPages(pdf)];
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	return CGPDFDocumentGetNumberOfPages(pdf);
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, index + 1);
	CGAffineTransform transform = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
											CGContextGetClipBoundingBox(ctx));
	CGContextConcatCTM(ctx, transform);
	CGContextDrawPDFPage(ctx, page);
}

#pragma mark Layer Support
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	if (leavesView.mode == LeavesViewModeSinglePage) {
		CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
		CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx));
        
		CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
		CGContextScaleCTM(ctx, 1.0, -1.0);
		CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(CGPDFDocumentGetPage(pdf, leavesView.currentPageIndex+1), kCGPDFCropBox, layer.bounds, 0, true));
        
		CGContextDrawPDFPage(ctx, CGPDFDocumentGetPage(pdf, leavesView.currentPageIndex+1));	
	} else {
		CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
		CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx));
		
		CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
		CGContextScaleCTM(ctx, 1.0, -1.0);
		
		// Drawing left page resized
		CGRect leftPage = layer.bounds;
		leftPage.size.width = layer.bounds.size.width / 2;
		CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(CGPDFDocumentGetPage(pdf, leavesView.currentPageIndex), kCGPDFCropBox, leftPage, 0, true));
		CGContextDrawPDFPage(ctx, CGPDFDocumentGetPage(pdf, leavesView.currentPageIndex));	
        
		// Drawing right page resized
		CGRect rightPage = layer.bounds;
		rightPage.size.width = layer.bounds.size.width / 2;
		rightPage.origin.x = layer.bounds.size.width / 2;
		CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(CGPDFDocumentGetPage(pdf, leavesView.currentPageIndex+1), kCGPDFCropBox, rightPage, 0, true));
		CGContextDrawPDFPage(ctx, CGPDFDocumentGetPage(pdf, leavesView.currentPageIndex+1));	
		
		
	}
    
}

#pragma mark  LeavesViewDelegate methods

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)pageIndex {
	[self displayPageNumber:pageIndex + 1];
}


- (void) leavesView:(LeavesView *)theView zoomingCurrentView:(NSUInteger)zoomLevel {
    
    // Checking to see if a tiledLayer exists
    if (tiledLayer == nil) {
        // Tiled Layer is nill 
        NSLog(@"**** tiledLayer does not exist we shoudl create one");
        tiledLayer = [CATiledLayer layer];
        tiledLayer.delegate = self;
        tiledLayer.tileSize = theView.frame.size;
        tiledLayer.levelsOfDetail = 4;  // 100
        tiledLayer.levelsOfDetailBias = 4; // 200
        tiledLayer.frame = theView.frame;
        tiledLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
        
        [theView.layer addSublayer:tiledLayer];
    } else {
        // tiledLayer exists so skip
        // Perhaps move this to start of method and if exists remove then recreate?
        NSLog(@"Current have a tiled layer");
    }
}

- (void) leavesView:(LeavesView *)theView doubleTapCurrentView:(NSUInteger)zoomLevel
{	
	[tiledLayer removeFromSuperlayer];
    tiledLayer.delegate = nil;              // Disconnect from Delegate aswell. 
	tiledLayer = nil;
}



#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	leavesView.backgroundRendering = YES;
	[self displayPageNumber:1];
}

@end
