//
//  FastTextStorage.m
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

#import "FastTextStorage.h"
#import "NSMutableAttributedString+TextUtil.h"
#import "FastTextView.h"
#import "TextAttchment.h"
#import <AssetsLibrary/AssetsLibrary.h>


@implementation FastTextLine

@synthesize range=_range;
@synthesize lineWidth=_lineWidth;
@synthesize ascent=_ascent;
@synthesize descent=_descent;
@synthesize leading=_leading;

@end


@implementation FastTextParagraph

@synthesize range=_range,rect=_rect,lines=_lines,origins=_origins;
@synthesize textAttchmentList=_textAttchmentList;
@synthesize linerefs=_linerefs;
@synthesize layer=_layer;
@synthesize pragraghSpaceHeight=_pragraghSpaceHeight;


- (id)init {
    if ((self = [super init])) {    

    }
    return self;
}


- (CGFloat) lineGetOriginY:(CGFloat)originy {
    return self.rect.origin.y + originy;
}


- (CFRange) lineGetStringRange:(FastTextLine *)line{
    CFRange lineRange =line.range;
    return CFRangeMake(self.range.location+lineRange.location, lineRange.length);
}


-(CFIndex)lineGetStringIndexForPosition:(CTLineRef)line fastTextLine:(FastTextLine *)fastline piont:(CGPoint)convertedPoint{
    CFIndex index= CTLineGetStringIndexForPosition(line, convertedPoint);
    return self.range.location+fastline.range.location+index;
}

-(CGFloat)lineGetGetOffsetForStringIndex:(CTLineRef)line fastTextLine:(FastTextLine *)fastline charIndex:(CFIndex)charIndex secondaryOffset:(CGFloat*)secondaryOffset{
    CFIndex newcharIndex=charIndex-fastline.range.location;
    return CTLineGetOffsetForStringIndex(line, newcharIndex, secondaryOffset);

}

- (void)dealloc {    
    free(self.origins);   
    _lines=nil;        
    _textAttchmentList=nil;    
    _linerefs=nil;
    CGLayerRelease(_layer);
    //_layer=nil;
    NSLog(@"FastTextParagraph dealloc ");
    
}

-(CGFloat)build:(NSAttributedString *)paraAttrstring paragraphSizeWidth:(CGFloat)paragraphSizeWidth paragraphOriginY:(CGFloat)paragraphOriginY paraRange:(NSRange)addParaRange isBuildLayer:(BOOL)isBuildLayer context:(CGContextRef)context{

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)paraAttrstring);
    //NSLog(@"paraAttrstring %@",paraAttrstring);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(paragraphSizeWidth, CGFLOAT_MAX), NULL);
    
    //NSLog(@"suggestedSize %@ paraAttrstring %@ addParaRange %@",NSStringFromCGSize(suggestedSize),paraAttrstring,NSStringFromRange(addParaRange));
    
    CGRect rect=CGRectMake(0, paragraphOriginY, paragraphSizeWidth, suggestedSize.height);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    CTFrameRef frameRef =  CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), [path CGPath], NULL);
    
    NSArray *lines = (__bridge NSArray*)CTFrameGetLines(frameRef);
    CGPoint *origins = (CGPoint*)malloc([lines count] * sizeof(CGPoint));
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, [lines count]), origins);
    
    CFRelease(framesetter);
    CFRelease(frameRef);
    
    self.lines=[[NSMutableArray alloc]init];
    
    for (int i=0; i<lines.count; i++) {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex((CFArrayRef)lines, i);
        CGFloat ascent,descent,leading,linewidth;
        linewidth=CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CFRange lineRange =CTLineGetStringRange(line);
        
        FastTextLine *fastline=[[FastTextLine alloc]init];
        fastline.range=lineRange;
        fastline.ascent=ascent;
        fastline.descent=descent;
        fastline.leading=leading;
        fastline.lineWidth=linewidth;
        [self.lines addObject:fastline];
        
    }
    for (int i=0; i<lines.count; i++) {
        origins[i].y=origins[i].y+self.pragraghSpaceHeight;
    }
        

    self.origins=origins;
    self.range=addParaRange;
    self.rect=CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+self.pragraghSpaceHeight) ;
   
    
    if (isBuildLayer) {
#if RENDER_WITH_LINEREF        
        self.linerefs=[NSMutableArray arrayWithArray:lines];    
#else
        if (self.layer!=nil) {
            CGLayerRelease(self.layer);
        }
        if (context!=NULL) {
            self.layer=CGLayerCreateWithContext (context,self.rect.size, NULL);
            [self buildLayer:lines layer: self.layer];
        }       
       
        lines=nil;//clear line
#endif
    }   
    return suggestedSize.height+self.pragraghSpaceHeight;

}

