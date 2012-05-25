//
//  ExamplesViewController.m
//  Leaves
//
//  Created by Tom Brow on 4/20/10.
//  Copyright 2010 Tom Brow. All rights reserved.
//
//  Modified by Diego Belfiore
//  2011 Tatami Software
//

#import "ExamplesViewController.h"
#import "PDFExampleViewController.h"
#import "ImageExampleViewController.h"
#import "ProceduralExampleViewController.h"
#import "PDFScrollExampleViewController.h"
#import "PDFSlideExampleViewController.h"
#import "PDFSlideRotateExampleViewController.h"

enum {PDF, IMAGE, PROCEDURAL, NUM_EXAMPLES};

enum {SCROLL, SLIDE, SLIDE_ROTATE, NEW_EXAMPLES};

@implementation ExamplesViewController

- (id)init {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"Leaves";
}

- (void)dealloc {
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? @"Leaves Examples" : @"New Examples";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return NUM_EXAMPLES;
    return NEW_EXAMPLES;
}

- (NSString *)titleForCellForLeavesExampleRow:(NSInteger)row
{
    switch (row) {
		case PDF: return @"PDF example"; break;
		case IMAGE: return @"Image example"; break;
		case PROCEDURAL: return @"Procedural example"; break;
		default: return @""; break;
	}
}

- (NSString *)titleForCellForNewExampleRow:(NSInteger)row
{
    switch (row) {
        case SCROLL: return @"Scroll"; break;
        case SLIDE: return @"Slide"; break;
        case SLIDE_ROTATE: return @"Slide with Rotation"; break;
        default: return @""; break;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = (indexPath.section == 0) 
        ? [self titleForCellForLeavesExampleRow:indexPath.row] 
        : [self titleForCellForNewExampleRow:indexPath.row];
	    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)loadLeavesExampleForRow:(NSInteger)row
{
	UIViewController *viewController;
	switch (row) {
		case PDF: 
			viewController = [[[PDFExampleViewController alloc] init] autorelease];
			break;
		case IMAGE: 
			viewController = [[[ImageExampleViewController alloc] init] autorelease]; 
			break;
		case PROCEDURAL:
			viewController = [[[ProceduralExampleViewController alloc] init] autorelease]; 
			break;
		default: 
			viewController = [[[UIViewController alloc] init] autorelease];
	} 
	[self.navigationController pushViewController:viewController animated:YES];    
}

- (void)loadNewExampleForRow:(NSInteger)row
{
    UIViewController *viewController;
    switch (row) {
        case SCROLL:
            viewController = [[[PDFScrollExampleViewController alloc] init] autorelease];
            break;
        case SLIDE:
            viewController = [[[PDFSlideExampleViewController alloc] init] autorelease];
            break;
        case SLIDE_ROTATE:
            viewController = [[[PDFSlideRotateExampleViewController alloc] init] autorelease];
            break;
        default:
            viewController = [[[UIViewController alloc] init] autorelease];
            break;
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == 0) [self loadLeavesExampleForRow:indexPath.row];
    else [self loadNewExampleForRow:indexPath.row];
}


@end

