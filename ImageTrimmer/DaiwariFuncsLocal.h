//
//  DaiwariFuncsLocal.h
//  ImageTrimmer
//
//  Created by uchiyama_Macmini on 2020/07/16.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DaiwariFuncsLocal : NSObject
+(NSDictionary*)calcDaiNum:(NSInteger)totalPage type:(NSString*)type;
+(NSArray*)arrangeDai:(NSDictionary*)dai type:(NSString*)type isTandoku:(BOOL)isTandoku;
@end
