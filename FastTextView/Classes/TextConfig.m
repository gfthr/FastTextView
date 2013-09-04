//
//  TextConfig.m
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import "TextConfig.h"
#import <CoreText/CoreText.h>
 #define ARRSIZE(a)      (sizeof(a) / sizeof(a[0]))
//#import "UIFont+TextUtil.h"
//#import "const.h"

static AttributeConfig *editorAttributeConfig = nil;

@implementation TextConfig


+(AttributeConfig *)editorAttributeConfig{

    @synchronized (self)
    {
        if (editorAttributeConfig == nil)
        {
            editorAttributeConfig= [[AttributeConfig alloc] init];
            //TODO load from config
            
            editorAttributeConfig.attributes=[AttributeConfig defaultAttributes];
            
            
        }
    }
    return editorAttributeConfig;

}


@end

@implementation AttributeConfig
@synthesize font=_font;
@synthesize attributes=_attributes;

+(NSDictionary *)defaultAttributes{

    NSString *fontName =[[UIFont systemFontOfSize:17]fontName];//@"Hiragino Sans GB";
    CGFloat fontSize= 17.0f;
    UIColor *color = [UIColor blackColor];
    UIColor *strokeColor = [UIColor whiteColor];
    CGFloat strokeWidth = 0.0;
    CGFloat paragraphSpacing = 0.0;
    CGFloat lineSpacing = 0.0;
    //CGFloat minimumLineHeight=24.0f;
        
    
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName,
                                             fontSize, NULL);
    
    CTParagraphStyleSetting settings[] = {
        { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing },
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
        // { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minimumLineHeight },
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, ARRSIZE(settings));
    
    //apply the current text style //2
   /* NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)color.CGColor, kCTForegroundColorAttributeName,
                           (__bridge id)fontRef, kCTFontAttributeName,
                           (id)strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
                           (id)[NSNumber numberWithFloat: strokeWidth], (NSString *)kCTStrokeWidthAttributeName,
                           (__bridge id) paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
                           nil];
    */
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)color.CGColor, kCTForegroundColorAttributeName,
                           (__bridge id)fontRef, kCTFontAttributeName,
                           (id)strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
                           (id)[NSNumber numberWithFloat: strokeWidth], (NSString *)kCTStrokeWidthAttributeName,
                           (__bridge id) paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
                           nil];
    
    CFRelease(fontRef);
    return attrs;
}




@end

