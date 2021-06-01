//
//  TrimMain.m
//  TrimmingTool
//
//  Created by uchiyama_Macmini on 2020/07/15.
//  Copyright © 2020年 uchiyama_Macmini. All rights reserved.
//

#import "TrimMain.h"

#define RATIO TRSet.ratio.floatValue / 100.0f
#define INV_RATIO 100.0f / TRSet.ratio.floatValue
#define TOMBO_W_MAX 6.0f
@interface TrimMain () <KZImageDelegate>
{
    float imgResolution;
}
@property (nonatomic, strong) KZImage *imgUtil;

@end

@implementation TrimMain
- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _imgUtil = [[KZImage alloc] init];
    _imgUtil.delegate = self;
    [_imgUtil startEngine];
    
    return self;
}

#pragma mark -
#pragma mark Internal Functions


struct sortByX {
    bool operator () (const cv::Rect & a, const cv::Rect & b){
        return (a.x < b.x);
    }
};

struct sortByY {
    bool operator () (const cv::Rect & a, const cv::Rect & b){
        return (a.y < b.y);
    }
};

void trimDust(cv::Mat &img, int dustArea)
{
    std::vector<std::vector<cv::Point> > vctContours;
    cv::findContours(img, vctContours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_NONE);
    for (int i = 0; i < vctContours.size(); i++) {
        auto cnt = vctContours.at(i);
        if (cv::contourArea(cnt) <= dustArea) {
            cv::drawContours(img, vctContours, i, cv::Scalar::all(0));
        }
    }
}

std::map<std::string, std::vector<float> > getXTomboWidth(cv::Mat img, int tomboLineCount, float* edgeX, int checkRow)
{
//    cv::imwrite("/tmp/getXTomboWidth.tif",img);
    std::map<std::string, std::vector<float> > dobuInfo;
    int start_sCol = 0;
    int start_eCol = 0;
    int end_sCol = 0;
    int end_eCol = 0;
    bool start_s = false;
    bool start_e = false;
    bool end_s = false;
    int max_tombo = tomboLineCount;
    std::vector<float> dobuX;
    std::vector<float> tomboW;
    for (int r = 0; r < img.rows; r++) {
        unsigned char* ro = img.ptr<unsigned char>(r);
        if (r == checkRow) {
            for (int c = 0; c < img.cols; c++) {
                if (!start_s && ro[c] != 0 && start_sCol == 0) {
                    start_sCol = c;
                    start_s = true;
                }
                else if (start_s && ro[c] == 0 && start_eCol == 0) {
                    start_eCol = c;
                    start_e = true;
                    if (tomboLineCount == 1) {
                        float a_start_width = start_eCol - start_sCol;
                        tomboW.push_back(a_start_width);
                        *edgeX = (float)start_sCol + (a_start_width / 2.0f);
                        dobuX.push_back(0.0f);
                        break;
                    }
                        
                }
                else if (start_e && ro[c] != 0 && end_sCol == 0) {
                    end_sCol = c;
                    end_s = true;
                }
                else if (end_s && ro[c] == 0 && end_eCol == 0) {
                    end_eCol = c;
                    max_tombo--;
                    float a_start_width = start_eCol - start_sCol;
                    float a_end_width = end_eCol - end_sCol;
                    tomboW.push_back(a_start_width);
                    if (max_tombo == tomboLineCount - 1) {
                        *edgeX = (float)start_sCol + (a_start_width / 2.0f);
                        dobuX.push_back(((float)end_sCol + (a_end_width / 2.0f)) - *edgeX);
                    }
                    tomboW.push_back(a_end_width);
                    if (max_tombo == 0) break;
                    if (max_tombo != tomboLineCount - 1) {
                        float edge = (float)start_sCol + (a_start_width / 2.0f);
                        dobuX.push_back(((float)end_sCol + (a_end_width / 2.0f)) - edge);
                    }
                    start_sCol = end_sCol;
                    start_eCol = end_eCol;
                    end_sCol = 0;
                    end_eCol = 0;
                    start_s = true;
                    start_e = true;
                    end_s = false;
                }
            }
            if (dobuX.size() == 0 || tomboW.size() == 0) {
                tomboW.clear();
                dobuX.clear();
                checkRow++;
                continue;
            }
            dobuInfo["dobuXs"] = dobuX;
            dobuInfo["tomboWs"] = tomboW;
            break;
        }
    }
    return dobuInfo;
}