-(void)buildLayer:(NSArray *)lines layer:(CGLayerRef)layer{
    
    CGContextRef ctx = CGLayerGetContext (layer);
    FastTextParagraph *textParagraph=self;
    
    _textAttchmentList=[[NSMutableArray alloc]init];
    
    NSInteger count = [lines count];
    
    CGPoint *origins =textParagraph.origins ;
    
    for (int i = 0 ; i < count; i++) {
        
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex((CFArrayRef)lines, i);
        
        CGFloat ascent,descent,leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGContextSetTextPosition(ctx,  origins[i].x, origins[i].y);
        
        CTLineDraw(line, ctx);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runsCount = CFArrayGetCount(runs);
        for (CFIndex runsIndex = 0; runsIndex < runsCount; runsIndex++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, runsIndex);
            CFDictionaryRef attributes = CTRunGetAttributes(run);
            id <FastTextAttachmentCell> attachmentCell = [( __bridge NSDictionary*)(attributes) objectForKey: FastTextAttachmentAttributeName];
            if (attachmentCell != nil && [attachmentCell respondsToSelector: @selector(attachmentSize)] && [attachmentCell respondsToSelector: @selector(attachmentDrawInRect:)]) {
                CGPoint position;
                CTRunGetPositions(run, CFRangeMake(0, 1), &position);
                
                CGSize size = [attachmentCell attachmentSize];
                CGPoint baselineOffset = [attachmentCell cellBaselineOffset];
                CGRect rect = { { origins[i].x + position.x+baselineOffset.x, origins[i].y + position.y+baselineOffset.y }, size };
                UIGraphicsPushContext(UIGraphicsGetCurrentContext());
                [attachmentCell attachmentDrawInRect: rect];
                UIGraphicsPopContext();
                
                TextAttchment *txtAttachment=[[TextAttchment alloc]init];
                
                txtAttachment.cellRect=rect;
                txtAttachment.attachmentcell=attachmentCell;
                [_textAttchmentList addObject:txtAttachment];
                
            }
        }
    }

}


@end



@implementation FastTextStorage

@synthesize paragraphs= _paragraphs;
@synthesize paragraphSize= _paragraphSize;
@synthesize delegate=_delegate;
@synthesize buildParagraghTime=_buildParagraghTime;
@synthesize pragraghSpaceHeight=_pragraghSpaceHeight;

- (id)init {
    if ((self = [super init])) {
        _attrstring= [[NSMutableAttributedString alloc] init];
        _paragraphs= [[NSMutableArray alloc]init];
        _paragraphSize =CGSizeZero;
        _isEditing=FALSE;
        _isScanAttribute=FALSE;
        _textAttchmentList= [[NSMutableArray alloc] init];

    }
    return self;
}

- (id)initWithString:(NSString *)str{
    if ((self = [self init])) {
       
        [self setAttributedString:[[NSAttributedString alloc]initWithString:str]];
    
    }
    return self;

}
- (id)initWithAttributedString:(NSAttributedString *)attrStr{
    
    if ((self = [self init])) {
        
        [self setAttributedString:[[NSAttributedString alloc]initWithAttributedString:attrStr]];
        
    }
    return self;
}

- (void)dealloc {
    _attrstring=nil;
    _paragraphs=nil;
    _delegate=nil;   
    _buildParagraghTime=nil;
    _textAttchmentList=nil;
    _deleteParagraphs=nil;
    NSLog(@"FastTextStorage dealloc ");
}

