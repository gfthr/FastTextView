//
//  NSMutableAttributedString+TextUtil.m
//  FastTextView
//
//  Created by gfthr on 8/4/12.
//  Copyright (C) 2011 by gfthr & ChineseAll.com .
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NSMutableAttributedString+TextUtil.h"
#import "FastTextView.h"
#import "TextAttchment.h"
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
//    NSLog(@"AttachmentRunDelegateGetSize(refCon).height %f",AttachmentRunDelegateGetSize(refCon).height);
    return AttachmentRunDelegateGetSize(refCon).height;
}

static CGFloat AttachmentRunDelegateGetWidth(void *refCon) {
    return AttachmentRunDelegateGetSize(refCon).width;
}
@implementation NSMutableAttributedString (TextUtil)
-(NSMutableArray *)scanAttachments {
   __block NSMutableArray *attachlist=[[NSMutableArray alloc]init];
    
    //    __block NSMutableAttributedString *mutableAttributedString = [_attributedString mutableCopy];
    
    [self enumerateAttribute: FastTextAttachmentAttributeName inRange: NSMakeRange(0, [self length]) options: 0 usingBlock: ^(id value, NSRange range, BOOL *stop) {
        // we only care when an attachment is set
        if (value != nil) {
            // create the mutable version of the string if it's not already there
            //            if (mutableAttributedString == nil)
            //                mutableAttributedString = [_attributedString mutableCopy];
            
            CTRunDelegateCallbacks callbacks = {
                .version = kCTRunDelegateVersion1,
                .dealloc = AttachmentRunDelegateDealloc,
                .getAscent = AttachmentRunDelegateGetDescent,
                //.getDescent = AttachmentRunDelegateGetDescent,
                .getWidth = AttachmentRunDelegateGetWidth
            };
            
            // the retain here is balanced by the release in the Dealloc function
            
            CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)((__bridge id)CFBridgingRetain(value)));
         
            id<FastTextAttachmentCell> cell=(id<FastTextAttachmentCell>)value;
            [cell setRange:range];
            
            if (cell != nil && [cell respondsToSelector: @selector(attachmentSize)] && [cell respondsToSelector: @selector(attachmentDrawInRect:)]) {
                TextAttchment *txtAttachment=[[TextAttchment alloc]init];
                
                txtAttachment.cellRect=CGRectZero;
                txtAttachment.attachmentcell=cell;
                [attachlist addObject:txtAttachment];
            }
         
            
            [self addAttribute: (NSString *)kCTRunDelegateAttributeName value: (__bridge id)runDelegate range:range];
            
            CFRelease(runDelegate);
        }
    }];
    return attachlist;
    
}

@end
