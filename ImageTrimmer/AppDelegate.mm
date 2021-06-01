//
//  AppDelegate.m
//  ImageTrimmer
//
//  Created by uchiyama_Macmini on 2020/07/16.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//
#import "TrimMain.h"
#import "AppDelegate.h"
#import "DaiwariFuncsLocal.h"
#import "TRSetting.h"
#import "Progress.h"

@interface AppDelegate () <NSTableViewDelegate, NSTableViewDataSource, ImageTrimDelegate>
@property (nonatomic, strong) TrimMain *trim;
@property (nonatomic, strong) NSMutableArray *dbSource;
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *tblFiles;

@property (nonatomic, weak) IBOutlet NSButton *btnClear;
@property (nonatomic, weak) IBOutlet NSButton *btnGo;

@property (nonatomic, weak) IBOutlet TRSetting *trs;
@property (nonatomic, strong) IBOutlet Progress *prog;

@property (nonatomic, weak) IBOutlet NSPanel *logView;
@property (nonatomic, strong) IBOutlet NSTextView *logTextView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _dbSource = [@[] mutableCopy];
    _tblFiles.delegate = self;
    _tblFiles.dataSource = self;
    [_tblFiles registerForDraggedTypes:@[NSFilenamesPboardType]];
    
    _trim = [[TrimMain alloc] init];
    _trim.delegate = self;
    _prog = [[Progress alloc] init];
    _logTextView.string = @"";
    _logTextView.font = [NSFont fontWithName:@"Osaka-Mono" size:12];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark -
#pragma mark Local Funcs
- (void)appendLog:(NSString*)str
{
    NSDate *n = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd HH:mm";
    NSString *date24 = [dateFormatter stringFromDate:n];
    NSMutableString *strLog = [_logTextView.string mutableCopy];
    [strLog appendFormat:@"%@ %@\n",date24,str];
    _logTextView.string = [strLog copy];
    [_logTextView scrollToEndOfDocument:self];
}

+ (NSArray*)getTan16P_F:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst]];
    [ar addObject:[NSNumber numberWithInt:ofst+15]];
    [ar addObject:[NSNumber numberWithInt:ofst+12]];
    [ar addObject:[NSNumber numberWithInt:ofst+3]];
    [ar addObject:[NSNumber numberWithInt:ofst+7]];
    [ar addObject:[NSNumber numberWithInt:ofst+8]];
    [ar addObject:[NSNumber numberWithInt:ofst+11]];
    [ar addObject:[NSNumber numberWithInt:ofst+4]];
    return [ar copy];
}
+ (NSArray*)getTan16P_B:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst+2]];
    [ar addObject:[NSNumber numberWithInt:ofst+13]];
    [ar addObject:[NSNumber numberWithInt:ofst+14]];
    [ar addObject:[NSNumber numberWithInt:ofst+1]];
    [ar addObject:[NSNumber numberWithInt:ofst+5]];
    [ar addObject:[NSNumber numberWithInt:ofst+10]];
    [ar addObject:[NSNumber numberWithInt:ofst+9]];
    [ar addObject:[NSNumber numberWithInt:ofst+6]];

    return [ar copy];
}
+ (NSArray*)getTan8P:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst]];
    [ar addObject:[NSNumber numberWithInt:ofst+7]];
    [ar addObject:[NSNumber numberWithInt:ofst+6]];
    [ar addObject:[NSNumber numberWithInt:ofst+1]];
    [ar addObject:[NSNumber numberWithInt:ofst+3]];
    [ar addObject:[NSNumber numberWithInt:ofst+4]];
    [ar addObject:[NSNumber numberWithInt:ofst+5]];
    [ar addObject:[NSNumber numberWithInt:ofst+2]];

    return [ar copy];
}
+ (NSArray*)getTan4P:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst]];
    [ar addObject:[NSNumber numberWithInt:ofst+3]];
    [ar addObject:[NSNumber numberWithInt:ofst+1]];
    [ar addObject:[NSNumber numberWithInt:ofst+2]];
    return [ar copy];
}
+ (NSArray*)getTan2P:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst]];
    [ar addObject:[NSNumber numberWithInt:ofst+1]];
    return [ar copy];
}
+ (NSArray*)getTan8P_F:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst]];
    [ar addObject:[NSNumber numberWithInt:ofst+7]];
    [ar addObject:[NSNumber numberWithInt:ofst+3]];
    [ar addObject:[NSNumber numberWithInt:ofst+4]];
    return [ar copy];
}
+ (NSArray*)getTan8P_B:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst+6]];
    [ar addObject:[NSNumber numberWithInt:ofst+1]];
    [ar addObject:[NSNumber numberWithInt:ofst+5]];
    [ar addObject:[NSNumber numberWithInt:ofst+2]];
    
    return [ar copy];
}
+ (NSArray*)getTan4P_F:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst]];
    [ar addObject:[NSNumber numberWithInt:ofst+3]];
    return [ar copy];
}
+ (NSArray*)getTan4P_B:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst+1]];
    [ar addObject:[NSNumber numberWithInt:ofst+2]];
    return [ar copy];
}
+ (NSArray*)getTan2P_F:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst]];
    return [ar copy];
}
+ (NSArray*)getTan2P_B:(int)ofst
{
    NSMutableArray* ar = [NSMutableArray array];
    [ar addObject:[NSNumber numberWithInt:ofst+1]];
    return [ar copy];
}

