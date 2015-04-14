//
//  ViewController.m
//  CrashViewer
//
//  Created by liuhaijun on 15/2/25.
//  Copyright (c) 2015年 All rights reserved.
//

#import "ViewController.h"

#define sympath @"symbolicatecrashPath"


@interface ViewController()
{
    NSMutableString* _strlog;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //提前搜索命令位置
    [self performSelectorInBackground:@selector(findSymbolicatecrash) withObject:nil];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)clearLog
{
    _strlog = @"".mutableCopy;
    [_logLabel setString:_strlog];
}
- (void)errorLog:(NSString*)msg
{
    if (!_strlog) {
        _strlog = @"".mutableCopy;
    }
    if (_strlog.length>0) {
        [_strlog appendString:@"\n"];
    }
    [_strlog appendString:msg];
    [_logLabel setString:_strlog];
}



#pragma mark textField changed
- (void)dsymFileChanged
{
    NSString* filePath = self.dsymPathField.stringValue;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self errorLog:@"dsym文件路径不存在"];
        return;
    }
    [self errorLog:@"正在获取dsymUUID..."];
    __block ViewController* bself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* dsynUUID = [bself getUUID:filePath];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [bself errorLog:[NSString stringWithFormat:@"dsymUUID获取成功：%@",dsynUUID]];
        });
    });
}
- (void)appFileChanged
{
    NSString* filePath = self.appPathField.stringValue;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self errorLog:@"app文件路径不存在"];
        return;
    }
    [self errorLog:@"正在获取appUUID..."];
    __block ViewController* bself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* appUUID = [self getAppUUID:_appPathField.stringValue];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [bself errorLog:[NSString stringWithFormat:@"appUUID获取成功：%@",appUUID]];
        });
    });
}
- (void)crashFileChanged
{
    NSString* filePath = self.crashPathField.stringValue;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self errorLog:@"crash文件路径不存在"];
        return;
    }
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    self.resultView.string = content;
    NSString* crashUUID = [self getCrashUUID:filePath];
    [self errorLog:[NSString stringWithFormat:@"crashUUID：%@",crashUUID]];
}

#pragma mark NSTextFieldDelegate
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    if (control == _dsymPathField) {
        [self dsymFileChanged];
    }
    else if (control == _appPathField) {
        [self appFileChanged];
    }
    else if (control == _crashPathField) {
        [self crashFileChanged];
    }
    return YES;
}


#pragma mark click events
- (IBAction)dsymBtnClicked:(id)sender
{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setCanChooseDirectories:NO];
    [oPanel setCanChooseFiles:YES];
    [oPanel setDirectoryURL:[NSURL fileURLWithPath:@"~"]];
    
    [oPanel beginWithCompletionHandler:^(NSInteger result) {
        if (NSFileHandlingPanelOKButton == result) {
            NSString *filePath = [[[oPanel URLs] objectAtIndex:0] path];
            [self.dsymPathField setStringValue:filePath];
            
            [self errorLog:[NSString stringWithFormat:@"您选择了dsyn文件：%@",filePath]];
            [self dsymFileChanged];
        }
    }];
}

- (IBAction)appBtnClicked:(id)sender
{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setCanChooseDirectories:NO];
    [oPanel setCanChooseFiles:YES];
    [oPanel setDirectoryURL:[NSURL fileURLWithPath:@"~"]];
    
    [oPanel beginWithCompletionHandler:^(NSInteger result) {
        if (NSFileHandlingPanelOKButton == result) {
            NSString *filePath = [[[oPanel URLs] objectAtIndex:0] path];
            [self.appPathField setStringValue:filePath];
            [self errorLog:[NSString stringWithFormat:@"您选择了app文件：%@",filePath]];
            [self appFileChanged];
        }
    }];
}

