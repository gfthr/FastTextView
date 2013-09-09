//
//  TextConfig.m
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import "AttributeConfig.h"
#import <CoreText/CoreText.h>
#import "UIFont+TextUtil.h"


@implementation AttributeConfig
@synthesize font=_font;
@synthesize attributes=_attributes;




-(UIFont *)font{
    UIFont *curfont=[UIFont systemFontOfSize:17.0f];
    if (self.attributes !=nil) {
        CTFontRef fontRef=(__bridge CTFontRef)([self.attributes objectForKey:(NSString *)kCTFontAttributeName]);        
        curfont=[UIFont fontWithCTFont:fontRef];
    }
    return curfont;    
}


- (void)setFont:(UIFont *)font {
    
    //UIFont *oldFont = _font;
    _font = font;
    
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef) self.font.fontName, self.font.pointSize, NULL);
    
    NSMutableDictionary *dictionary=[self.attributes mutableCopy];
    
    [dictionary setObject:(__bridge id)ctFont forKey:(NSString *)kCTFontAttributeName];
    
//    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:(__bridge id)ctFont, (NSString *)kCTFontAttributeName, (id)[UIColor blackColor].CGColor, kCTForegroundColorAttributeName, nil];
    
    //self.defaultAttributes = dictionary;
    CFRelease(ctFont);
    
    self.attributes=dictionary;
    
    //[self textChanged];
    
}

-(void)setFontSize:(NSInteger)fontType{
    
    CGFloat fontSize= 15.0f;
    switch(fontType){
        case 0:{
            fontSize = 15.0f;
        }
            break;
        case 1:{
            fontSize = 17.0f;
        }
            break;
        case 2:{
            fontSize = 19.0f;
        }
            break;
        case 3:{
            fontSize = 21.0f;
        }
            break;
    }
    
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef) self.font.fontName, fontSize, NULL);
    
    NSMutableDictionary *dictionary=[self.attributes mutableCopy];
    
    [dictionary setObject:(__bridge id)ctFont forKey:(NSString *)kCTFontAttributeName];
    
    //    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:(__bridge id)ctFont, (NSString *)kCTFontAttributeName, (id)[UIColor blackColor].CGColor, kCTForegroundColorAttributeName, nil];
    
    //self.defaultAttributes = dictionary;
    CFRelease(ctFont);
    
    self.attributes=dictionary;
}

-(void)setReadStyle:(NSInteger)readStyle{
    
    UIColor *color = [UIColor blackColor]; //数据库
    UIColor *strokeColor = [UIColor whiteColor]; //数据库
    if(readStyle == 0){
        //白天
        color = [self colorWithR:36 G:36 B:36 alpha:1.0];
        strokeColor = [UIColor whiteColor];
    }else{
        //黑夜
        color = [self colorWithR:94 G:102 B:106 alpha:1.0];
        strokeColor = [UIColor whiteColor];
    }
    
    NSMutableDictionary *dictionary=[self.attributes mutableCopy];
    
    [dictionary setObject:(id)color.CGColor forKey:(NSString *)kCTForegroundColorAttributeName];
    [dictionary setObject:(id)strokeColor.CGColor forKey:(NSString *) kCTStrokeColorAttributeName];
    self.attributes=dictionary;
}

-(UIColor *)colorWithR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b alpha:(CGFloat)alpha{
    CGFloat red=[NSNumber numberWithInt:r].floatValue/255;
    CGFloat green=[NSNumber numberWithInt:g].floatValue/255;
    CGFloat blue=[NSNumber numberWithInt:b].floatValue/255;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end