std::map<std::string, std::vector<float> > getYTomboWidth(cv::Mat img, int tomboLineCount, float* edgeY, int checkRow)
{
    std::map<std::string, std::vector<float> > dobuInfo;
    int start_sRow = 0;
    int start_eRow = 0;
    int end_sRow = 0;
    int end_eRow = 0;
    bool start_s = false;
    bool start_e = false;
    bool end_s = false;

    int max_tombo = tomboLineCount;
    std::vector<float> dobuY;
    std::vector<float> tomboH;
    for (int c = 0; c < img.cols; c++) {
        if (c == checkRow) {
            for (int r = 0; r < img.rows; r++) {
                uchar *ro = img.ptr<uchar>(r);
                if (!start_s && ro[c] != 0 && start_sRow == 0) {
                    start_sRow = r;
                    start_s = true;
                }
                else if (start_s && ro[c] == 0 && start_eRow == 0) {
                    start_eRow = r;
                    start_e = true;
                    if (tomboLineCount == 1) {
                        float a_start_width = start_eRow - start_sRow;
                        tomboH.push_back(a_start_width);
                        *edgeY = (float)start_sRow + (a_start_width / 2.0f);
                        dobuY.push_back(0.0f);
                        break;
                    }
                }
                else if (start_e && ro[c] != 0 && end_sRow == 0) {
                    end_sRow = r;
                    end_s = true;
                }
                else if (end_s && ro[c] == 0 && end_eRow == 0) {
                    end_eRow = r;
                    max_tombo--;
                    float a_start_width = start_eRow - start_sRow;
                    float a_end_width = end_eRow - end_sRow;
                    
                    if (max_tombo == tomboLineCount - 1) {
                        *edgeY = (float)start_sRow + (a_start_width / 2.0f);
                        dobuY.push_back(((float)end_sRow + (a_end_width / 2.0f)) - *edgeY);
                        tomboH.push_back(a_start_width);
                        tomboH.push_back(a_end_width);
                    }
                    else if (max_tombo == 0) {
                        break;
                    }
                    else if (max_tombo != tomboLineCount - 1) {
                        float edge = (float)start_sRow + (a_start_width / 2.0f);
                        dobuY.push_back(((float)end_sRow + (a_end_width / 2.0f)) - edge);
                        tomboH.push_back(a_end_width);
                    }
                    start_sRow = end_sRow;
                    start_eRow = end_eRow;
                    end_sRow = 0;
                    end_eRow = 0;
                    start_s = true;
                    start_e = true;
                    end_s = false;
                }
            }
            if (dobuY.size() == 0 || tomboH.size() == 0) {
                tomboH.clear();
                dobuY.clear();
                checkRow++;
                continue;
            }
            dobuInfo["dobuYs"] = dobuY;
            dobuInfo["tomboHs"] = tomboH;
            break;
        }
    }
    return dobuInfo;
}

cv::Mat cropLeft(cv::Mat img, int dustArea)
{
    cv::Rect2f crp;
    cv::Mat iii;
    cv::Mat binIII, invbinIII;
    if (img.channels() != 1) {
        cv::cvtColor(img, iii, cv::COLOR_BGR2GRAY);
        cv::adaptiveThreshold(iii, binIII, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 27, 10);
        
        // ゴミとり
        cv::bitwise_not(binIII, invbinIII);
        trimDust(invbinIII, dustArea);
    }
    else {
        cv::threshold(img, invbinIII, 0, 255, cv::THRESH_OTSU);
        trimDust(invbinIII, dustArea);
    }
    // たて方向のドブトンボのみ抽出
    int cropCol = 0;
    int maxPixCol = 0;
    for (int c = 0; c < invbinIII.cols; c++) {
        int totalPixCol = 0;
        for (int r = 0; r < invbinIII.rows; r++) {
            uchar *p = invbinIII.ptr<uchar>(r);
            if (p[c] != 0) totalPixCol++;
        }
        if (maxPixCol < totalPixCol && totalPixCol != 0 && abs(maxPixCol - totalPixCol) > (maxPixCol * 2)) {
            maxPixCol = totalPixCol;
            cropCol = c;
        }
    }
    
    if (cropCol < invbinIII.cols / 3) {
        int tmpCrop = cropCol + 4;
        maxPixCol = 0;
        for (int c = cropCol + 4; c < invbinIII.cols; c++) {
            int totalPixCol = 0;
            for (int r = 0; r < invbinIII.rows; r++) {
                uchar *p = invbinIII.ptr<uchar>(r);
                if (p[c] != 0) totalPixCol++;
            }
            if (maxPixCol < totalPixCol && totalPixCol != 0 && abs(maxPixCol - totalPixCol) > (maxPixCol * 2)) {
                maxPixCol = totalPixCol;
                cropCol = c;
            }
        }
        float crpWidthUnit = abs(tmpCrop - cropCol) / 4.0f;
        crp = cv::Rect2f(tmpCrop + crpWidthUnit,
                         0,
                         crpWidthUnit*2,
                         invbinIII.rows);
    }
    else {
        float crpWidthUnit = (invbinIII.cols - cropCol) / 4.0f;
        crp = cv::Rect2f(crpWidthUnit*2,
                         0,
                         crpWidthUnit,
                         invbinIII.rows);
    }
    

    
    binIII = cv::Mat(invbinIII, crp);
    return binIII;
}