- (IBAction)crashBtnClicked:(id)sender
{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setCanChooseDirectories:NO];
    [oPanel setCanChooseFiles:YES];
    [oPanel setDirectoryURL:[NSURL fileURLWithPath:@"~"]];
    
    [oPanel beginWithCompletionHandler:^(NSInteger result) {
        if (NSFileHandlingPanelOKButton == result) {
            NSString *filePath = [[[oPanel URLs] objectAtIndex:0] path];
            [self.crashPathField setStringValue:filePath];
            [self errorLog:[NSString stringWithFormat:@"您选择了crash文件：%@",filePath]];
            [self crashFileChanged];
        }
    }];
}

- (IBAction)analyseBtnClicked:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_dsymPathField.stringValue]) {
        [self errorLog:@"DSYM文件不存在"];
        return;
    }
    if(![_dsymPathField.stringValue.lowercaseString hasSuffix:@".dsym"])
    {
        [self errorLog:@"DSYM文件格式错误"];
        return;
    }    if (![fileManager fileExistsAtPath:_crashPathField.stringValue]) {
        [self errorLog:@"crash文件不存在"];
        return;
    }
    if(![_crashPathField.stringValue.lowercaseString hasSuffix:@".crash"])
    {
        [self errorLog:@"crash文件格式错误"];
        return;
    }
    
    [self errorLog:@"文件符合要求，开始解析~~~~~~~~~~~~"];
    
    [self performSelectorInBackground:@selector(analyse) withObject:nil];
    
}
- (IBAction)clearBtnClicked:(id)sender
{
    [self clearLog];
}
- (IBAction)checkUUIDBtnClicked:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_dsymPathField.stringValue]) {
        [self errorLog:@"DSYM文件不存在"];
        return;
    }
    if(![_dsymPathField.stringValue.lowercaseString hasSuffix:@".dsym"])
    {
        [self errorLog:@"DSYM文件格式错误"];
        return;
    }
    if (![fileManager fileExistsAtPath:_appPathField.stringValue]) {
        [self errorLog:@"app文件不存在"];
        return;
    }
    if(![_appPathField.stringValue.lowercaseString hasSuffix:@".app"])
    {
        [self errorLog:@"app文件格式错误"];
        return;
    }
    NSString* dsynUUID = [self getUUID:_dsymPathField.stringValue];
    NSString* appUUID = [self getAppUUID:_appPathField.stringValue];
    if (dsynUUID&&dsynUUID.length>0&&[dsynUUID isEqualToString:appUUID]) {
        [self errorLog:[NSString stringWithFormat:@"UUID相同:%@",appUUID]];
    }
    else
    {
        [self errorLog:[NSString stringWithFormat:@"UUID不同:\nappUUID:%@\ndsynUUID:%@",appUUID,dsynUUID]];
    }
    
}
- (IBAction)saveBtnClicked:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        if (NSFileHandlingPanelOKButton == result) {
            NSString *filePath = [[savePanel URL] path];
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:[_resultView.string dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        }
    }];
}

#pragma mark 命令

- (NSString *)getAppUUID:(NSString *)filePath
{
    NSString* appPath = [self getRunnableAppPath:filePath];
    return [self getUUID:appPath];
}

- (NSString *)getRunnableAppPath:(NSString *)appPath
{
    NSRange leftPos = [appPath rangeOfString:@"/" options:NSBackwardsSearch];
    NSRange rightPos = [appPath rangeOfString:@".app"];
    
    if (leftPos.location == NSNotFound || rightPos.location == NSNotFound) {
        return nil;
    }
    
    NSRange range = NSMakeRange(leftPos.location + 1, rightPos.location - leftPos.location - 1);
    NSString *appName = [appPath substringWithRange:range];
    return [NSString stringWithFormat:@"%@/%@", appPath, appName];
}