#pragma mark -
#pragma mark Actions

- (IBAction)clearTables:(id)sender
{
    _dbSource = [NSMutableArray array];
    [_tblFiles reloadData];
    [_prog resetUI];
}

- (IBAction)goTrim:(id)sender
{
    [_prog resetUI];
    if (_dbSource.count == 0) {
        [KZLibs alertMessage:@"ファイルを登録してください" info:@"" isOnlyAlert:YES window:self.window];
        return;
    }
    NSString *name = _dbSource[0][@"name"];

    // 保存先が未指定なら書類フォルダを設定
    if (EQ_STR(TRSet.savePath, @"")) {
        TRSet.savePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] precomposedStringWithCanonicalMapping];
    }
    
    NSString *savePath = TRSet.savePath;
    
    if (![KZLibs isDirectory:savePath]) {
        savePath = [savePath stringByDeletingLastPathComponent];
    }
    
    savePath = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_出力",name]];
    
    if (![NSFileManager.defaultManager fileExistsAtPath:savePath]) {
        [NSFileManager.defaultManager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    dispatch_queue_t serialQueue = dispatch_queue_create("asahi.kazuya.trtool.trimmain", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t main = dispatch_get_main_queue();
    __block BOOL isContinue = YES;
    int pageNum = TRSet.allPage.intValue;
    NSString *type = TRSet.type;
    int offsetPage = TRSet.startPage.intValue;
    BOOL isTanDoku = TRSet.isDonTen;
    
    dispatch_async(serialQueue, ^{
        NSMutableArray* arSavenames = [@[] mutableCopy];
        dispatch_sync(main, ^{
            [self appendLog:[NSString stringWithFormat:@"保存ファイル名の生成"]];
        });
        if (EQ_STR(type, TYPE_TANKOU_HASUU)) {
            
            NSDictionary* daiNum = [DaiwariFuncsLocal calcDaiNum:pageNum type:@"単行本"];
            NSArray* arranged = [DaiwariFuncsLocal arrangeDai:daiNum type:type isTandoku:isTanDoku];
            int allDai = [daiNum[@"台数"] intValue];
            int curTop = offsetPage;
            for (int dai = 0; dai < allDai; dai++) {
                NSMutableArray *aFileNames = [@[] mutableCopy];
                NSMutableArray *bFileNames = [@[] mutableCopy];
                // 表裏の順番
                NSString *layName = arranged[dai];
                if (EQ_STR(layName, @"16P表裏")) {
                    NSArray *f = [AppDelegate getTan16P_F:curTop];
                    for (int i = 0; i < f.count; i++) {
                        [aFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[f[i] intValue]]]];
                    }
                    NSArray *b = [AppDelegate getTan16P_B:curTop];
                    for (int i = 0; i < b.count; i++) {
                        [bFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[b[i] intValue]]]];
                    }
                    [arSavenames addObject:@{@"F" : aFileNames, @"B" : bFileNames}];
                    curTop += 16;
                }
                else if (EQ_STR(layName, @"8P表裏")) {
                    NSArray *f = [AppDelegate getTan8P_F:curTop];
                    for (int i = 0; i < f.count; i++) {
                        [aFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[f[i] intValue]]]];
                    }
                    NSArray *b = [AppDelegate getTan8P_B:curTop];
                    for (int i = 0; i < b.count; i++) {
                        [bFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[b[i] intValue]]]];
                    }
                    [arSavenames addObject:@{@"F" : aFileNames, @"B" : bFileNames}];
                    curTop += 8;
                }
                else if (EQ_STR(layName, @"8P単独")) {
                    NSArray *f = [AppDelegate getTan8P:curTop];
                    for (int i = 0; i < f.count; i++) {
                        [aFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[f[i] intValue]]]];
                    }
                    [arSavenames addObject:@{@"F" : aFileNames}];
                    curTop += 8;
                }
                else if (EQ_STR(layName, @"4P表裏")) {
                    NSArray *f = [AppDelegate getTan4P_F:curTop];
                    for (int i = 0; i < f.count; i++) {
                        [aFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[f[i] intValue]]]];
                    }
                    NSArray *b = [AppDelegate getTan4P_B:curTop];
                    for (int i = 0; i < b.count; i++) {
                        [bFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[b[i] intValue]]]];
                    }
                    [arSavenames addObject:@{@"F" : aFileNames, @"B" : bFileNames}];
                    curTop += 4;
                }
                else if (EQ_STR(layName, @"4P単独")) {
                    NSArray *f = [AppDelegate getTan4P:curTop];
                    for (int i = 0; i < f.count; i++) {
                        [aFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[f[i] intValue]]]];
                    }
                    [arSavenames addObject:@{@"F" : aFileNames}];
                    curTop += 4;
                }
                else if (EQ_STR(layName, @"2P表裏")) {
                    NSArray *f = [AppDelegate getTan2P_F:curTop];
                    for (int i = 0; i < f.count; i++) {
                        [aFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[f[i] intValue]]]];
                    }
                    NSArray *b = [AppDelegate getTan2P_B:curTop];
                    for (int i = 0; i < b.count; i++) {
                        [bFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[b[i] intValue]]]];
                    }
                    [arSavenames addObject:@{@"F" : aFileNames, @"B" : bFileNames}];
                    curTop += 2;
                }
                else if (EQ_STR(layName, @"2P単独")) {
                    NSArray *f = [AppDelegate getTan2P:curTop];
                    for (int i = 0; i < f.count; i++) {
                        [aFileNames addObject:[NSString stringWithFormat:@"%@_P%@.tif",name,[KZLibs paddNumber:3 num:[f[i] intValue]]]];
                    }
                    [arSavenames addObject:@{@"F" : aFileNames}];
                    curTop += 2;
                }
            }
