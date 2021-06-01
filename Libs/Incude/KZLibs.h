//
//  KZLibs.h
//  KZLibs
//
//  Created by 内山和也 on 2019/03/26.
//  Copyright (c) 2019年 内山和也. All rights reserved.
//

#include <stdio.h>
#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <NetFS/NetFS.h>
#import <DiskArbitration/DiskArbitration.h>

//#define MountainLion 108

#define FormatStr(...) [NSString stringWithFormat:__VA_ARGS__]
#define Log(str)    NSLog(@"\nsource: %s\n  func: %s\n  line: %d\n%@\n-----------\n", (strrchr(__FILE__, '/') ?: __FILE__ - 1) + 1, __FUNCTION__,__LINE__, str)
#define LogF(...)    NSLog(@"\nsource: %s\n  func: %s\n  line: %d\n%@\n-----------\n", (strrchr(__FILE__, '/') ?: __FILE__ - 1) + 1, __FUNCTION__,__LINE__, FormatStr(__VA_ARGS__))
#define EQ_STR(x,y) [x compare:y] == NSOrderedSame
#define NEQ_STR(x,y) [x compare:y] != NSOrderedSame
#define RESPATH [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources"]
@interface KZLibs : NSObject
// array func
+ (NSArray*)distinctArray:(NSArray*)array;

// number func
+ (NSString*)getRoundedStr:(double)value digit:(uint8)scale;
+ (NSString*)paddNumber:(int)keta num:(int)num;

// date func
+(NSString*)getNowDate:(NSString*)format;
+(NSString*)getSeirekiString:(NSString*)wareki;

// string func
+ (NSArray*)searchCharPosition:(NSString*)str searchChar:(NSString*)ch;
+ (BOOL)isExistString:(NSString*)str searchStr:(NSString*)searchStr;
+ (BOOL)isEqual:(NSString*)str compare:(NSString*)cmp;
+ (BOOL)isEqualC:(NSString*)str compare:(const char*)cmp;
+ (BOOL)isOnlyDecimalNumber:(NSString*)str;

// Unit Func
+ (double)mmToPixcel:(double)m dpi:(double)dpi;
+ (double)pixcelToMm:(double)p dpi:(double)dpi;

// file func
+ (void)makeFolder:(NSString*)root folderName:(NSString*)name;
+ (NSString*)getFileExt:(NSString*)path;
+ (NSString*)getFileName:(NSString*)path;
+ (NSString*)getCurDir:(NSString*)path;
+ (BOOL)isDirectory:(NSString *)path;
+ (BOOL)isFile:(NSString *)path;
+ (NSArray*)getFileList:(NSString *)atPath searchName:(NSString*)name onlyDir:(BOOL)onD onlyFile:(BOOL)onF;
+ (NSArray*)getFileList:(NSString *)path dirClass:(NSUInteger)dirClass onlyDir:(BOOL)onD;
+ (NSArray*)getFileList:(NSString *)path deep:(BOOL)deep onlyDir:(BOOL)onD onlyFile:(BOOL)onF isAllFullPath:(BOOL)isFullPath;
+ (NSString*)getFileModificateDate:(NSString*)path;
+ (NSImage*)getIcon:(NSString*)path isFileTypeIcon:(BOOL)isFType;
+ (NSString*)getFileSize:(NSString*)path;
+ (BOOL)forceDeleteFile:(NSString*)path;
+ (BOOL)forceMoveFile:(NSString*)atPath toPath:(NSString*)toPath;

// script func
+ (NSString*)doShellScript:(NSArray*)command;
+ (NSString*)doShellScriptWithEnv:(NSArray*)command envs:(NSDictionary*)dicEnv;

// dialog func
+ (BOOL)alertMessage:(NSString*)message info:(NSString*)info isOnlyAlert:(BOOL)isOnlyAlert window:(NSWindow*)window okTitle:(NSString*)okTitle ngTitle:(NSString*)ngTitle;
+ (BOOL)alertMessage:(NSString*)message info:(NSString*)info isOnlyAlert:(BOOL)isOnlyAlert window:(NSWindow*)window;
+(NSArray*)openFileDialog:(NSString*)title multiple:(BOOL)mp selectFile:(BOOL)selectFile selectDir:(BOOL)selectDir;
+(NSArray*)openFileDialog:(NSString*)title multiple:(BOOL)mp selectFile:(BOOL)selectFile selectDir:(BOOL)selectDir window:(NSWindow*)parent;

// NetFS func
+ (NSString*)getIfExistLocalVolumes:(NSString*)folderName;
+ (BOOL)mountSetver:(NSString*)serverAddress mountFolder:(NSString*)mountFolder user:(NSString*)user pass:(NSString*)pass;
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request error:(NSError **)error;
+ (BOOL)unmountVolumeAtURL:(NSURL *)url;
+ (void)unMountDisk:(NSString*)name;

// Image Func
+ (NSString*)getImageColor:(NSString*)path;
+ (NSUInteger)getPDFPageCount:(NSString*)path;
+ (NSSize)getPDFSizeMm:(NSString*)path;
+ (NSUInteger)getTIFFPageCount:(NSString*)path;
+ (NSData*)cvtCGImage2Data:(CGImageRef)rep;
+ (NSImage *)resizeImage:(NSImage *)sourceImage width:(float)resizeWidth height:(float)resizeHeight;
+ (BOOL)pdf2jpg:(NSData*)page path:(NSString*)savePath x:(int)x y:(int)y w:(int)w h:(int)h ratio:(double)ratio;
+ (void)captScreen:(NSRect)rect savePath:(NSString*)savePath;
+ (NSSize)getImageSize:(NSString*)src;

// Other Func
+ (BOOL)checkRectIsZero:(NSRect)src;
+ (BOOL)isEqualToSize:(NSSize)src destination:(NSSize)dest;
+ (NSWindow*)getMainWindow;
@end