cv::Mat cropRight(cv::Mat img, int dustArea)
{
    cv::Rect2f crp;
    cv::Mat iii;
    cv::Mat binIII, invbinIII;
    if (img.channels() != 1) {
        cv::cvtColor(img, iii, cv::COLOR_BGR2GRAY);
        cv::adaptiveThreshold(iii, binIII, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 27, 10);
        
        // ゴミとり
        cv::bitwise_not(binIII, invbinIII);
        trimDust(invbinIII, dustArea);
    }
    else {
        cv::threshold(img, invbinIII, 0, 255, cv::THRESH_OTSU);
        trimDust(invbinIII, dustArea);
    }
    // たて方向のドブトンボのみ抽出
    int cropCol = 0;
    int maxPixCol = 0;
    
    for (int c = invbinIII.cols-1; c > 0; c--) {
        int totalPixCol = 0;
        for (int r = 0; r < invbinIII.rows; r++) {
            uchar *p = invbinIII.ptr<uchar>(r);
            if (p[c] != 0) totalPixCol++;
        }
        if (maxPixCol < totalPixCol && totalPixCol != 0 && abs(maxPixCol - totalPixCol) > (maxPixCol * 2)) {
            maxPixCol = totalPixCol;
            cropCol = c;
        }
        
    }
    float crpWidthUnit = (invbinIII.cols - cropCol) / 4.0f;
    
    crp = cv::Rect2f(cropCol + crpWidthUnit*2,
                     0,
                     crpWidthUnit,
                     invbinIII.rows);
    binIII = cv::Mat(invbinIII, crp);
    return binIII;
}

cv::Mat cropTop(cv::Mat img, int dustArea)
{
    cv::Rect2f crp;
    cv::Mat iii;
    cv::Mat binIII, invbinIII;
    if (img.channels() != 1) {
        cv::cvtColor(img, iii, cv::COLOR_BGR2GRAY);
        cv::adaptiveThreshold(iii, binIII, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 27, 10);
        // ゴミとり
        cv::bitwise_not(binIII, invbinIII);
        trimDust(invbinIII, dustArea);
    }
    else {
        cv::threshold(img, invbinIII, 0, 255, cv::THRESH_OTSU);
        trimDust(invbinIII, dustArea);
    }
    
    // 横方向のドブトンボのみ抽出
    int cropRow = 0;
    int maxPixRow = 0;
    
    for (int r = 0; r < invbinIII.rows; r++) {
        uchar *p = invbinIII.ptr<uchar>(r);
        int totalPixRow = 0;
        for (int c = 0; c < invbinIII.cols; c++) {
            if (p[c] != 0) totalPixRow++;
        }
        if (maxPixRow < totalPixRow && totalPixRow != 0 && abs(maxPixRow - totalPixRow) > (maxPixRow * 2)) {
            maxPixRow = totalPixRow;
            cropRow = r;
        }
    }
    if (cropRow < invbinIII.rows / 3) {
        int tmpCrop = cropRow + 4;
        maxPixRow = 0;
        for (int r = cropRow + 4; r < invbinIII.rows; r++) {
            uchar *p = invbinIII.ptr<uchar>(r);
            int totalPixRow = 0;
            for (int c = 0; c < invbinIII.cols; c++) {
                if (p[c] != 0) totalPixRow++;
            }
            if (maxPixRow < totalPixRow && totalPixRow != 0 && abs(maxPixRow - totalPixRow) > (maxPixRow * 2)) {
                maxPixRow = totalPixRow;
                cropRow = r;
            }
        }
        float crpHeightUnit = abs(tmpCrop - cropRow) / 4.0f;
        crp = cv::Rect2f(0,
                         tmpCrop + crpHeightUnit,
                         invbinIII.cols,
                         crpHeightUnit*2);
    }
    else {
        float crpHeightUnit = (invbinIII.rows - cropRow) / 4.0f;
        crp = cv::Rect2f(0,
                         crpHeightUnit*2,
                         invbinIII.cols,
                         crpHeightUnit);
    }
    
    binIII = cv::Mat(invbinIII, crp);

    return binIII;
}

cv::Mat cropBottom(cv::Mat img, int dustArea)
{
    cv::Rect2f crp;
    cv::Mat iii;
    cv::Mat binIII, invbinIII;
    if (img.channels() != 1) {
        cv::cvtColor(img, iii, cv::COLOR_BGR2GRAY);
        cv::adaptiveThreshold(iii, binIII, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 27, 10);
        // ゴミとり
        cv::bitwise_not(binIII, invbinIII);
        trimDust(invbinIII, dustArea);
    }
    else {
        cv::threshold(img, invbinIII, 0, 255, cv::THRESH_OTSU);
        trimDust(invbinIII, dustArea);
    }
    
    // 横方向のドブトンボのみ抽出
    int cropRow = 0;
    int maxPixRow = 0;
    for (int r = invbinIII.rows-1; r > 0; r--) {
        uchar *p = invbinIII.ptr<uchar>(r);
        int totalPixRow = 0;
        for (int c = 0; c < invbinIII.cols; c++) {
            if (p[c] != 0){
                totalPixRow++;
            }
        }
        if (maxPixRow < totalPixRow && totalPixRow != 0 && abs(maxPixRow - totalPixRow) > (maxPixRow * 2)) {
            maxPixRow = totalPixRow;
            cropRow = r;
        }
    }
    
    float crpHeightUnit = (invbinIII.rows - cropRow) / 4.0f;
    crp = cv::Rect2f(0,
                     cropRow + crpHeightUnit*2,
                     invbinIII.cols,
                     crpHeightUnit);
    
    binIII = cv::Mat(invbinIII, crp);

    return binIII;
}

