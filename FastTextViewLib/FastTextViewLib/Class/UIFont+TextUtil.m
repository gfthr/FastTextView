//
//  UIFont+TextUtil.m
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import "UIFont+TextUtil.h"

@implementation UIFont (TextUtil)

+ (id)fontWithCTFont:(CTFontRef)ctFont
{
    CFStringRef fontName=CTFontCopyPostScriptName(ctFont); //CTFontCopyFullName(ctFont);//(__bridge CFStringRef)@"HiraKakuProN-W3"; //
    CGFloat fontSize =CTFontGetSize(ctFont);
    
    UIFont *ret = [UIFont fontWithName:(__bridge NSString *)fontName size:fontSize];
    CFRelease(fontName);
    return ret;
}

@end
