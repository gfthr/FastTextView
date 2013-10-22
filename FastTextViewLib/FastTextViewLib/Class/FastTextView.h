
//
//  FastTextView.h
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

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <UIKit/UITextChecker.h>
#include <objc/runtime.h>
#import "FastTextStorage.h"
#import "FileWrapperObject.h"
#import "AttributeConfig.h"

#define TILED_LAYER_MODE 1
#define RENDER_WITH_LINEREF 1

#define EMPTY_STRING @"　　"

extern NSString * const FastTextAttachmentAttributeName;
extern NSString * const FastTextParagraphAttributeName;


typedef enum {
    FastDisplayFull = 0, //full refresh 全部刷新
    FastDisplayRect = 1, //rect refresh 局部RECT刷新，一般是当前可视的局部刷新
} FastDisplayFlags;

@class FastTextView,TextAttchment;

@protocol FastTextViewDelegate <NSObject, UIScrollViewDelegate>
@optional
- (BOOL)fastTextViewShouldBeginEditing:(FastTextView *)textView;
- (BOOL)fastTextViewShouldEndEditing:(FastTextView *)textView;
- (void)fastTextViewDidBeginEditing:(FastTextView *)textView;
- (void)fastTextViewDidEndEditing:(FastTextView *)textView;
- (void)fastTextViewDidChange:(FastTextView *)textView;
- (void)fastTextViewDidChangeSelection:(FastTextView *)textView;
- (void)fastTextView:(FastTextView*)textView didSelectURL:(NSURL*)URL;
- (void)fastTextView:(FastTextView*)textView txtAttachmentLongPress:(TextAttchment*)textAttach;
- (void)fastTextViewSwipeUp:(FastTextView*)textView ;
- (void)fastTextViewSwipeDown:(FastTextView*)textView;
@end


@protocol FastTextAttachmentCell <NSObject>
@optional
- (UIView *)attachmentView;
- (CGSize) attachmentSize;
- (CGPoint)cellBaselineOffset;
- (void) attachmentDrawInRect: (CGRect)r;
@property (nonatomic,readwrite) NSRange range ;
@property (nonatomic,strong)  FileWrapperObject *fileWrapperObject;
@end


@interface FastIndexedPosition : UITextPosition {
    NSUInteger               _index;
    id <UITextInputDelegate> _inputDelegate;
}
@property (nonatomic) NSUInteger index;
+ (FastIndexedPosition *)positionWithIndex:(NSUInteger)index;
@end


//MARK: UITextRange definition
@interface FastIndexedRange : UITextRange {
    NSRange _range;
}
@property (nonatomic) NSRange range;
+ (FastIndexedRange *)rangeWithNSRange:(NSRange)range;
@end


@class FastCaretView, FastContentView, FastTextWindow, FastMagnifyView, FastSelectionView;
@interface FastTextView : UIScrollView <UITextInputTraits, UITextInput,UIScrollViewDelegate,FastTextStorageDelegate> {
@private
    NSDictionary                       *_markedTextStyle;
    __unsafe_unretained id <UITextInputDelegate>           _inputDelegate;
    UITextInputStringTokenizer         *_tokenizer;
    UITextChecker                      *_textChecker;
    UILongPressGestureRecognizer       *_longPress;    
    BOOL _ignoreSelectionMenu;
    BOOL _delegateRespondsToShouldBeginEditing;
    BOOL _delegateRespondsToShouldEndEditing;
    BOOL _delegateRespondsToDidBeginEditing;
    BOOL _delegateRespondsToDidEndEditing;
    BOOL _delegateRespondsToDidChange;
    BOOL _delegateRespondsToDidChangeSelection;
    BOOL _delegateRespondsToDidSelectURL;
    BOOL _delegateRespondsToSwipUp;
    BOOL _delegateRespondsToSwipDown;
    
    FastTextStorage  *_attributedString;
    UIFont              *_font; 
    BOOL                _editing;
    BOOL                _editable;
    BOOL                _dirty; //脏标志
    NSRange             _markedRange;
    NSRange             _selectedRange;
    NSRange             _correctionRange;
    NSRange             _linkRange;    
    CGRect              _viewframe;   
    FastContentView      *_textContentView;
    FastTextWindow       *_textWindow;
    FastCaretView        *_caretView;
    FastSelectionView    *_selectionView;
    UILabel              *_placeHolderView;    
    NSMutableArray      *_attachmentViews;
    NSMutableArray      *_visibleTextAttchList;    
    UIView *_inputView;
    UIView *_inputAccessoryView;
            
    BOOL isSecondTap; //second tap  gfthr ADD 记录是否第二次点击
    FastDisplayFlags displayFlags; //refresh mode  刷新模式
    CGFloat oldOffset; //last scrollview Offset 上一次scrollview 的 Offset    
    int visibleRectFirstLineIndex; //visible region first line index 可见区域的第一行行号    
    int caretLineIndex; //caret Line Index  光标所在的行号
    CGFloat caretLineWidth; //caret Line width   光标所在的行的宽度    
    int caretLineIndex_selected; //when selectedRang.length>0 caret Line Index,selectedRang.length>0 时 前导光标所在的行号
    NSString *lastMarkedText;
    
    double beginedittime;
    NSString  *actiontime;
    NSString  *txtreplacetime;
    double txtchangetime;
    double selectedRangetime;
    double caretedittime;
    double setneeddisplaytime;
    double drawrecttime;

    NSString *_placeHolder;    
    BOOL isInsertText;
    BOOL isFirstResponser;
    CGFloat _pragraghSpaceHeight;
}

@property(nonatomic) UIDataDetectorTypes dataDetectorTypes; // UIDataDetectorTypeLink supported
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic) UITextAutocorrectionType autocorrectionType;        
@property(nonatomic) UIKeyboardType keyboardType;                       
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;             
@property(nonatomic) UIReturnKeyType returnKeyType;                    
@property(nonatomic) BOOL enablesReturnKeyAutomatically; 
@property(nonatomic,unsafe_unretained) id <FastTextViewDelegate> delegate;
@property(nonatomic,copy) FastTextStorage *attributedString;
@property(nonatomic,copy) NSString *text;
@property(nonatomic,strong) UIFont *font; // ignored when attributedString is not nil
@property(nonatomic,getter=isEditable) BOOL editable; //default YES
@property(nonatomic) NSRange selectedRange;
@property(nonatomic) NSRange markedRange;
@property(nonatomic,strong) NSString *placeHolder;
@property (nonatomic, readwrite, retain) UIView *inputView;
@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;
@property(nonatomic,readwrite,getter=isDirty) BOOL dirty; //default NO
@property(nonatomic,strong) AttributeConfig *attributeConfig;

@property(nonatomic,assign) CGFloat pragraghSpaceHeight;
@property(nonatomic,assign) BOOL isImageSigleLine;

- (BOOL)hasText;
- (void)deleteWithRange:(NSRange)range;
- (void)addAttachmentWithCell:(NSObject <FastTextAttachmentCell> *)cell;
- (void)editAttachmentWithCell:(NSObject <FastTextAttachmentCell> *)cell rang:(NSRange)range;
- (void)setDisplayFlags:(FastDisplayFlags)flags;
- (void)didReceiveMemoryWarning ;
- (CGFloat)getContentViewHeight;

-(void)refreshView;
-(void)refreshAllView;

- (void)selectionChanged;


@end