#pragma mark -
#pragma mark OpenCV

// ギザギザエリアの無いトンボを抽出(1本トンボのみ)
cv::Range getXTomboOffset(cv::Mat img) {
    cv::Range ret;
    std::vector< std::vector<cv::Point> > contours;
    cv::Rect rc;
    cv::findContours(img, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_NONE);
    for (auto it = contours.begin(); it != contours.end(); ++it) {
        cv::Rect r = cv::boundingRect(*it);
        if (r.area() > 10) {
            rc |= r;
        }
    }
    rc = cv::Rect(rc.x, rc.y, rc.width, rc.height);
    cv::Mat crp(img,rc);
    for (int c = 0; c < crp.cols; c++) {
        int totalPixCol = 0;
        for (int r = 0; r < crp.rows; r++) {
            uchar *p = crp.ptr<uchar>(r);
            if (p[c] != 0) totalPixCol++;
        }
        if (totalPixCol == crp.rows && ret.start == 0) {
            ret.start = rc.x+c;
        }
        else if (totalPixCol == crp.rows && ret.start != 0) {
            ret.end = rc.x+c;
        }
    }
    return ret;
}

std::map<std::string, float> getCropPoint(cv::Mat img, float res, int redust, std::string mode, cv::Rect cropRect)
{
    int trim = 10;
    cv::Mat iii,binIII;
    cv::cvtColor(img, iii, cv::COLOR_BGR2GRAY);
    cv::adaptiveThreshold(iii, binIII, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 27, 10);
    cv::bitwise_not(binIII, binIII);
    cv::imwrite("/tmp/binIII.tif", binIII);
    
    // 空白を除去
    std::vector< std::vector<cv::Point> > contours;
    cv::Rect rc;
    cv::findContours(binIII, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_NONE);
    for (auto it = contours.begin(); it != contours.end(); ++it) {
        cv::Rect r = cv::boundingRect(*it);
        if (r.area() > 10) {
            rc |= r;
        }
    }
    
    if (mode == "TL") {
        rc = cv::Rect(rc.x + trim, rc.y + trim, (rc.width - trim) + 2, (rc.height - trim) + 2);
    }
    else if (mode == "TR") {
        rc = cv::Rect(rc.x - 2, rc.y + trim, (rc.width - trim) + 2, (rc.height - trim) + 2);
    }
    else if (mode == "BL") {
        rc = cv::Rect(rc.x + trim, rc.y - 2, (rc.width - trim) + 2, (rc.height - trim) + 2);
    }
    
    cv::Mat crp(binIII,rc);
    cv::imwrite("/tmp/crp.tif", crp);
    // X方向のドブ切り出し
    cv::Mat binTombo_x;
    
    if (mode == "TL" || mode == "TR") {
        binTombo_x = cropTop(crp, redust);
    }
    else if (mode == "BL") {
        binTombo_x = cropBottom(crp, redust);
    }
    
    cv::imwrite("/tmp/binTombo_x.tif", binTombo_x);
    // Y方向のドブ切り出し
    cv::Mat binTombo_y;
    if (mode == "TL" || mode == "BL") {
        binTombo_y = cropLeft(crp, redust);
    }
    else if (mode == "TR") {
        binTombo_y = cropRight(crp, redust);
    }
    cv::imwrite("/tmp/binTombo_y.tif", binTombo_y);
    std::map<std::string, float> retInfo;
    
    try {
        float edgeX, edgeY;
        auto xtombo = getXTomboWidth(binTombo_x, TRSet.danXCount.intValue, &edgeX, binTombo_x.rows / 2.0);
        std::vector<float> dobuX = xtombo["dobuXs"];
        std::vector<float> tomboW = xtombo["tomboWs"];
        if (dobuX.size() == 0 || tomboW.size() == 0)
            throw "X方向のドブ取得失敗";
        
        auto ytombo = getYTomboWidth(binTombo_y, TRSet.danYCount.intValue, &edgeY, binTombo_y.cols / 2.0);
        std::vector<float> dobuY = ytombo["dobuYs"];
        std::vector<float> tomboH = ytombo["tomboHs"];
        if (dobuY.size() == 0 || tomboH.size() == 0)
            throw "Y方向のドブ取得失敗";
        
        float xpix = 0.0f;
        if (mode == "TL" || mode == "BL") {
            xpix = (float)rc.x+edgeX+dobuX[0];
        }
        else if (mode == "TR") {
            xpix = (float)cropRect.x + (float)rc.x+edgeX;
        }
        
        
        float ypix = 0.0f;
        
        if (mode == "TL" || mode == "TR") {
            ypix = (float)rc.y+edgeY+dobuY[0];
        }
        else if (mode == "BL") {
            ypix = (float)cropRect.y + (float)rc.y+edgeY;
        }
        
        retInfo["X"] = xpix;
        retInfo["Y"] = ypix;
        retInfo["DobuX"] = dobuX[0];
        retInfo["DobuY"] = dobuY[0];
        retInfo["EdgeX"] = rc.x-trim;
        retInfo["EdgeY"] = rc.y-trim;
        return retInfo;
        
    } catch (const char *ex) {
        throw;
    }
    
    return retInfo;
}

