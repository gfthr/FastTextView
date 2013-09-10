//
//  UIFont+TextUtil.h
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface UIFont (TextUtil)
+ (id)fontWithCTFont:(CTFontRef)ctFont;
@end
