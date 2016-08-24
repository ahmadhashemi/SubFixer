//
//  SFConverter.h
//  SubFixer
//
//  Created by Ahmad on 8/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface SFConverter : NSObject <WebFrameLoadDelegate>

+(void)checkDragAndFixSubtitle:(id<NSDraggingInfo>)sender;
+(void)fixSubtitleAtPath:(NSString *)filePath;

@end
