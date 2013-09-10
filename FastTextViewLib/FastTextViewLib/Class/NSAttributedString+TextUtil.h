//
//  NSAttributedString+TextUtil.h
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (TextUtil)



+ (NSAttributedString *)fromHtmlString:(NSString *)htmlstr withAttachmentPath:(NSString *)attachpath;



- (void)printDesc;

+ (NSMutableAttributedString *)scanAttachments:(NSMutableAttributedString *)_attributedString;

+ (NSString *)scanAttachmentsForNewFileName:(NSAttributedString *)_attributedString ;

+ (NSMutableAttributedString *)stripStyle:(NSAttributedString *) attrstring;

- (CGFloat)boundingHeightForWidth:(CGFloat)width;

@end