#ifdef DEBUG
#else
            int allDai = [daiNum[@"枚数"] intValue];
            if ((int)(_dbSource.count) != allDai) {
                dispatch_sync(main, ^{
                    isContinue = NO;
                    [KZLibs alertMessage:@"台の数が正しくありません" info:@"PDFの個数を確認してください" isOnlyAlert:YES window:self.window];
                    return;
                });
                if (!isContinue) return;
            }
#endif
        }

        dispatch_async(main, ^{
            [self.window beginSheet:_prog.window completionHandler:^(NSModalResponse returnCode) {
                switch (returnCode) {
                    case NSModalResponseOK:
                        Log(@"OK");
                        break;
                }
            }];
            [_prog setAllFileCount:[NSString stringWithFormat:@"%lu", [_dbSource count]]];
        });
        
        for (int row = 0; row < _dbSource.count; row++) {
            dispatch_async(main, ^{
                [_prog incrementFileCount];
                [_prog resetMenCount];
            });
            NSDictionary *info = _dbSource[row];
            int daiNum = [info[@"daiNum"] intValue];
            NSDictionary *tblNames = arSavenames[daiNum-1];
            dispatch_async(main, ^{
                [_prog setAllMenCount:[NSString stringWithFormat:@"%lu", [tblNames[info[@"fb"]] count]]];
                [_prog incrementMenCount];
                NSString *fname = [[info[@"path"] lastPathComponent] stringByDeletingPathExtension];
                [_prog changeLabel:[NSString stringWithFormat:@"%@ : トンボ解析開始",fname]];
                [self appendLog:[NSString stringWithFormat:@"%@-トンボ解析開始", fname]];
            });
            @autoreleasepool {
                
                if (EQ_STR(type, TYPE_TANKOU_HASUU)) {
                    
                    
                    NSArray *arCrops = [_trim getMentsukeInfo:info[@"path"] isSiagari:TRSet.isSiagari];
                    
                    if (arCrops.count == 1 && [arCrops[0] isKindOfClass:[NSString class]]) {
                        dispatch_async(main, ^{
                            [_prog closeDialog];
                            [KZLibs alertMessage:@"トンボ解析エラー" info:@"アプリの担当者に確認してください" isOnlyAlert:YES window:self.window];
                            NSString *fname = [[info[@"path"] lastPathComponent] stringByDeletingPathExtension];
                            [self appendLog:[NSString stringWithFormat:@"%@-解析エラー:%@", fname, arCrops[0]]];
                        });
                    }
                    
                    dispatch_async(main, ^{
                        NSString *fname = [[info[@"path"] lastPathComponent] stringByDeletingPathExtension];
                        [_prog changeLabel:[NSString stringWithFormat:@"%@ : トンボ解析終了",fname]];
                        [self appendLog:[NSString stringWithFormat:@"%@-トンボ解析終了", fname]];
                    });
                    
                    if (![_trim trimstart:info[@"path"] savePath:savePath saveNames:tblNames[info[@"fb"]] cropAreas:arCrops]) {
                        dispatch_async(main, ^{
                            [_prog closeDialog];
                            [KZLibs alertMessage:@"検出された面数と実際の面数が違います" info:@"アプリの担当者に確認してください" isOnlyAlert:YES window:self.window];
                            NSString *fname = [[info[@"path"] lastPathComponent] stringByDeletingPathExtension];
                            [self appendLog:[NSString stringWithFormat:@"%@-切り出しエラー:面数違い", fname]];
                        });
                        return;
                    }
                }
            }
        }
    });
    if (!isContinue) {
        [self.window close];
    }
}

