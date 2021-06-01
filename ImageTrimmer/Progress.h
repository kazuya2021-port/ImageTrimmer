//
//  Progress.h
//  ImageTrimmer
//
//  Created by uchiyama_Macmini on 2020/08/03.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Progress : NSWindowController
- (void)resetUI;
- (void)resetMenCount;
- (void)setAllMenCount:(NSString*)allmen;
- (void)setAllFileCount:(NSString*)allfilecount;
- (void)incrementMenCount;
- (void)incrementFileCount;
- (void)changeLabel:(NSString*)label;
- (void)closeDialog;
- (double)getCurFileCount;
- (double)getMaxFileCount;
- (double)getCurMenCount;
- (double)getMaxMenCount;
@end
