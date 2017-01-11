//
//  SFConverter.m
//  SubFixer
//
//  Created by Ahmad on 8/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "SFConverter.h"

@implementation SFConverter

static NSString *filePath;
static NSString *folderPath;
static NSString *fileName;
static NSString *tempFilePath;

+(void)checkDragAndFixSubtitle:(id<NSDraggingInfo>)sender {
    
    NSArray *filesPath = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    
    NSString *filePath = [filesPath lastObject];
    
    NSString *fileExtension = filePath.pathExtension;
    
    if (![fileExtension isEqualToString:@"srt"]) {
        
        [SFConverter postMessage:@"Only SRT files are supported"];
        return;
    }
    
    [SFConverter fixSubtitleAtPath:filePath];
    
}

+(void)postMessage:(NSString *)message {
    
    NSDictionary *userInfo = @{@"Message":message};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeMessageLabelText" object:nil userInfo:userInfo];
    
}

+(void)fixSubtitleAtPath:(NSString *)path {
    
    [SFConverter postMessage:@"Please wait..."];
    
    filePath = [NSString stringWithString:path];
    folderPath = [filePath stringByDeletingLastPathComponent];
    fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    
    // to have a backup
    NSError *moveError;
    NSString *newTarget = [[[folderPath stringByAppendingPathComponent:fileName] stringByAppendingString:@"-backup"] stringByAppendingPathExtension:@"srt"];
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:newTarget error:&moveError];
    
    if (moveError) {
        [SFConverter postMessage:moveError.localizedDescription];
        return;
    }
    
    tempFilePath = [[folderPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"txt"];
    
    NSError *copyError;
    [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:tempFilePath error:&copyError];
    
    if (copyError) {
        [SFConverter postMessage:copyError.localizedDescription];
        return;
    }
    
    WebView *webView = [[WebView alloc] init];
    webView.customTextEncodingName = @"Windows-1256";
    webView.frameLoadDelegate = (id)self;
    [webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:tempFilePath]]];
}

+(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
    
    NSString *fixedSubtitle = [[[frame dataSource] representation] documentSource];
    
    NSString *fixedFilePath = [[folderPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"srt"];
    [fixedSubtitle writeToFile:fixedFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [SFConverter postMessage:@"Fixed file replaced with previous one"];
    
}

@end