-(void)clearDeleteParagraphs{
    _deleteParagraphs=nil;
}

- (NSString *)string{
    return _attrstring.string;
}


- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range{
    return [_attrstring attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str{
    
    NSLog(@"_attrstring.string.length %d",_attrstring.string.length);

    if (range.location!=NSNotFound && (range.location + range.length)>_attrstring.string.length )  return; //避免错误
    
    double starttime=[[NSDate date]timeIntervalSince1970];
     
    NSMutableArray *changedParagraphIndex=[[NSMutableArray alloc]init];
    BOOL isDeleteAttach=[self beforeEditParagrapInRange:range withChangedParagraphIndex:changedParagraphIndex withString:str];
    
    [_attrstring replaceCharactersInRange:range withString:str];
    
    [self afterEditParagraphWithOldRangeLength:range.length withChangedParagraphIndex:changedParagraphIndex withString:str];
    
    //after delete attachment need to rescan
    if (isDeleteAttach && !_isScanAttribute) {
        [self editParagrapAttributesInRange:NSMakeRange(0, self.length)];     
    }
    
    
    double time3=[[NSDate date]timeIntervalSince1970];
    
    self.buildParagraghTime=[NSString stringWithFormat:@"editParagrapInRange starttime %f,endtime %f totaltime  %f",starttime,time3,time3-starttime];
   // NSLog(@"editParagrapInRange starttime %f,endtime %f totaltime  %f",starttime,time3,time3-starttime);
    
}

-(void)refreshParagraghInRange:(NSRange)range{
    if (range.location!=NSNotFound && (range.location + range.length)>_attrstring.string.length )  return; //避免错误

    
    NSString *str=[_attrstring.string  substringWithRange:range];

    NSMutableArray *changedParagraphIndex=[[NSMutableArray alloc]init];
    [self beforeEditParagrapInRange:range withChangedParagraphIndex:changedParagraphIndex withString:str];
    
    [self afterEditParagraphWithOldRangeLength:range.length withChangedParagraphIndex:changedParagraphIndex withString:str];

}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range{
    if (range.location!=NSNotFound && (range.location + range.length)>_attrstring.string.length )  return; //避免错误

    [_attrstring setAttributes:attrs range:range];
}

- (void)scanAttributes:(NSRange)range{
    if (range.location!=NSNotFound && (range.location + range.length)>_attrstring.string.length )  return; //避免错误

    
    if (!_isScanAttribute) {//avoid dead lock
        [self editParagrapAttributesInRange:range];
        [self refreshParagraghInRange:range];
    }
}


-(void)willProcessEditing{
    if (_delegate!=nil && [_delegate respondsToSelector:@selector(textStorageWillProcessEditing:)]) {
        [_delegate textStorageWillProcessEditing:self];
    }
}

-(void)didProcessEditing{
   
    if (_delegate!=nil && [_delegate respondsToSelector:@selector(textStorageDidProcessEditing:)]) {
        [_delegate textStorageDidProcessEditing:self];
    }
}

- (BOOL)isEditing{
    return _isEditing;
}


- (void)beginStorageEditing{
    _isEditing=TRUE;
    [self willProcessEditing];
    
}

-(void)endStorageEditing{    
    if (_isEditing) [self didProcessEditing];
    _isEditing=FALSE;
}

-(BOOL)beforeEditParagrapInRange:(NSRange)oldrange withChangedParagraphIndex:(NSMutableArray *)changedParagraphIndex withString:(NSString *)_newstring{
    //
    
    NSString *newstring=[_newstring copy];
    NSInteger changedLineIndex= -1;
    BOOL isSingleLineChange=FALSE;
    BOOL isHasLineBreak=FALSE;
    BOOL isDeleteLineBreak=FALSE;
    BOOL isDeleteAttachment=FALSE;
    
    if ([self isEmptyOrNull:newstring]) {
        newstring=@"";
    }
    
    if (([newstring rangeOfString:@"\n"].length>0)||[newstring rangeOfString:@"\r"].length>0) {
        isHasLineBreak=TRUE;
    }
    
//    if (oldrange.location!=NSNotFound && (oldrange.location + oldrange.length)<=_attrstring.string.length ) {
    if (([[_attrstring.string substringWithRange:oldrange ] rangeOfString:@"\n"].length>0)||([[_attrstring.string substringWithRange:oldrange ] rangeOfString:@"\r"].length>0)) {
        isDeleteLineBreak=TRUE;
    }
    
    
    unichar attachmentCharacter = FastTextAttachmentCharacter;
    if ([newstring rangeOfString:[NSString stringWithCharacters:&attachmentCharacter length:1]].length>0) {
        isHasLineBreak=TRUE;            
    }
    
    if ([[_attrstring.string substringWithRange:oldrange ] rangeOfString:[NSString stringWithCharacters:&attachmentCharacter length:1]].length>0) {
          isDeleteAttachment=TRUE;
    }
    
    //get changed paragraph's index list and changed line index 生成更新段落的索引列表和更改唯一行的索引
    for (int j=0; j<[_paragraphs count]; j++) {
        FastTextParagraph *textParagraph=[_paragraphs objectAtIndex:j];
        if ([self checkIntersectionWithBaseRange:textParagraph.range changeRange:oldrange]) { //check current paragraph is in changed range
            [changedParagraphIndex addObject:[NSNumber numberWithInt:j]];
            if ([changedParagraphIndex count]<=1 && !isHasLineBreak) { //only when chaned paragraph count <=1 and no input linebreak and image should check single line mode  只有 变更的章节数小于等于1 及用户没有输入回车 或者图片,才进行单行的判断
                NSArray *lines = textParagraph.lines;
                int m=0;
                for (int i=0; i < lines.count; i++) {
                    FastTextLine *fastline=[lines objectAtIndex:i];

                    CFRange cfRange =[textParagraph lineGetStringRange:fastline];
                    NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length == kCFNotFound ? 0 : cfRange.length);
                    if ([self checkIntersectionWithBaseRange:range changeRange:oldrange]) {//check current line is in changed range 此行在变更范围内
                        //if chenged line count >1 then build all paragraph  此处只记录一个改变的行，如果超出一行，则需要重置整个章节
                        if (m==0) {
                            changedLineIndex=i;
                            m++;
                            isSingleLineChange=TRUE;
                        }else{
                            changedLineIndex=-1;
                            isSingleLineChange=FALSE;
                            break;
                        }
                    }else{
                        continue;
                    }
                }
            }
        }else{
            if (isDeleteLineBreak) {
                NSRange nextrange = NSMakeRange(oldrange.location,MIN(oldrange.length+1,_attrstring.length) );
                if ([self checkIntersectionWithBaseRange:textParagraph.range changeRange:nextrange]) {//check current paragraph is in changed range 此段落在变更范围内
                    [changedParagraphIndex addObject:[NSNumber numberWithInt:j]];
                }
            }else{
                continue;
            }
            
            
        }
    }
  
    /*     
    //check to see if is single mode
    if(isSingleLineChange && changedLineIndex>=0){
        NSInteger paraindex=((NSNumber *)[changedParagraphIndex objectAtIndex:0]).intValue;
        FastTextParagraph *textParagraph=[_paragraphs objectAtIndex:paraindex];
        CTLineRef line = (__bridge CTLineRef)[textParagraph.lines objectAtIndex:changedLineIndex];
        CFRange cfRange =[textParagraph lineGetStringRange:line];
        NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length == kCFNotFound ? 0 : cfRange.length);
        
        NSInteger tmplength=range.length -oldrange.length+newstring.length;
        if (tmplength>=0) {
            NSRange newLineRange=NSMakeRange(range.location, tmplength);
            
            NSAttributedString *lineAttributedString=[self attributedSubstringFromRange:newLineRange];
            
            CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)lineAttributedString;
            
            CTTypesetterRef mTypesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
            CFIndex count = CTTypesetterSuggestLineBreak(mTypesetter, 0,_paragraphSize.width);
            if (count<=newLineRange.length) {//只分一行
                CTLineRef newline = CTTypesetterCreateLine(mTypesetter, CFRangeMake(0, count));
                [textParagraph.lines replaceObjectAtIndex:changedLineIndex withObject:(__bridge id)(newline)];
                //CFRelease(line);
                return;
            }
        }        
    }
    */
    
    return isDeleteAttachment;

}
-(void)afterEditParagraphWithOldRangeLength:(NSInteger)oldRangeLength withChangedParagraphIndex:(NSMutableArray *)changedParagraphIndex withString:(NSString *)newstring{

    
    //rebuild changed paragraph 重新生成指定的段落
    CGFloat oldHeight=0;
    NSRange oldParagraphRange=NSMakeRange(NSNotFound, 0);
    CGFloat oldParagraphOriginY=0;
    NSInteger startparaindex=0;
    NSInteger endparaindex=_paragraphs.count;    
    NSMutableArray *changedParas=[[NSMutableArray alloc]init];
   
    //some ready work 重建段落前的准备信息
    for (int i=0; i<[changedParagraphIndex count]; i++) {
        NSInteger paraindex=((NSNumber *)[changedParagraphIndex objectAtIndex:i]).intValue;
        if (i==0) {
            startparaindex=paraindex;
        }
        FastTextParagraph *textParagraph=[_paragraphs objectAtIndex:paraindex];
        oldHeight+=textParagraph.rect.size.height;
        if (oldParagraphRange.location==NSNotFound) {
            oldParagraphRange.location=textParagraph.range.location;
        }
        oldParagraphRange=NSUnionRange(oldParagraphRange, textParagraph.range);
        if(i==([changedParagraphIndex count]-1)){
            oldParagraphOriginY=textParagraph.rect.origin.y;
            endparaindex=paraindex;
        }        
    }    
    NSRange newParagraphRange=NSMakeRange(oldParagraphRange.location, oldParagraphRange.length -oldRangeLength+newstring.length);
    if (oldParagraphRange.location==NSNotFound) {
        newParagraphRange=NSMakeRange(0,newstring.length);
    }
//    NSLog(@"newParagraphRange %@  %@" ,NSStringFromRange(newParagraphRange),[self.string substringWithRange:newParagraphRange]);
    
    if (newParagraphRange.location!=NSNotFound) {
        //rebuild 重建段落
        CGFloat newHeight=[self buildParagraphWithRange:newParagraphRange oldParagraphOriginY:oldParagraphOriginY changedParagraphs:changedParas];
        
        //change forward paragragh's rect 更改前面段落的rect
        for (int i=0; i<MAX(0, startparaindex); i++) {
            FastTextParagraph *textParagraph=[_paragraphs objectAtIndex:i];
            //NSLog(@"rect %@  %@" ,NSStringFromRange(textParagraph.range),[self.string substringWithRange:textParagraph.range]);
            textParagraph.rect=CGRectMake(textParagraph.rect.origin.x, textParagraph.rect.origin.y-(oldHeight-newHeight), textParagraph.rect.size.width, textParagraph.rect.size.height);

        }
        
        //change backward paragragh's range 更新后续段落的rangge
        for (int i=(endparaindex+1); i<[_paragraphs count]; i++) {
            FastTextParagraph *textParagraph=[_paragraphs objectAtIndex:i];
            textParagraph.range=NSMakeRange(textParagraph.range.location-oldRangeLength+newstring.length, textParagraph.range.length);
        }

        //remove old paragragh 移除旧的段落
        if ([changedParagraphIndex count]>0) {
            for (int i=[changedParagraphIndex count]-1; i>=0; i--) {
                NSInteger paraindex=((NSNumber *)[changedParagraphIndex objectAtIndex:i]).intValue;
                FastTextParagraph *textParagraph=[_paragraphs objectAtIndex:paraindex];
                [_deleteParagraphs addObject:textParagraph];
                [_paragraphs removeObjectAtIndex:paraindex];
            }
        }
       
        //add new paragragh 加入新的段落
        if ([changedParas count]>0) {
            for (int i=[changedParas count]-1; i>=0; i--) {
                [_paragraphs insertObject:[changedParas objectAtIndex:i] atIndex:startparaindex];
            }
        }
       
        changedParas=nil;
        
        //caculate new height 重新计算整个高度
        if (_paragraphs.count==1) {
            FastTextParagraph *p= [_paragraphs objectAtIndex:0];
            if (p.lines.count<=1) {
                if (ABS(oldHeight-newHeight)<=10) {
                     _paragraphSize.height=MAX(_paragraphSize.height,newHeight);
                }else{
                    _paragraphSize.height=_paragraphSize.height-(oldHeight-newHeight);
                }
               
            }else{
                _paragraphSize.height=_paragraphSize.height-(oldHeight-newHeight);
            }
        }else{
            _paragraphSize.height=_paragraphSize.height-(oldHeight-newHeight);
        }
       
      
    }       
}



-(void)editParagrapAttributesInRange:(NSRange)oldrange{
    _isScanAttribute=TRUE;
    _textAttchmentList= [self scanAttachments];
    _isScanAttribute=FALSE;
}


-(CGFloat)buildParagraphWithRange:(NSRange)newParagraphRange oldParagraphOriginY:(CGFloat)oldParagraphOriginY changedParagraphs:(NSMutableArray *)changedParas {

    CGFloat newHeight=0;
    //build paragraph 生成段落
    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFStringRef newParagraphString=(__bridge CFStringRef)[self.string substringWithRange:newParagraphRange];
    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, newParagraphString, CFRangeMake(0, CFStringGetLength(newParagraphString)), kCFStringTokenizerUnitParagraph, locale);
    
    CFStringTokenizerTokenType tokenType = kCFStringTokenizerTokenNone;
    unsigned tokensFound = 0;
    
    NSMutableArray *rangelist=[[NSMutableArray alloc]init];
    while(kCFStringTokenizerTokenNone != (tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer))) {
        CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        //CFStringRef tokenValue = CFStringCreateWithSubstring(kCFAllocatorDefault, string, tokenRange);
        NSRange range = NSMakeRange(tokenRange.location == kCFNotFound ? NSNotFound : tokenRange.location, tokenRange.length);
        [rangelist addObject:NSStringFromRange(range)];        
        //CFRelease(tokenValue);
        ++tokensFound;
    }
    
    // Clean up
    CFRelease(tokenizer);
    CFRelease(locale);
    
   
    if ([rangelist count]>0) {
        CGFloat paragraphOriginY=oldParagraphOriginY;
        for (int i=[rangelist count]-1; i>=0; i--) {
            
            NSRange range =NSRangeFromString([rangelist objectAtIndex:i]);
            NSRange addParaRange=NSMakeRange(newParagraphRange.location+range.location, range.length);
            
            NSAttributedString *paraAttrstring=[self attributedSubstringFromRange:addParaRange];
            
            FastTextParagraph *fastTextParagraph=[[FastTextParagraph alloc]init];
            fastTextParagraph.pragraghSpaceHeight=self.pragraghSpaceHeight;
            
            CGFloat suggestedSizeheight=[fastTextParagraph build:paraAttrstring paragraphSizeWidth:_paragraphSize.width paragraphOriginY:paragraphOriginY paraRange:addParaRange isBuildLayer:NO context:NULL];
            
            paragraphOriginY+=suggestedSizeheight;
            newHeight+=suggestedSizeheight;           
            
            [changedParas insertObject:fastTextParagraph atIndex:0];
            
        }
       // [self printParagraphs];
    }
    return newHeight;
}


