//
//  FastTextStorage.h
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

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

enum {
    FastTextAttachmentCharacter = 0xfffc // The magical Unicode character for attachments in both Cocoa (NSAttachmentCharacter) and CoreText ('run delegate' there).
};
@class  FastTextStorage;

@protocol FastTextStorageDelegate <NSObject>

@optional
-(void)textStorageWillProcessEditing:(FastTextStorage *)storage;
-(void)textStorageDidProcessEditing:(FastTextStorage *)storage;
@end


@interface FastTextLine : NSObject {
@private
    CFRange _range;
    CGFloat _lineWidth;
    CGFloat _ascent;
    CGFloat _descent;
    CGFloat _leading;
   
}

@property(nonatomic,assign) CFRange range;
@property(nonatomic,assign) CGFloat lineWidth;
@property(nonatomic,assign) CGFloat ascent;
@property(nonatomic,assign) CGFloat descent;
@property(nonatomic,assign) CGFloat leading;

@end



@interface FastTextParagraph : NSObject {
@private
    NSRange _range;
    CGRect _rect;
    NSMutableArray *_lines;
    CGPoint *_origins ;
    NSMutableArray *_textAttchmentList;
    NSMutableArray *_linerefs;
    CGLayerRef _layer;
    CGFloat _pragraghSpaceHeight;
}

@property(nonatomic,assign) NSRange range;
@property(nonatomic,assign) CGRect rect;
@property(nonatomic,strong) NSMutableArray *lines;
@property(nonatomic,assign) CGPoint *origins ;
@property(nonatomic,strong) NSMutableArray *textAttchmentList;
@property(nonatomic,strong) NSMutableArray *linerefs;
@property(nonatomic,assign) CGLayerRef layer;

@property(nonatomic,assign) CGFloat pragraghSpaceHeight;


- (CGFloat) lineGetOriginY:(CGFloat)originy ;

- (CFRange) lineGetStringRange:(FastTextLine *)line;

-(CFIndex)lineGetStringIndexForPosition:(CTLineRef)line fastTextLine:(FastTextLine *)fastline piont:(CGPoint)convertedPoint;

-(CGFloat)lineGetGetOffsetForStringIndex:(CTLineRef)line fastTextLine:(FastTextLine *)fastline  charIndex:(CFIndex)charIndex secondaryOffset:(CGFloat*)secondaryOffset;

-(CGFloat)build:(NSAttributedString *)paraAttrstring paragraphSizeWidth:(CGFloat)paragraphSizeWidth paragraphOriginY:(CGFloat)paragraphOriginY paraRange:(NSRange)addParaRange isBuildLayer:(BOOL)isBuildLayer context:(CGContextRef)context;

@end





@interface FastTextStorage : NSMutableAttributedString{
    NSMutableAttributedString *_attrstring;
    NSMutableArray *_paragraphs;
    CGSize _paragraphSize;    
    __weak id <FastTextStorageDelegate> _delegate;
    BOOL _isEditing;
    BOOL _isScanAttribute;
    NSString *_buildParagraghTime;
    NSMutableArray *_textAttchmentList;
    NSMutableArray *_deleteParagraphs;;
    CGFloat _pragraghSpaceHeight;
    
}
@property(nonatomic,weak) id <FastTextStorageDelegate> delegate;
@property(nonatomic,assign) CGSize paragraphSize;
@property(nonatomic,strong) NSMutableArray *paragraphs;
@property(nonatomic,strong)  NSString *buildParagraghTime;

@property(nonatomic,assign) CGFloat pragraghSpaceHeight;

- (id)init;

- (id)initWithString:(NSString *)str;

- (id)initWithAttributedString:(NSAttributedString *)attrStr;

- (NSString *)string;

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range;

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range;

- (void)scanAttributes:(NSRange)range;

- (void)refreshParagraghInRange:(NSRange)range;

- (void)buildParagraph:(CGFloat)width;

- (void)rebuildLayer:(FastTextParagraph *)paragraph context:(CGContextRef)context;

- (CTLineRef)buildCTLineRef:(FastTextLine *)fastTextLine withParagraph:(FastTextParagraph *)paragraph;

//release unvisible region object
- (void)didReceiveMemoryWarning:(CGRect)visibleRect;

- (void)printLayer;

- (void)beginStorageEditing;

- (void)endStorageEditing;

- (NSArray *)textAttchmentList;

- (BOOL)isEditing;

-(void)clearDeleteParagraphs;

-(void)clearCacheLinerefs;

@end
