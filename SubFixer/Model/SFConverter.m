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
        
        [SFConverter postMessage:@"Only SRT Files Are Supported"];
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
    tempFilePath = [[folderPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"txt"];
    
    NSError *copyError;
    [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:tempFilePath error:&copyError];
    
    if (copyError) {
        NSLog(@"%@",copyError.userInfo);
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
    
    [SFConverter postMessage:@"Fixed File Replaced With Previous One"];
    
}

@end