-(void)buildParagraph:(CGFloat)width{
    
    _paragraphSize=CGSizeMake(width, 0);
    
    _paragraphs=[[NSMutableArray alloc]init];
    
    NSRange newParagraphRange=NSMakeRange(0, self.length);
    
    CGFloat newHeight=[self buildParagraphWithRange:newParagraphRange oldParagraphOriginY:0 changedParagraphs:_paragraphs];
    
    _paragraphSize.height =newHeight;
}


-(void)rebuildLayer:(FastTextParagraph *)paragraph context:(CGContextRef)context{
    
    NSRange paraRange= NSMakeRange(paragraph.range.location, paragraph.range.length);
    NSAttributedString *mAttributedString=[self attributedSubstringFromRange:paraRange];
    @synchronized(paragraph){
        [paragraph build:mAttributedString paragraphSizeWidth:paragraph.rect.size.width  paragraphOriginY:paragraph.rect.origin.y paraRange:paragraph.range isBuildLayer:YES context:context];
    }
    
  
}


/*
 根据段落和行信息，重建CTLineRef
 according fastTextLine and  paragraph,rebuild CTLineRef
 */
-(CTLineRef)buildCTLineRef:(FastTextLine *)fastTextLine withParagraph:(FastTextParagraph *)paragraph{    
    NSRange lineRange= NSMakeRange(paragraph.range.location+fastTextLine.range.location, fastTextLine.range.length);
    NSAttributedString *mAttributedString=[self attributedSubstringFromRange:lineRange];
    //NSLog(@"buildCTLineRef %@",mAttributedString.string);
    CTTypesetterRef mTypesetter;
    mTypesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)mAttributedString);
    CTLineRef line = CTTypesetterCreateLine(mTypesetter, CFRangeMake(0, fastTextLine.range.length));
    CFRelease(mTypesetter);    
    return line;
}


