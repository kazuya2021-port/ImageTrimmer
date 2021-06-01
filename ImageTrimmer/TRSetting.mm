//
//  TRSetting.m
//  ImageTrimmer
//
//  Created by uchiyama_Macmini on 2020/07/22.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//

#import "TRSetting.h"

@interface TRSetting () <NSControlTextEditingDelegate, NSTextFieldDelegate>
@property (nonatomic, weak) IBOutlet NSTextField *txtTomboArea;
@property (nonatomic, weak) IBOutlet NSTextField *txtRemDust;
@property (nonatomic, weak) IBOutlet NSTextField *txtRatio;
@property (nonatomic, weak) IBOutlet NSButton *isDonTen;
@property (nonatomic, weak) IBOutlet NSButton *isSiagari;
@property (nonatomic, weak) IBOutlet NSButton *isLeftBind;

@property (nonatomic, weak) IBOutlet NSTextField *saveField;
@property (nonatomic, weak) IBOutlet NSTextField *pageField;
@property (nonatomic, weak) IBOutlet NSTextField *startField;
@property (nonatomic, weak) IBOutlet NSComboBox *typeBox;

@property (nonatomic, weak) IBOutlet NSTextField *danX;
@property (nonatomic, weak) IBOutlet NSTextField *danY;
@end

@implementation TRSetting
- (instancetype)init
{
    self = [super init];
    if(!self) return nil;
    TRSettingObject *obj = TRSet;
    return self;
}

- (void)awakeFromNib
{
    _txtTomboArea.stringValue = TRSet.tomboArea;
    _txtRemDust.stringValue = TRSet.remDust;
    _txtRatio.stringValue = TRSet.ratio;
    _saveField.stringValue = TRSet.savePath;
    _pageField.stringValue = TRSet.allPage;
    _startField.stringValue = TRSet.startPage;
    _typeBox.stringValue = TRSet.type;
    _danX.stringValue = TRSet.danXCount;
    _danY.stringValue = TRSet.danYCount;
    _isDonTen.state = (TRSet.isDonTen)? NSOnState : NSOffState;
    _isSiagari.state = (TRSet.isSiagari)? NSOnState : NSOffState;
    _isLeftBind.state = (TRSet.isLeftBind)? NSOnState : NSOffState;
    _txtTomboArea.delegate = self;
    _txtRemDust.delegate = self;
    _txtRatio.delegate = self;
    _saveField.delegate = self;
    _pageField.delegate = self;
    _startField.delegate = self;
    _danX.delegate = self;
    _danY.delegate = self;
    _isSiagari.target = self;
    _typeBox.target = self;
    _isDonTen.target = self;
    _isLeftBind.target = self;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    NSTextField* control = (NSTextField*)obj.object;
    NSString *fieldString = control.stringValue.precomposedStringWithCanonicalMapping;
    control.stringValue = fieldString;
    
    if (EQ_STR(control.identifier, @"TomboArea")) {
        TRSet.tomboArea = fieldString;
        [self saveUserDefault:fieldString key:@"TomboArea"];
    }
    if (EQ_STR(control.identifier, @"RemDust")) {
        TRSet.remDust = fieldString;
        [self saveUserDefault:fieldString key:@"RemDust"];
    }
    if (EQ_STR(control.identifier, @"Ratio")) {
        TRSet.ratio = fieldString;
        [self saveUserDefault:fieldString key:@"Ratio"];
    }
    if (EQ_STR(control.identifier, @"StartPage")) {
        TRSet.startPage = fieldString;
        [self saveUserDefault:fieldString key:@"StartPage"];
    }
    if (EQ_STR(control.identifier, @"AllPage")) {
        TRSet.allPage = fieldString;
        [self saveUserDefault:fieldString key:@"AllPage"];
    }
    if (EQ_STR(control.identifier, @"SavePath")) {
        TRSet.savePath = fieldString;
        [self saveUserDefault:fieldString key:@"SavePath"];
    }
    if (EQ_STR(control.identifier, @"DanX")) {
        TRSet.danXCount = fieldString;
        [self saveUserDefault:fieldString key:@"DanX"];
    }
    if (EQ_STR(control.identifier, @"DanY")) {
        TRSet.danYCount = fieldString;
        [self saveUserDefault:fieldString key:@"DanY"];
    }
}

- (IBAction)selectType:(id)sender
{
    NSComboBox *box = sender;
    NSString *title = [[box selectedCell] title];
    TRSet.type = title;
    [self saveUserDefault:title key:@"Type"];
}

- (IBAction)checkLeftBind:(id)sender
{
    BOOL state = (_isLeftBind.state == NSOnState);
    TRSet.isLeftBind = (state)? YES : NO;
    [self saveUserDefaultBool:state key:@"isLeftBind"];
}

- (IBAction)checkDonten:(id)sender
{
    BOOL state = (_isDonTen.state == NSOnState);
    TRSet.isDonTen = (state)? YES : NO;
    [self saveUserDefaultBool:state key:@"isDonTen"];
}

- (IBAction)checkSiagari:(id)sender
{
    BOOL state = (_isSiagari.state == NSOnState);
    TRSet.isSiagari = (state)? YES : NO;
    [self saveUserDefaultBool:state key:@"isSiagari"];
}

- (void)saveUserDefault:(id)obj key:(NSString*)key
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:obj forKey:key];
    [ud synchronize];
}

- (void)saveUserDefaultBool:(BOOL)obj key:(NSString*)key
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:obj forKey:key];
    [ud synchronize];
}

@end