std::vector<cv::Rect2f> getColCropRange(cv::Mat binIII, float resolution, std::map<std::string, float> cropInfo, bool isSiagari, float bottomX, float bottomDobu) {
    float dobu_max = [KZLibs mmToPixcel:30 dpi:resolution];
    float dobu_min = [KZLibs mmToPixcel:1.5 dpi:resolution];
    
    std::vector<cv::Rect> colRects;
    std::vector<std::vector<cv::Point> > vctContours;

    cv::findContours(binIII, vctContours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_NONE);
    for (auto it = vctContours.begin(); it != vctContours.end(); it++) {
        cv::Rect theRect = cv::boundingRect(*it);
        if (theRect.width <= TOMBO_W_MAX && theRect.height > (TOMBO_W_MAX * 2.0f))
            colRects.push_back(theRect);
    }
    
    std::sort(colRects.begin(), colRects.end(), sortByX());
    std::vector<cv::Rect2f> rngToCropX;
    
    try {
        for (int i = 0; i < colRects.size()-1; i++) {
            cv::Rect topRect = colRects.at(i);
            cv::Rect top2Rect = colRects.at(i+1);
            float realDf = (top2Rect.x + top2Rect.width / 2.0f) - (topRect.x + (topRect.width / 2.0f));
            if ((topRect.x <= (cropInfo["X"] - cropInfo["EdgeX"])) &&
                (top2Rect.x > (cropInfo["X"] - cropInfo["EdgeX"]) + cropInfo["DobuX"])) {
                cv::Rect2f rng;
                if (isSiagari) {
                    rng.x = cropInfo["X"];
                    rng.width = realDf;
                    continue;
                }
                else {
                    rng.x = cropInfo["X"] - cropInfo["DobuX"];
                    cv::Rect top3Rect = colRects.at(i+2);
                    float real2Df = (top3Rect.x + top3Rect.width / 2.0f) - (top2Rect.x + (top2Rect.width / 2.0f));
                    if (real2Df <= dobu_max && real2Df >= dobu_min) {
                        rng.width = realDf + cropInfo["DobuX"] + real2Df;
                    }
                    else {
                        rng.width = realDf + cropInfo["DobuX"];
                    }
                }
                rngToCropX.push_back(rng);
                continue;
            }
            else if ((topRect.x <= (cropInfo["X"] - cropInfo["EdgeX"])) && (top2Rect.x <= (cropInfo["X"] - cropInfo["EdgeX"]))) {
                continue;
            }
            else if ((topRect.x >= bottomX) || (top2Rect.x >= bottomX)) {
                break;
            }
            
            if (realDf <= dobu_max && realDf >= dobu_min) {
                // 間隔がドブ幅の範囲内(1.5~30mm以内)
                if (i < colRects.size()-2) {
                    cv::Rect top3Rect = colRects.at(i+2);
                    cv::Rect2f rng;
                    if (top3Rect.x >= bottomX) {
                        break;
                    }
                    
                    float real2Df = (top3Rect.x + top3Rect.width / 2.0f) - (top2Rect.x + (top2Rect.width / 2.0f));
                    if (real2Df <= dobu_max && real2Df >= dobu_min) {
                        // 3本トンボ
                        if (i >= colRects.size()-3) continue;
                        
                        cv::Rect top4Rect = colRects.at(i+3);
                        float real3Df = (top4Rect.x + top4Rect.width / 2.0f) - (top3Rect.x + (top3Rect.width / 2.0f));
                        if (real3Df > dobu_max) {
                            if (isSiagari) {
                                rng.x = cropInfo["EdgeX"] + top3Rect.x + (top3Rect.width / 2.0f);
                                rng.width = real3Df;
                            }
                            else {
                                rng.x = cropInfo["EdgeX"] + top2Rect.x + (top2Rect.width / 2.0f);
                                if (i >= colRects.size()-4) {
                                    rng.width = real2Df + real3Df;
                                }
                                else {
                                    cv::Rect top5Rect = colRects.at(i+4);
                                    float real4Df = (top5Rect.x + top5Rect.width / 2.0f) - (top4Rect.x + (top4Rect.width / 2.0f));
                                    if (real4Df > dobu_max) {
                                        rng.width = real2Df + real3Df;
                                    }
                                    else {
                                        rng.width = real3Df + real2Df + real4Df;
                                    }
                                }
                            }
                            rngToCropX.push_back(rng);
                        }
                        else {
                            throw "4本トンボは未サポート";
                        }
                        i = i+2;
                    }
                    else if (real2Df > dobu_max) {
                        // 2本トンボ
                        cv::Rect2f rng;
                        if (isSiagari) {
                            rng.x = cropInfo["EdgeX"] + top2Rect.x + (top2Rect.width / 2.0f);
                            rng.width = real2Df;
                        }
                        else {
                            if (i >= colRects.size()-3) {
                                rng.width = realDf + real2Df;
                            }
                            else {
                                cv::Rect top4Rect = colRects.at(i+3);
                                float real3Df = (top4Rect.x + top4Rect.width/ 2.0f) - (top3Rect.x + (top3Rect.width / 2.0f));
                                if (real3Df > dobu_max) {
                                    rng.width = realDf + real2Df;
                                }
                                else {
                                    rng.width = realDf + real2Df + real3Df;
                                }
                            }
                        }
                        rngToCropX.push_back(rng);
                        i = i+1;
                    }
                    else {
                        throw "ゴミデータが残っている可能性あり";
                    }
                }
                else {
                    Log(@"ColEnd");
                }
            }
            else if (realDf > dobu_max) {
                cv::Rect2f rng;
                rng.x = cropInfo["EdgeX"] + topRect.x + (topRect.width / 2.0f);
                if (isSiagari) {
                    rng.width = realDf;
                }
                else {
                    if (i >= colRects.size()-2) {
                        rng.width = realDf;
                    }
                    else {
                        cv::Rect top3Rect = colRects.at(i+2);
                        float real2Df = (top3Rect.x + top3Rect.width / 2.0f) - (top2Rect.x + (top2Rect.width / 2.0f));
                        if (real2Df <= dobu_max && real2Df >= dobu_min) {
                            rng.width = realDf + real2Df;
                        }
                        else {
                            rng.width = realDf;
                        }
                    }
                }
                rngToCropX.push_back(rng);
            }
            else {
                throw "ゴミデータが残っている可能性あり";
            }
        }
    } catch (const char *ex) {
        throw;
    }
    
    return rngToCropX;
}

