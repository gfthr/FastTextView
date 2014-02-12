//
//  UIColor+Helper.m
//  FastTextViewLib
//
//  Created by 王 强 on 14-2-12.
//  Copyright (c) 2014年 wangqiang. All rights reserved.
//

#import "UIColor+Helper.h"

@implementation UIColor (Helper)

+(UIColor *)colorWithR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b alpha:(CGFloat)alpha{
    CGFloat red=[NSNumber numberWithInt:r].floatValue/255;
    CGFloat green=[NSNumber numberWithInt:g].floatValue/255;
    CGFloat blue=[NSNumber numberWithInt:b].floatValue/255;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end