-(BOOL)checkIntersectionWithBaseRange:(NSRange)baseRange changeRange:(NSRange)changeRange{
    if (baseRange.location==NSNotFound || changeRange.location==NSNotFound) {
        return FALSE;
    }
    if (changeRange.length==0) {
        if (changeRange.location >=baseRange.location
            && changeRange.location<=(baseRange.location+baseRange.length) ) {
            return TRUE;
        }else{
            return FALSE;
        }
    }
    NSRange intersectionRange=NSIntersectionRange(baseRange,changeRange);
    if (intersectionRange.length<= 0) {
        return FALSE;
    }    
    return TRUE;
    
}

-(NSArray *)textAttchmentList{

    return _textAttchmentList;
}


-(void)printParagraphs{
    int i=0;
    for (FastTextParagraph *textParagraph in _paragraphs) {
         NSLog(@"printParagraphs >> %d >> %@  %@" ,i,NSStringFromRange(textParagraph.range),[self.string substringWithRange:textParagraph.range]);
        i++;
    } 
}

-(void)printLayer{
    int i=0;
    for (FastTextParagraph *textParagraph in _paragraphs) {
        if (textParagraph.layer!=nil) {
             i++;
        }       
    }
     NSLog(@"printLayer >> %d / %d " ,i,_paragraphs.count);
}

