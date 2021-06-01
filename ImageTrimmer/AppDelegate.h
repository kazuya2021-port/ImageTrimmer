//
//  AppDelegate.h
//  ImageTrimmer
//
//  Created by uchiyama_Macmini on 2020/07/16.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
+ (NSArray*)getTan16P_F:(int)ofst;
+ (NSArray*)getTan16P_B:(int)ofst;
+ (NSArray*)getTan8P:(int)ofst;
+ (NSArray*)getTan4P:(int)ofst;
+ (NSArray*)getTan2P:(int)ofst;
+ (NSArray*)getTan8P_F:(int)ofst;
+ (NSArray*)getTan8P_B:(int)ofst;
+ (NSArray*)getTan4P_F:(int)ofst;
+ (NSArray*)getTan4P_B:(int)ofst;
+ (NSArray*)getTan2P_F:(int)ofst;
+ (NSArray*)getTan2P_B:(int)ofst;

@end

