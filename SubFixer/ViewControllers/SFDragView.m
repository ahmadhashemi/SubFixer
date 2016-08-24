//
//  SFDragView.m
//  SubFixer
//
//  Created by Ahmad on 8/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "SFDragView.h"
#import "SFConverter.h"

@implementation SFDragView

-(void)awakeFromNib {
    
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    
    return NSDragOperationLink;
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    
    return YES;
}

-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    [SFConverter checkDragAndFixSubtitle:sender];
    
    return YES;
}

@end
