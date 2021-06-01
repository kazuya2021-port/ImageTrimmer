//
//  TrimMain.h
//  TrimmingTool
//
//  Created by uchiyama_Macmini on 2020/07/15.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ImageTrimDelegate <NSObject>
@optional
- (void)cropPageStart:(NSString*)savePath;
- (void)cropPageDone:(NSString*)croppedPath;
@end

@interface TrimMain : NSObject
@property (nonatomic, strong) id <ImageTrimDelegate> delegate;
- (NSArray*)getMentsukeInfo:(NSString*)path isSiagari:(BOOL)isSiagari;
- (BOOL)trimstart:(NSString*)path savePath:(NSString *)savePath saveNames:(NSArray *)saveNames cropAreas:(NSArray*)cropAreas;
@end