std::vector<cv::Rect2f> getRowCropRange(cv::Mat binIII, float resolution, std::map<std::string, float> cropInfo, bool isSiagari, float bottomY, float bottomDobu) {
    float dobu_max = [KZLibs mmToPixcel:30 dpi:resolution];
    float dobu_min = [KZLibs mmToPixcel:1.5 dpi:resolution];
    
    std::vector<cv::Rect> rowRects;
    std::vector<std::vector<cv::Point> > vctContours;
    
    cv::findContours(binIII, vctContours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_NONE);
    for (auto it = vctContours.begin(); it != vctContours.end(); it++) {
        cv::Rect theRect = cv::boundingRect(*it);
        if (theRect.height <= TOMBO_W_MAX && theRect.width > (TOMBO_W_MAX * 2))
            rowRects.push_back(theRect);
    }
    
    std::sort(rowRects.begin(), rowRects.end(), sortByY());
    std::vector<cv::Rect2f> rngToCropY;
    
    try {
        for (int i = 0; i < (rowRects.size()-1); i++) {
            cv::Rect topRect = rowRects.at(i);
            cv::Rect top2Rect = rowRects.at(i+1);
            float realDf = (top2Rect.y + top2Rect.height / 2.0f) - (topRect.y + (topRect.height / 2.0f));
            if ((topRect.y <= (cropInfo["Y"] - cropInfo["EdgeY"])) && (top2Rect.y > (cropInfo["Y"] - cropInfo["EdgeY"]) + cropInfo["DobuY"])) {
                cv::Rect2f rng;
                if (isSiagari) {
                    rng.y = cropInfo["Y"];
                    rng.height = realDf;
                    continue;
                }
                else {
                    rng.y = cropInfo["Y"] - cropInfo["DobuY"];
                    cv::Rect top3Rect = rowRects.at(i+2);
                    float real2Df = (top3Rect.y + top3Rect.height / 2.0f) - (top2Rect.y + (top2Rect.height / 2.0f));
                    if (real2Df > dobu_max) {
                        rng.height = realDf + cropInfo["DobuY"];
                    }
                    else {
                        rng.height = realDf + cropInfo["DobuY"] + real2Df;
                    }
                }
                rngToCropY.push_back(rng);
                continue;
            }
            else if ((topRect.y <= (cropInfo["Y"] - cropInfo["EdgeY"])) && (top2Rect.y <= (cropInfo["Y"] - cropInfo["EdgeY"]))) {
                continue;
            }
            else if ((topRect.y >= bottomY) || (top2Rect.y >= bottomY)) {
                break;
            }
            
            if (realDf <= dobu_max && realDf >= dobu_min) {
                // 間隔がドブ幅の範囲内(1.5~30mm以内)
                if (i < rowRects.size()-2) {
                    cv::Rect top3Rect = rowRects.at(i+2);
                    if (top3Rect.y >= bottomY) {
                        break;
                    }
                    cv::Rect2f rng;
                    float real2Df = (top3Rect.y + top3Rect.height / 2.0f) - (top2Rect.y + (top2Rect.height / 2.0f));
                    if (real2Df <= dobu_max && real2Df >= dobu_min) {
                        // 3本トンボ
                        if (i >= rowRects.size()-3) continue;
                        
                        cv::Rect top4Rect = rowRects.at(i+3);
                        float real3Df = (top4Rect.y + top4Rect.height / 2.0f) - (top3Rect.y + (top3Rect.height / 2.0f));
                        if (real3Df > dobu_max) {
                            if (isSiagari) {
                                rng.y = cropInfo["EdgeY"] + top3Rect.y + (top3Rect.height / 2.0f);
                                rng.height = real3Df;
                            }
                            else {
                                rng.y = cropInfo["EdgeY"] + top2Rect.y + (top2Rect.height / 2.0f);
                                if (i >= rowRects.size()-4) {
                                    rng.height = real2Df + real3Df;
                                }
                                else {
                                    cv::Rect top5Rect = rowRects.at(i+4);
                                    float real4Df = (top5Rect.y + top5Rect.height / 2.0f) - (top4Rect.y + (top4Rect.height / 2.0f));
                                    if (real4Df > dobu_max) {
                                        rng.height = real2Df + real3Df;
                                    }
                                    else {
                                        rng.height = real3Df + real2Df + real4Df;
                                    }
                                }
                            }
                            rngToCropY.push_back(rng);
                        }
                        else {
                            throw "4本トンボは未サポート";
                        }
                        i = i+2;
                        
                    }
                    else if (real2Df > dobu_max) {
                        // 2本トンボ
                        cv::Rect2f rng;
                        if (isSiagari) {
                            rng.y = cropInfo["EdgeY"] + top2Rect.y + (top2Rect.height / 2.0f);
                            rng.height = real2Df;
                        }
                        else {
                            if (i >= rowRects.size()-3) {
                                rng.height = realDf + real2Df;
                            }
                            else {
                                cv::Rect top4Rect = rowRects.at(i+3);
                                float real3Df = (top4Rect.y + top4Rect.height / 2.0f) - (top3Rect.y + (top3Rect.height / 2.0f));
                                if (real3Df > dobu_max) {
                                    rng.height = realDf + real2Df;
                                }
                                else {
                                    rng.height = realDf + real2Df + real3Df;
                                }
                            }
                        }
                        rngToCropY.push_back(rng);
                        i = i+1;
                    }
                    else {
                        throw "ゴミデータが残っている可能性あり";
                    }
                }
                else {
                    Log(@"RowEnd");
                }
            }
            else if (realDf > dobu_max) {
                // 1本トンボ
                cv::Rect2f rng;
                if (isSiagari) {
                    rng.y = cropInfo["EdgeY"] + topRect.y + (topRect.height / 2.0f);
                    rng.height = realDf;
                }
                else {
                    if (i >= rowRects.size()-2) {
                        rng.height = realDf;
                    }
                    else {
                        cv::Rect top3Rect = rowRects.at(i+2);
                        float real2Df = (top3Rect.y + top3Rect.height / 2.0f) - (top2Rect.y + (top2Rect.height / 2.0f));
                        if (real2Df > dobu_max) {
                            rng.height = realDf;
                        }
                        else {
                            rng.height = realDf + real2Df;
                        }
                    }
                }
                rngToCropY.push_back(rng);
            }
            else {
                throw "ゴミデータが残っている可能性あり";
            }
        }
    } catch (const char *ex) {
        throw;
    }
    
    return rngToCropY;
}