#pragma mark -
#pragma mark DataSource From Table
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _dbSource.count;
}

#pragma mark -
#pragma mark Delegate From Table

- (NSDictionary*)getInfoFromFile:(NSString*)path
{
    NSString *fileLast = [path lastPathComponent];
    NSString *fname = [fileLast stringByDeletingPathExtension];
    NSArray *spt = [fname componentsSeparatedByString:@"_"];
    if (spt.count <= 1) return nil;
    
    NSString *name = spt[0];
    NSString *tmp = spt[1];
    BOOL isF = NO;
    BOOL isOriStr = NO;
    NSRange rngOri = [tmp rangeOfString:@"折"];
    NSRange rngFB = [tmp rangeOfString:@"表"];
    if (rngFB.location == NSNotFound) {
        rngFB = [tmp rangeOfString:@"裏"];
        if (rngFB.location == NSNotFound) {
            rngFB = [tmp rangeOfString:@"F"];
            if (rngFB.location == NSNotFound) {
                rngFB = [tmp rangeOfString:@"B"];
                if (rngFB.location != NSNotFound) {
                    isF = NO;
                }
            }
            else {
                isF = YES;
            }
        }
        else {
            isF = NO;
            isOriStr = YES;
        }
    }
    else {
        isF = YES;
        isOriStr = YES;
    }
    
    NSMutableDictionary *retDic = [@{} mutableCopy];
    [retDic setObject:name forKey:@"name"];
    [retDic setObject:path forKey:@"path"];
    NSString *daiStr = [tmp substringToIndex:rngFB.location];
    if (isOriStr) {
        daiStr = [tmp substringToIndex:rngFB.location-1];
    }
    
    [retDic setObject:[NSNumber numberWithInt:[daiStr intValue]]
               forKey:@"daiNum"];
    [retDic setObject:(isF)? @"F" : @"B"
               forKey:@"fb"];
    return [retDic copy];

}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    if (row > _dbSource.count || row < 0) {
        return NSDragOperationNone;
    }
    
    if (!info.draggingSource) {
        return NSDragOperationCopy;
    }
    else if (info.draggingSource == self) {
        return NSDragOperationNone;
    }
    else if (info.draggingSource == tableView) {
        [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
        return NSDragOperationMove;
    }
    return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pb = info.draggingPasteboard;
    NSArray *arTypes = pb.types;
    
    NSMutableArray *theDatas = [_dbSource mutableCopy];
    
    for (NSString *type in arTypes) {
        if ([KZLibs isEqual:type compare:NSFilenamesPboardType]) {
            // File Drop To Table View
            NSData *data = [pb dataForType:NSFilenamesPboardType];
            NSError *error;
            NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
            NSArray *theFiles = [NSPropertyListSerialization
                                 propertyListWithData:data
                                 options:(NSPropertyListReadOptions)NSPropertyListImmutable
                                 format:&format
                                 error:&error];
            if (error) {
                LogF(@"get file property error : %@", error.description);
                break;
            }
            if (!theFiles) {
                Log(@"get file property error");
                break;
            }
            
            for (NSUInteger i = 0; i < theFiles.count; i++) {
                if ([KZLibs isDirectory:theFiles[i]]) {
                    NSArray *arFiles = [KZLibs getFileList:theFiles[i] deep:NO onlyDir:NO onlyFile:YES isAllFullPath:YES];
                    for (NSString* file in arFiles) {
                        NSDictionary *d = [self getInfoFromFile:file];
                        if (d) {
                            [theDatas addObject:d];
                        }
                    }
                }
                else {
                    NSDictionary *d = [self getInfoFromFile:theFiles[i]];
                    if (d) {
                        [theDatas addObject:d];
                    }
                }
            }
            
            NSSortDescriptor *descNum = [NSSortDescriptor sortDescriptorWithKey:@"daiNum" ascending:YES];
            NSSortDescriptor *descFB = [NSSortDescriptor sortDescriptorWithKey:@"fb" ascending:NO];
            [theDatas sortUsingDescriptors:@[descNum,descFB]];
            _dbSource = [theDatas mutableCopy];
            [_prog resetUI];
            [tableView reloadData];
        }
    }
    return YES;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier = tableColumn.identifier;
    NSTableCellView *cell = nil;
    cell = [tableView makeViewWithIdentifier:identifier owner:self];
    cell.textField.stringValue = _dbSource[row][identifier];
    
    return cell;
}