-(BOOL) isEmptyOrNull:(NSString *)str {
    if (![str isKindOfClass:[NSString class]]) {
        return TRUE;
    }else if (str==nil) {
        return TRUE;
    }else if(!str) {
        // null object
        return TRUE;
    } else if(str==NULL) {
        // null object
        return TRUE;
    } else if([str isEqualToString:@"NULL"]) {
        // null object
        return TRUE;
    }
    return FALSE;
}

- (void)didReceiveMemoryWarning:(CGRect)visibleRect {
    
    CGFloat ystart=visibleRect.origin.y;
    CGFloat yend=visibleRect.origin.y+visibleRect.size.height;   
    
    for (int j=0; j<[self.paragraphs count]; j++) {
        
        FastTextParagraph *textParagraph=[self.paragraphs objectAtIndex:j];
        
        if (((textParagraph.rect.origin.y )>yend )) {
#if RENDER_WITH_LINEREF
            textParagraph.linerefs=nil;
#else
            CGLayerRelease(textParagraph.layer);   
#endif
            

        }else if (((textParagraph.rect.origin.y + textParagraph.rect.size.height)<ystart )){
#if RENDER_WITH_LINEREF
            textParagraph.linerefs=nil;
#else
            CGLayerRelease(textParagraph.layer);
#endif
        }
        
    }
    
    
    NSLog(@"FastTextStorage didReceiveMemoryWarning ");
}

-(void)clearCacheLinerefs{
    for (int j=0; j<[self.paragraphs count]; j++) {
        FastTextParagraph *textParagraph=[self.paragraphs objectAtIndex:j];
        
#if RENDER_WITH_LINEREF
        textParagraph.linerefs=nil;
#else
        CGLayerRelease(textParagraph.layer);
#endif
    }

}

@end
