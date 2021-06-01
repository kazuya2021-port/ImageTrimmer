//
//  Progress.m
//  ImageTrimmer
//
//  Created by uchiyama_Macmini on 2020/08/03.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//

#import "Progress.h"

@interface Progress ()
@property (nonatomic, weak) IBOutlet NSProgressIndicator* prgAll;
@property (nonatomic, weak) IBOutlet NSProgressIndicator* prgIt;
@property (nonatomic, weak) IBOutlet NSTextField *txtAllMax;
@property (nonatomic, weak) IBOutlet NSTextField *txtItMax;
@property (nonatomic, weak) IBOutlet NSTextField *txtAllCur;
@property (nonatomic, weak) IBOutlet NSTextField *txtItCur;
@property (nonatomic, weak) IBOutlet NSTextField *txtLabel;
@end

@implementation Progress

- (id)init {
    if (self = [super initWithWindowNibName:[self className] owner:self]) {
        [self resetUI];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self resetUI];
}

- (void)resetUI
{
    _prgAll.indeterminate = NO;
    _prgAll.maxValue = 0;
    _prgAll.doubleValue = 0;
    _prgIt.indeterminate = NO;
    _prgIt.maxValue = 0;
    _prgIt.doubleValue = 0;
    _txtAllMax.stringValue = @"";
    _txtItMax.stringValue = @"";
    _txtAllCur.stringValue = @"";
    _txtItCur.stringValue = @"";
    _txtLabel.stringValue = @"";
}

- (void)resetMenCount
{
    _txtItMax.stringValue = @"";
    _txtItCur.stringValue = @"";
    _prgIt.indeterminate = NO;
    _prgIt.maxValue = 0;
    _prgIt.doubleValue = 0;
}

- (void)setAllMenCount:(NSString*)allmen
{
    _prgIt.maxValue = allmen.doubleValue;
    _txtItMax.stringValue = allmen;
    [_txtItMax displayIfNeeded];
}

- (void)setAllFileCount:(NSString*)allfilecount
{
    _prgAll.maxValue = allfilecount.doubleValue;
    _txtAllMax.stringValue = allfilecount;
    [_txtAllMax displayIfNeeded];
}

- (void)incrementMenCount
{
    [_prgIt incrementBy:1];
    _txtItCur.stringValue = [NSString stringWithFormat:@"%.0f",_prgIt.doubleValue];
    [_txtItCur displayIfNeeded];
//    if (_prgAll.maxValue == _prgAll.doubleValue && _prgIt.maxValue == _prgIt.doubleValue) {
//        [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
//    }
}

- (void)incrementFileCount
{
    [_prgAll incrementBy:1];
    _txtAllCur.stringValue = [NSString stringWithFormat:@"%.0f",_prgAll.doubleValue];
    [_txtAllCur displayIfNeeded];
}

- (void)changeLabel:(NSString*)label
{
    _txtLabel.stringValue = label;
    [_txtLabel displayIfNeeded];
}

- (void)closeDialog
{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (double)getCurFileCount
{
    return _prgAll.doubleValue;
}

- (double)getMaxFileCount
{
    return _prgAll.maxValue;
}

- (double)getCurMenCount
{
    return _prgIt.doubleValue;
}

- (double)getMaxMenCount
{
    return _prgIt.maxValue;
}
@end