#pragma mark -
#pragma mark Delegate From TrimMain
- (void)cropPageStart:(NSString*)savePath
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSString *name = _dbSource[0][@"name"];
        NSString *fname = [savePath lastPathComponent];
        fname = [fname stringByDeletingPathExtension];
        fname = [fname stringByReplacingOccurrencesOfString:name withString:@""];
        fname = [fname stringByReplacingOccurrencesOfString:@"_" withString:@""];
        [_prog changeLabel:[NSString stringWithFormat:@"%@ : 切り出し開始",fname]];
        [self appendLog:[NSString stringWithFormat:@"%@-切り出し開始", fname]];
        if ([NSFileManager.defaultManager fileExistsAtPath:savePath]) {
            [NSFileManager.defaultManager trashItemAtURL:[NSURL fileURLWithPath:savePath] resultingItemURL:nil error:nil];
        }
    });
}

- (void)cropPageDone:(NSString*)croppedPath
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSString *name = _dbSource[0][@"name"];
        NSString *fname = [croppedPath lastPathComponent];
        fname = [fname stringByDeletingPathExtension];
        fname = [fname stringByReplacingOccurrencesOfString:name withString:@""];
        fname = [fname stringByReplacingOccurrencesOfString:@"_" withString:@""];
        [_prog changeLabel:[NSString stringWithFormat:@"%@ : 切り出し完了",fname]];
        [self appendLog:[NSString stringWithFormat:@"%@-切り出し完了", fname]];
        [_prog incrementMenCount];
        if ([_prog getMaxFileCount] == [_prog getCurFileCount] && [_prog getMaxMenCount] == [_prog getCurMenCount]) {
            [_prog closeDialog];
        }
    });
}
@end
