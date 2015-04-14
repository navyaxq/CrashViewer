//
//  ViewController.h
//  CrashViewer
//
//  Created by liuhaijun on 15/2/25.
//  Copyright (c) 2015年 All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property(nonatomic,retain)IBOutlet NSButton* dsymBtn;
@property(nonatomic,retain)IBOutlet NSButton* appBtn;
@property(nonatomic,retain)IBOutlet NSButton* crashBtn;
@property(nonatomic,retain)IBOutlet NSButton* symBtn;
@property(nonatomic,retain)IBOutlet NSButton* clearBtn;
@property(nonatomic,retain)IBOutlet NSButton* checkBtn;
@property(nonatomic,retain)IBOutlet NSButton* saveBtn;

@property(nonatomic,retain)IBOutlet NSTextField* dsymPathField;
@property(nonatomic,retain)IBOutlet NSTextField* appPathField;
@property(nonatomic,retain)IBOutlet NSTextField* crashPathField;
@property(nonatomic,retain)IBOutlet NSTextView* logLabel;
@property(nonatomic,retain)IBOutlet NSTextView* resultView;

- (IBAction)dsymBtnClicked:(id)sender;
- (IBAction)appBtnClicked:(id)sender;
- (IBAction)crashBtnClicked:(id)sender;
- (IBAction)analyseBtnClicked:(id)sender;
- (IBAction)clearBtnClicked:(id)sender;
- (IBAction)checkUUIDBtnClicked:(id)sender;
- (IBAction)saveBtnClicked:(id)sender;

@end

