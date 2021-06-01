//
//  TRSettingObject.m
//  ImageTrimmer
//
//  Created by uchiyama_Macmini on 2020/07/22.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//

#import "TRSettingObject.h"

@implementation TRSettingObject
- (instancetype)init
{
    self = [super init];
    if(!self) return nil;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *load = [ud objectForKey:@"TomboArea"];
    _tomboArea = (!load)? @"30" : load;
    load = [ud objectForKey:@"RemDust"];
    _remDust = (!load)? @"8" : load;
    load = [ud objectForKey:@"Ratio"];
    _ratio = (!load)? @"50" : load;
    NSNumber *loadBool = [ud objectForKey:@"isDonTen"];
    _isDonTen = ([loadBool compare:@YES] == NSOrderedSame)? YES : NO;
    loadBool = [ud objectForKey:@"isSiagari"];
    _isSiagari = ([loadBool compare:@YES] == NSOrderedSame)? YES : NO;
    loadBool = [ud objectForKey:@"isLeftBind"];
    _isLeftBind = ([loadBool compare:@YES] == NSOrderedSame)? YES : NO;
    load = [ud objectForKey:@"StartPage"];
    _startPage = (!load)? @"1" : load;
    load = [ud objectForKey:@"AllPage"];
    _allPage = (!load)? @"" : load;
    load = [ud objectForKey:@"SavePath"];
    _savePath = (!load)? @"" : load;
    load = [ud objectForKey:@"Type"];
    _type = (!load)? @"" : load;
    load = [ud objectForKey:@"DanX"];
    _danXCount = (!load)? @"2" : load;
    load = [ud objectForKey:@"DanY"];
    _danYCount = (!load)? @"2" : load;
    return self;
}

+ (instancetype)sharedSetting
{
    static TRSettingObject *_sharedSetting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSetting = [[TRSettingObject alloc] init];
    });
    return _sharedSetting;
}
@end