- (NSArray*)getMentsukeInfo:(NSString*)path isSiagari:(BOOL)isSiagari
{
    float resolution = [_imgUtil getImageDPI:path];
    
    imgResolution = resolution * RATIO;
    ConvertSetting *convertSetting = [[ConvertSetting alloc] init];
    convertSetting.isResize = YES;
    convertSetting.toSpace = KZColorSpace::GRAY;
    convertSetting.Resolution = imgResolution;
    
    NSData *imgData = [_imgUtil ImageConvertfrom:path page:0 format:KZFileFormat::TIFF_FORMAT size:NSMakeSize(0, 0) trimSize:0 setting:convertSetting];
    cv::Mat img = cv::imdecode(cv::Mat(1, (int)imgData.length, CV_8UC3, (void*)imgData.bytes), cv::IMREAD_COLOR);
    cv::imwrite("/tmp/img.tif", img);
    float trimArea = [KZLibs mmToPixcel:TRSet.tomboArea.floatValue dpi:imgResolution];
    cv::Rect tlRect(0,0,trimArea, trimArea);
    cv::Rect blRect(0,img.rows - trimArea,trimArea, trimArea);
    cv::Rect trRect(img.cols - trimArea,0,trimArea, trimArea);
    cv::Mat cropTL(img, tlRect);
    cv::Mat cropBL(img, blRect);
    cv::Mat cropTR(img, trRect);
    std::map<std::string, float> cropInfo, cropInfoBL, cropInfoTR;
    try {
        cropInfo = getCropPoint(cropTL, imgResolution, TRSet.remDust.intValue, "TL", tlRect);
    } catch (const char *ex) {
        NSString *er = [NSString stringWithFormat:@"get TopLeft tombo error - %@",[NSString stringWithUTF8String:ex]];
        return @[er];
    }
    try {
        cropInfoBL = getCropPoint(cropBL, imgResolution, TRSet.remDust.intValue, "BL", blRect);
    } catch (const char *ex) {
        NSString *er = [NSString stringWithFormat:@"get BottomLeft tombo error - %@",[NSString stringWithUTF8String:ex]];
        return @[er];
    }
    try {
        cropInfoTR = getCropPoint(cropTR, imgResolution, TRSet.remDust.intValue, "TR", trRect);
    } catch (const char *ex) {
        NSString *er = [NSString stringWithFormat:@"get TopRight tombo error - %@",[NSString stringWithUTF8String:ex]];
        return @[er];
    }
    
    cv::Rect2f leftLineRect(cropInfo["EdgeX"], cropInfo["EdgeY"],
                       (cropInfo["X"] - cropInfo["EdgeX"]), img.rows - cropInfo["EdgeY"]);
    
    cv::Mat leftLine(img, leftLineRect);
    
    cv::imwrite("/tmp/leftLine.tif", leftLine);
    cv::Mat binLTombos = cropLeft(leftLine, TRSet.remDust.intValue);
    trimDust(binLTombos, TRSet.remDust.intValue);
    cv::imwrite("/tmp/binLTombos.tif", binLTombos);
    
    std::vector<cv::Rect2f> mapRowTombo;
    std::vector<cv::Rect2f> mapColTombo;
    try {
        mapRowTombo = getRowCropRange(binLTombos, imgResolution, cropInfo, isSiagari, cropInfoBL["Y"], cropInfoBL["DobuY"]);
    } catch (const char *ex) {
        NSString *er = [NSString stringWithFormat:@"analyze row tombo error - %@",[NSString stringWithUTF8String:ex]];
        return @[er];
    }

    cv::Rect2f topLineRect(cropInfo["EdgeX"], cropInfo["EdgeY"],
                           img.cols - cropInfo["EdgeX"], (cropInfo["Y"] - cropInfo["EdgeY"]));
    // 下はそのまま上方向に3mm切り出す
    
    cv::Mat topLine(img, topLineRect);
    
    cv::imwrite("/tmp/topLine.tif", topLine);
    cv::Mat binTTombos = cropTop(topLine, TRSet.remDust.intValue);
    trimDust(binTTombos, TRSet.remDust.intValue);
    cv::imwrite("/tmp/binTTombos.tif", binTTombos);
    
    try {
        mapColTombo = getColCropRange(binTTombos, imgResolution, cropInfo, isSiagari, cropInfoTR["X"], cropInfoTR["DobuX"]);
    } catch (const char *ex) {
        NSString *er = [NSString stringWithFormat:@"analyze col tombo error - %@",[NSString stringWithUTF8String:ex]];
        return @[er];
    }
    
    NSMutableArray *arRet = [@[] mutableCopy];
    for (int r = 0; r < mapRowTombo.size(); r++) {
        NSRect cropRc;
        cv::Rect2f rcRow = mapRowTombo[r]; // y , height
        for (int c = 0; c < mapColTombo.size(); c++) {
            cv::Rect2f rcCol = mapColTombo[c];
            cropRc = NSMakeRect(rcCol.x * INV_RATIO, rcRow.y * INV_RATIO, rcCol.width * INV_RATIO, rcRow.height * INV_RATIO);
            BOOL isRotPage = NO;
            if (TRSet.isLeftBind) {
                if (r%2==1) isRotPage = NO;
                else isRotPage = YES;
            }
            else {
                if (r%2==1) isRotPage = YES;
                else isRotPage = NO;
            }
            [arRet addObject:@{@"rect": [NSValue valueWithRect:cropRc],
                               @"isRot": [NSNumber numberWithBool:isRotPage]}];
        }
    }
    return [arRet copy];
}

- (BOOL)trimstart:(NSString*)path savePath:(NSString *)savePath saveNames:(NSArray *)saveNames cropAreas:(NSArray*)cropAreas
{
    if (saveNames.count == cropAreas.count) {
        [_imgUtil cropMentuke:path menInfo:cropAreas isSiagari:YES savePath:savePath saveNames:saveNames];
    }
    else {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark Delegate From KZImage
- (void)cropPageStart:(NSString*)savePath
{
    [_delegate cropPageStart:savePath];
}

- (void)cropPageDone:(NSString*)croppedPath
{
    [_delegate cropPageDone:croppedPath];
}
@end
