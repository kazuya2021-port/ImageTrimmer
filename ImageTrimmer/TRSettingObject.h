//
//  TRSettingObject.h
//  ImageTrimmer
//
//  Created by uchiyama_Macmini on 2020/07/22.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRSettingObject : NSObject
+ (instancetype)sharedSetting;
@property (nonatomic, copy) NSString *tomboArea;
@property (nonatomic, copy) NSString *remDust;
@property (nonatomic, copy) NSString *ratio;
@property (nonatomic, copy) NSString *startPage;
@property (nonatomic, copy) NSString *allPage;
@property (nonatomic, copy) NSString *savePath;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *danXCount;
@property (nonatomic, copy) NSString *danYCount;
@property (assign) BOOL isDonTen;
@property (assign) BOOL isLeftBind;
@property (assign) BOOL isSiagari;
@end
