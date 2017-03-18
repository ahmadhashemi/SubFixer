//
//  SFConverter.m
//  SubFixer
//
//  Created by Ahmad on 8/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "SFConverter.h"

@implementation SFConverter

static NSMutableArray *filesPathArray;
static NSString *filePath;
static NSString *folderPath;
static NSString *fileName;
static NSString *tempFilePath;

+(void)checkDragAndFixSubtitle:(id<NSDraggingInfo>)sender {
    
    NSArray *pathArray = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSMutableArray *filesPath = [[NSMutableArray alloc] init];
    
    
    for (NSString *path in pathArray) {
        NSString *fileExtension = path.pathExtension;
        
        if (![fileExtension isEqualToString:@"srt"]) {
            BOOL isDir;
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
            if (exists) {
                /* file exists */
                if (isDir) {
                    /* file is a directory */
                    NSArray * dir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
                    for (NSString *fileName in dir) {
                        NSString *combinedPath = [NSString stringWithFormat:@"%@%@%@", path, @"/", fileName];
                        [filesPath addObject: combinedPath];
                    }
                }
            }
        }
        else {
            [filesPath addObject: path];
        }
    }
    
    filesPathArray = [[NSMutableArray alloc] init];
    for (NSString *filePath in filesPath) {
        NSString *fileExtension = filePath.pathExtension;
        if ([fileExtension isEqualToString:@"srt"]) {
            [filesPathArray addObject:filePath];
        }
    }
    [SFConverter checkArrayAndFixSubtitle];
    
}


+(void)checkArrayAndFixSubtitle {
    
    if (filesPathArray.count == 0) {
        [SFConverter postMessage:@"Fixed files and replaced with previous ones"];
        return;
    }
    
    NSString *filePath = [filesPathArray firstObject];
    
    
    [filesPathArray removeObject:filePath];
    [SFConverter fixSubtitleAtPath:filePath];
}

+(void)postMessage:(NSString *)message {
    
    NSDictionary *userInfo = @{@"Message":message};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeMessageLabelText" object:nil userInfo:userInfo];
    
}

+(void)fixSubtitleAtPath:(NSString *)path {
    
    [SFConverter postMessage:@"Please wait..."];
    
    if ([SFConverter checkIfEncodeIsUTF8String: path]) {
        [SFConverter checkArrayAndFixSubtitle];
        return;
    }
    
    filePath = [NSString stringWithString:path];
    folderPath = [filePath stringByDeletingLastPathComponent];
    fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    
    // to have a backup
    NSError *moveError;
    NSString *newTarget = [[[folderPath stringByAppendingPathComponent:fileName] stringByAppendingString:@"-backup"] stringByAppendingPathExtension:@"srt"];
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:newTarget error:&moveError];
    filePath = newTarget;
    
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


+(BOOL)checkIfEncodeIsUTF8String:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSData * urlData = [NSData dataWithContentsOfURL:url];
    NSString * isUTF8String = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    if (isUTF8String) {
        return YES;
    }
    return NO;
}





+(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
    
    NSString *fixedSubtitle = [[[frame dataSource] representation] documentSource];
    
    NSString *fixedFilePath = [[folderPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"srt"];
    [fixedSubtitle writeToFile:fixedFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [SFConverter checkArrayAndFixSubtitle];
    
}

@end
