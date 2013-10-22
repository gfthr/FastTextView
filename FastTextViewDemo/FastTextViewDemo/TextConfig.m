//
//  TextConfig.m
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import "TextConfig.h"
#import <CoreText/CoreText.h>
//#import "const.h"
#define ARRSIZE(a)      (sizeof(a) / sizeof(a[0]))


static AttributeConfig *editorAttributeConfig = nil;
static AttributeConfig *readerAttributeConfig = nil;
static AttributeConfig *readerTitleAttributeConfig = nil;

@implementation TextConfig


+(AttributeConfig *)editorAttributeConfig{

    @synchronized (self)
    {
        if (editorAttributeConfig == nil)
        {
            editorAttributeConfig= [[AttributeConfig alloc] init];
            //TODO load from config
            
            editorAttributeConfig.attributes=[self defaultAttributes];
            
            
        }
    }
    return editorAttributeConfig;

}

+(AttributeConfig *)readerAttributeConfig{

    @synchronized (self)
    {
        if (readerAttributeConfig == nil)
        {
            readerAttributeConfig= [[AttributeConfig alloc] init];
            readerAttributeConfig.attributes=[self defaultReaderAttributes];
            //TODO load from config
        }
        
    }
    return readerAttributeConfig;
}






+(AttributeConfig *)readerTitleAttributeConfig{
    
    @synchronized (self)
    {
        if (readerTitleAttributeConfig == nil)
        {
            readerTitleAttributeConfig= [[AttributeConfig alloc] init];
            readerTitleAttributeConfig.attributes=[self defaultReaderTitleAttributes];
            //TODO load from config
        }
        
    }
    return readerTitleAttributeConfig;
}



+(NSDictionary *)defaultAttributes{

    NSString *fontName =[[UIFont systemFontOfSize:17]fontName];//@"Hiragino Sans GB";
    CGFloat fontSize= 17.0f;
    UIColor *color = [UIColor blackColor];
    UIColor *strokeColor = [UIColor whiteColor];
    CGFloat strokeWidth = 0.0;
    CGFloat paragraphSpacing = 20.0;
    CGFloat paragraphSpacingBefore = 20.0;
    CGFloat lineSpacing = 5.0;
    CGFloat minimumLineHeight=0.0f;
    
    //CGFloat headIndent= 20.0;
    
    
    
        
    
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName,
                                             fontSize, NULL);
    
    CTParagraphStyleSetting settings[] = {
        { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore },        
        { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing },
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minimumLineHeight },
        //{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &headIndent },
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


//modify by yangzongming
+(NSDictionary *)defaultReaderAttributes{
    return  [self defaultAttributes];
    
}

/*
+(NSDictionary *)defaultImageDescAttributes{
    
    NSString *fontName =[[UIFont systemFontOfSize:12]fontName];//@"Hiragino Sans GB";
    CGFloat fontSize= 12.0f;
    UIColor *color = [UIColor blackColor];
    UIColor *strokeColor = [UIColor whiteColor];
    CGFloat strokeWidth = 0.0;    
    
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName,
                                             fontSize, NULL);  
    
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)color.CGColor, kCTForegroundColorAttributeName,
                           (__bridge id)fontRef, kCTFontAttributeName,
                           (id)strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
                           (id)[NSNumber numberWithFloat: strokeWidth], (NSString *)kCTStrokeWidthAttributeName,
                           nil];
    
    CFRelease(fontRef);
    return attrs;
}
 */



+(NSDictionary *)defaultReaderTitleAttributes{
    return  [self defaultAttributes];
}




@end

