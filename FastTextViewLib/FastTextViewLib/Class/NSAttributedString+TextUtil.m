//
//  NSAttributedString+TextUtil.m
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import "NSAttributedString+TextUtil.h"
//#import "NSString+TextUtil.h"
#import "TextParagraph.h"
//#import "ImageAttachmentCell.h"
//#import "SlideAttachmentCell.h"
//#import "UIImage-Extensions.h"
#import "NSMutableAttributedString+TextUtil.h"
#import "FileWrapperObject.h"
#import "FastTextView.h"
// MARK: Text attachment helper functions
static void AttachmentRunDelegateDealloc(void *refCon) {
    CFBridgingRelease(refCon);
}

static CGSize AttachmentRunDelegateGetSize(void *refCon) {
    id <FastTextAttachmentCell> cell = (__bridge  id<FastTextAttachmentCell>)(refCon);
    if ([cell respondsToSelector: @selector(attachmentSize)]) {
        return [cell attachmentSize];
    } else {
        return [[cell attachmentView] frame].size;
    }
}

static CGFloat AttachmentRunDelegateGetDescent(void *refCon) {
    return AttachmentRunDelegateGetSize(refCon).height;
}

static CGFloat AttachmentRunDelegateGetWidth(void *refCon) {
    return AttachmentRunDelegateGetSize(refCon).width;
}


@implementation NSAttributedString (TextUtil)


-(NSString *)getUnixTimestamp:(NSDate *)curdate{
    
    //NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[curdate timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
}


-(NSInteger)getRandFromOnetoX:(NSInteger)x{
    return  (arc4random() % x) + 1;
}

+ (NSAttributedString *)fromHtmlString:(NSString *)htmlstr withAttachmentPath:(NSString *)attachpath
{
    //    OpenEditMarkupParser *markupParser=[[OpenEditMarkupParser alloc]init];
    //    NSAttributedString *retstr=[markupParser attrStringFromMarkup:htmlstr withAttachmentPath:attachpath];
    //    return retstr;
    return nil;
}






-(void)printDesc{
    [self enumerateAttributesInRange:NSMakeRange(0, [self length]) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop){
        NSLog(@"beigin ------ %@ ",NSStringFromRange(range));
        
        NSAttributedString *tmpstr=[self attributedSubstringFromRange:range];
        
        NSLog(@" tmpstr.string %@ ",tmpstr.string);
        NSLog(@"  %@ ",attrs);
        NSLog(@">>>>end ------ %@ ",NSStringFromRange(range));
    }];
    NSLog(@">>>>>%@ ",@"finished");
    
}

+(NSMutableAttributedString *)scanAttachments:(NSMutableAttributedString *)_attributedString {
    
    NSMutableArray *temArray = [_attributedString scanAttachments];
    [temArray removeAllObjects];
    temArray = nil;
    return _attributedString;
    
////    __block NSMutableAttributedString *mutableAttributedString = [_attributedString mutableCopy];
//    
//    [_attributedString enumerateAttribute: FastTextAttachmentAttributeName inRange: NSMakeRange(0, [_attributedString length]) options: 0 usingBlock: ^(id value, NSRange range, BOOL *stop) {
//        // we only care when an attachment is set
//        if (value != nil) {
//            // create the mutable version of the string if it's not already there
//            //            if (mutableAttributedString == nil)
//            //                mutableAttributedString = [_attributedString mutableCopy];
//            
//            CTRunDelegateCallbacks callbacks = {
//                .version = kCTRunDelegateVersion1,
//                .dealloc = AttachmentRunDelegateDealloc,
//                .getAscent = AttachmentRunDelegateGetDescent,
//                //.getDescent = AttachmentRunDelegateGetDescent,
//                .getWidth = AttachmentRunDelegateGetWidth
//            };
//            
//            // the retain here is balanced by the release in the Dealloc function
//            
//            CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)((__bridge id)CFBridgingRetain(value)));
//            
//            id<FastTextAttachmentCell> cell=(id<FastTextAttachmentCell>)value;
//            [cell setRange:range];
//            
//            [_attributedString addAttribute: (NSString *)kCTRunDelegateAttributeName value: (__bridge id)runDelegate range:range];
//            
//            CFRelease(runDelegate);
//        }
//    }];
//    
//    return _attributedString;

}


+(NSString *)scanAttachmentsForNewFileName:(NSAttributedString *)_attributedString {
    __block NSString *newFilename=@"a1.jpg";
    __block int maxfileid=1;
    
    [_attributedString enumerateAttribute: FastTextAttachmentAttributeName inRange: NSMakeRange(0, [_attributedString length]) options: 0 usingBlock: ^(id value, NSRange range, BOOL *stop) {
        if (value != nil) {         
            
            id<FastTextAttachmentCell> cell=(id<FastTextAttachmentCell>)value;
        
            NSString *filename=[cell.fileWrapperObject.fileName lowercaseString];
            if (filename!=nil && [[filename substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"a"]) {
                int nowfileid= [self getObjectIntValue:[[filename stringByDeletingPathExtension] substringFromIndex:1]]+1;
                if (nowfileid>maxfileid) {
                    maxfileid=nowfileid;
                }                
            }           
        }
    }];
    
    newFilename=[NSString stringWithFormat:@"a%d.jpg",maxfileid];    
    
    return newFilename;
    
}

+(NSInteger)getObjectIntValue:(id)obj{
    
    NSNumber *_intvalue= (NSNumber *)obj;
    
    if (_intvalue!=nil && _intvalue!=(NSNumber *)[NSNull null]){
        return _intvalue.intValue;
    } else {
        return 0;
    }
    
}



+ (NSMutableAttributedString *)stripStyle:(NSAttributedString *) attrstring{
    //只保留附件属性
    
    __block NSMutableAttributedString *mutableAttributedString =[[NSMutableAttributedString alloc]initWithString: [attrstring string]];
    
    
    [attrstring enumerateAttribute: FastTextAttachmentAttributeName inRange: NSMakeRange(0, [attrstring length]) options: 0 usingBlock: ^(id value, NSRange range, BOOL *stop) {
        if (value != nil) {
            
            id<FastTextAttachmentCell> cell=(id<FastTextAttachmentCell>)value;
            
           [mutableAttributedString addAttribute: FastTextAttachmentAttributeName value:cell range:range];
        }
    }];

    
    
    if (mutableAttributedString) {
        return mutableAttributedString;
    }
    return nil;
}


//////

- (CGFloat)boundingHeightForWidth:(CGFloat)width {
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef) self);
    CGRect box = CGRectMake(0,0, width, CGFLOAT_MAX);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, box);
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
    CFRelease(path);
    return suggestedSize.height;
    
}


@end