- (NSString *)getUUID:(NSString *)filePath
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/dwarfdump"];
    
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:@"--uuid"];
    [arguments addObject:filePath];
    
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    if (result&&result.length>0&&[result hasPrefix:@"UUID:"]) {
        NSArray* array = [result componentsSeparatedByString:@" "];
        if (array&&array.count>2) {
            result = array[1];
        }
    }
    return result;
}

- (NSString *)getCrashUUID:(NSString *)filePath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self errorLog:@"crash文件路径不存在"];
        return @"";
    }
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    NSString *leftSymbol = @"Binary Images:\n";
    NSRange leftRange = [content rangeOfString:leftSymbol];
    content = [content substringFromIndex:leftRange.location+leftRange.length];
    
    content = [content componentsSeparatedByString:@"\n"][0];
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *result = [content componentsSeparatedByCharactersInSet:characterSet][1];
    return result;
}

- (BOOL)UUID:(NSString *)uuid1 isEqualtoUUID:(NSString *)uuid2
{
    if (uuid1 == nil || uuid2 == nil) {
        return NO;
    }
    uuid1 = [uuid1 stringByReplacingOccurrencesOfString:@"-" withString:@""].lowercaseString;
    uuid2 = [uuid2 stringByReplacingOccurrencesOfString:@"-" withString:@""].lowercaseString;
    return [uuid1 isEqualToString:uuid2];
}

- (NSString*)findSymbolicatecrash
{
    @synchronized(self)
    {
        NSString* symbolicatecrash = [[NSUserDefaults standardUserDefaults] objectForKey:sympath];
        if (symbolicatecrash && [[NSFileManager defaultManager] fileExistsAtPath:symbolicatecrash]) {
            return symbolicatecrash;
        }
        [self performSelectorOnMainThread:@selector(errorLog:) withObject:@"获取symbolicatecrash命令路径..." waitUntilDone:YES];
        NSTask *task;
        task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/find"];
        
        NSMutableArray *arguments = [NSMutableArray array];
        [arguments addObject:@"/Applications/Xcode.app"];
        [arguments addObject:@"-name"];
        [arguments addObject:@"symbolicatecrash"];
        [arguments addObject:@"-type"];
        [arguments addObject:@"f"];
        
        [task setArguments: arguments];
        
        NSPipe *pipe;
        pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        
        NSFileHandle *file;
        file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *data;
        data = [file readDataToEndOfFile];
        
        NSString *result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        symbolicatecrash = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self performSelectorOnMainThread:@selector(errorLog:) withObject:@"symbolicatecrash命令路径获取成功" waitUntilDone:YES];
        [[NSUserDefaults standardUserDefaults] setObject:symbolicatecrash forKey:sympath];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return symbolicatecrash;
    }
}

- (NSString*)analyse
{
    NSString* dsynUUID = [self getUUID:_dsymPathField.stringValue];
    NSString* crashUUID = [self getCrashUUID:_crashPathField.stringValue];
    [self errorLog:[NSString stringWithFormat:@"dsynUUID:%@",dsynUUID]];
    [self errorLog:[NSString stringWithFormat:@"crashUUID:%@",crashUUID]];
    if ([self UUID:dsynUUID isEqualtoUUID:crashUUID]) {
        [self errorLog:@"UUID相同"];
    }
    else
    {
        [self errorLog:@"UUID不同"];
    }

    
    
    [self performSelectorOnMainThread:@selector(errorLog:) withObject:@"执行symbolicatecrash命令..." waitUntilDone:YES];
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: [self findSymbolicatecrash]];
    [task setEnvironment:@{@"DEVELOPER_DIR":@"/Applications/Xcode.app/Contents/Developer"}];
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:_crashPathField.stringValue];
    [arguments addObject:_dsymPathField.stringValue];
    
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [self performSelectorOnMainThread:@selector(errorLog:) withObject:@"执行symbolicatecrash命令完毕" waitUntilDone:YES];
    [_resultView performSelectorOnMainThread:@selector(setString:) withObject:result waitUntilDone:YES];
    return result;
}




@end
