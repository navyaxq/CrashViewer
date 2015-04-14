//
//  WindowContorller.m
//  CrashViewer
//
//  Created by liuhaijun on 15/2/28.
//  Copyright (c) 2015年 All rights reserved.
//

#import "WindowContorller.h"

@interface WindowContorller ()

@end

@implementation WindowContorller

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSButton *closeButton = [[self window] standardWindowButton:NSWindowCloseButton];
    closeButton.target = self;
    closeButton.action = @selector(close);
}
- (void)close;
{
    [[NSApplication sharedApplication] terminate:0];
    [super close];
}
@end
