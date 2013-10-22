//
//  FastTextView.m
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

#import "FastTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "TextAttchment.h"
//#import "TextConfig.h"
#import "NSAttributedString+TextUtil.h"
//#import "SlideAttachmentCell.h"
#import "ContentViewTiledLayer.h"
//#import "MemoryDebugMaster.h"

NSString * const FastTextAttachmentAttributeName = @"com.itangyuan.FastTextAttachmentAttribute";
NSString * const FastTextParagraphAttributeName = @"com.itangyuan.FastTextParagraphAttribute";
NSString * const TangyuanAttributeStringUTI = @" com.itangyuan.NSAttributedString";

typedef enum {
    FastWindowLoupe = 0,
    FastWindowMagnify,
} FastWindowType;

typedef enum {
    FastSelectionTypeLeft = 0,
    FastSelectionTypeRight,
} FastSelectionType;


// MARK: FastContentView definition

@interface FastContentView : UIView {
    
@private
     id __weak _delegate;    
    #if TILED_LAYER_MODE
    ContentViewTiledLayer *_tiledLayer;
    #endif
}
@property(nonatomic,weak) id delegate;
@property (nonatomic, readonly) ContentViewTiledLayer *tiledLayer;
-(void) refreshView;
-(void) refreshAllView;

@end

// MARK: FastCaretView definition

@interface FastCaretView : UIView {
    
    NSTimer *_blinkTimer;
}
- (void)delayBlink;
- (void)show;

@end


// MARK: FastLoupeView definition

@interface FastLoupeView : UIView {
    
@private
    UIImage *_contentImage;
}
- (void)setContentImage:(UIImage*)image;

@end


// MARK: MagnifyView definition

@interface FastMagnifyView : UIView {
    
@private
    UIImage *_contentImage;
}
- (void)setContentImage:(UIImage*)image;

@end


// MARK: FastTextWindow definition

@interface FastTextWindow : UIWindow {
    
@private
    UIView              *_view;
    FastWindowType       _type;
    FastSelectionType    _selectionType;
    BOOL                _showing;    
}

@property(nonatomic,assign) FastWindowType type;
@property(nonatomic,assign) FastSelectionType selectionType;
@property(nonatomic,readonly,getter=isShowing) BOOL showing;
- (void)setType:(FastWindowType)type;
- (void)renderWithContentView:(UIView*)view fromRect:(CGRect)rect;
- (void)showFromView:(UIView*)view rect:(CGRect)rect;
- (void)hide:(BOOL)animated;
- (void)updateWindowTransform;

@end


// MARK: FastSelectionView definition

@interface FastSelectionView : UIView {
    
@private
    UIView *_leftDot;
    UIView *_rightDot;
    UIView *_leftCaret;
    UIView *_rightCaret;
}
- (void)setBeginCaret:(CGRect)begin endCaret:(CGRect)rect;

@end


// MARK: FastTextView private

@interface FastTextView (Private)

- (CGRect)caretRectForIndex:(int)index;
- (CGRect)caretRectForIndex:(int)index point:(CGPoint)point ;
- (CGRect)firstRectForNSRange:(NSRange)range;
- (NSInteger)closestIndexToPoint:(CGPoint)point;
- (NSRange)characterRangeAtPoint_:(CGPoint)point;
- (void)checkSpellingForRange:(NSRange)range;
- (void)textChanged;
- (void)removeCorrectionAttributesForRange:(NSRange)range;
- (void)insertCorrectionAttributesForRange:(NSRange)range;
- (void)showCorrectionMenuForRange:(NSRange)range;
- (void)checkLinksForRange:(NSRange)range;
- (void)showMenu;
- (CGRect)menuPresentationRect;
- (void)insertAttributedString:(NSAttributedString *)newString ;
- (NSAttributedString *)stripStyle:(NSAttributedString *) attrstring;
+ (UIColor *)selectionColor;
+ (UIColor *)spellingSelectionColor;
+ (UIColor *)caretColor;

@end


@interface FastTextView ()


@property(nonatomic,strong) NSDictionary *correctionAttributes;
@property(nonatomic,strong) NSMutableDictionary *menuItemActions;
@property(nonatomic) NSRange correctionRange;

@end


@implementation FastTextView

@synthesize delegate;
@synthesize attributedString=_attributedString;
@synthesize text=_text;
@synthesize font=_font;
@synthesize editable=_editable;
@synthesize dirty=_dirty;
@synthesize markedRange=_markedRange;
@synthesize selectedRange=_selectedRange;
@synthesize correctionRange=_correctionRange;
@synthesize attributeConfig=_attributeConfig;
@synthesize correctionAttributes=_correctionAttributes;
@synthesize markedTextStyle=_markedTextStyle;
@synthesize inputDelegate=_inputDelegate;
@synthesize menuItemActions;
@synthesize dataDetectorTypes;
@synthesize autocapitalizationType;
@synthesize autocorrectionType;
@synthesize keyboardType;
@synthesize keyboardAppearance;
@synthesize returnKeyType;
@synthesize enablesReturnKeyAutomatically;
@synthesize inputView = _inputView;
@synthesize inputAccessoryView = _inputAccessoryView;
@synthesize placeHolder=_placeHolder;
@synthesize pragraghSpaceHeight=_pragraghSpaceHeight;

@synthesize isImageSigleLine;


-(void)setDisplayFlags:(FastDisplayFlags)flags{
    displayFlags=flags;
}


- (void)commonInit {
    self.alwaysBounceVertical = YES;
    self.editable = YES;
    _dirty=NO;
    isSecondTap=NO;
    isInsertText=NO;
    isFirstResponser=NO;
    self.backgroundColor = [UIColor clearColor];
    //[UIColor colorWithPatternImage:[UIImage imageNamed:@"paperbg.png"]];
   
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.clipsToBounds = YES;
  
   
    
   //FastContentView *contentView = [[FastContentView alloc] initWithFrame:CGRectInset(self.bounds, 8.0f, 8.0f)];
    
    FastContentView *contentView = [[FastContentView alloc] initWithFrame:CGRectMake(10, 8, self.bounds.size.width-16, self.bounds.size.height-16)];
    contentView.autoresizingMask =  self.autoresizingMask;
    contentView.delegate = self;
    contentView.backgroundColor=[UIColor clearColor];
    [self addSubview:contentView];
    _textContentView = contentView;
    
    [self showPlaceHolderView];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    gesture.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self addGestureRecognizer:gesture];
    _longPress = gesture;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:singleTap];
    
    /*
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUp:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer1;
    recognizer1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self addGestureRecognizer:recognizer1];
    */   
    
    _visibleTextAttchList=[[NSMutableArray alloc] init];
//    self.attributeConfig=[TextConfig editorAttributeConfig];    
    self.font =  self.attributeConfig.font;
    
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    oldOffset=self.contentOffset.y;
    
    displayFlags=FastDisplayFull;
   
    [self setText:@""];
    
#if TILED_LAYER_MODE
    //    CGSize size0=CGSizeMake(_textContentView.frame.size.width*2, self.frame.size.height*8);
    //    tiledLayer.tileSize =size0 ;
    
    ContentViewTiledLayer *tiledLayer = (ContentViewTiledLayer *)[_textContentView layer];
    
    tiledLayer.levelsOfDetail = 1;
    tiledLayer.levelsOfDetailBias = 0;
    // get larger dimension and multiply by scale
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat largerDimension = MAX(mainScreen.applicationFrame.size.width, mainScreen.applicationFrame.size.height);
    CGFloat scale = mainScreen.scale;
    // this way tiles cover entire screen regardless of orientation or scale
    CGSize tileSize = CGSizeMake(largerDimension * scale, largerDimension * scale);
    tiledLayer.tileSize = tileSize;
#endif
    
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (id)init {
    if ((self = [self initWithFrame:CGRectZero])) {}
    return self;
}

- (id)initWithCoder: (NSCoder *)aDecoder {
    if ((self = [super initWithCoder: aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)didReceiveMemoryWarning {    
    [_attributedString didReceiveMemoryWarning:[self getVisibleRect]];    
    NSLog(@"fastTextView didReceiveMemoryWarning ");
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset"];
    [self removeObserver:self forKeyPath:@"contentSize"];
    _markedTextStyle=nil;
    _tokenizer=nil;
    _textChecker=nil;    
    _font=nil;
    _attributedString=nil;
    _font=nil;
    _textContentView=nil;
    _textWindow=nil;
    _caretView=nil;    
    _selectionView=nil;
    _placeHolderView=nil;
    _attachmentViews=nil;
    _visibleTextAttchList=nil;
    _inputView=nil;
    _inputAccessoryView=nil;
    lastMarkedText=nil;
    actiontime=nil;
    txtreplacetime=nil;
    _placeHolder=nil;
}

-(void)refreshView{
    [_textContentView refreshView];
}

-(void)refreshAllView{
    [_textContentView refreshAllView];
}



-(void)setPlaceHolder:(NSString *)mplaceHolder{
    _placeHolder=mplaceHolder;
    [self showPlaceHolderView];
}

-(void)showPlaceHolderView{
    if (_placeHolderView !=nil) {
        [_placeHolderView removeFromSuperview];
    }    
    _placeHolderView =[[UILabel alloc]initWithFrame:CGRectMake(8, 8, 100, 20)];
    [_placeHolderView setText:_placeHolder];
    [_placeHolderView setFont:[UIFont systemFontOfSize:16]];
    [_placeHolderView setTextColor:[UIColor lightGrayColor]];
    _placeHolderView.backgroundColor=[UIColor clearColor];
    [self addSubview:_placeHolderView];
}

-(void)recaculate{

    CGRect rect = _textContentView.frame;
    CGFloat height = 0;
    if (_attributedString!=nil) {
        height= _attributedString.paragraphSize.height;
    }   
    rect.size.height = height;//+self.font.lineHeight
    
    _textContentView.frame =CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, MAX(rect.size.height, 0));
    
    
    
    //NSLog(@" _textContentView.frame %@",NSStringFromCGRect(_textContentView.frame));
    
//    NSLog(@"NSStringFromCGRect(self.frame) %@  NSStringFromCGRect(self.bounds) %@  _textContentView.frame %@ _textContentView.bounds %@ ",NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds),NSStringFromCGRect(_textContentView.frame),NSStringFromCGRect(_textContentView.bounds));
    
    self.contentSize = CGSizeMake(self.frame.size.width, rect.size.height+(self.font.lineHeight*2));
    
//    UIMenuController *menuController = [UIMenuController sharedMenuController];
//    if ([menuController isMenuVisible]) {
//        [self performSelector:@selector(showMenu) withObject:nil afterDelay:0.35f];
//    }

    //self.bounds=CGRectMake(self.bounds.origin.x,0,self.bounds.size.width,self.bounds.size.height);
    
/*    #if TILED_LAYER_MODE
//    CGSize size0=CGSizeMake(_textContentView.frame.size.width*2, self.frame.size.height*8);
    //    tiledLayer.tileSize =size0 ;
    
    ContentViewTiledLayer *tiledLayer = (ContentViewTiledLayer *)[_textContentView layer];

    tiledLayer.levelsOfDetail = 1;
    tiledLayer.levelsOfDetailBias = 0;    
    // get larger dimension and multiply by scale
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat largerDimension = MAX(mainScreen.applicationFrame.size.width, mainScreen.applicationFrame.size.height);
    CGFloat scale = mainScreen.scale;
    // this way tiles cover entire screen regardless of orientation or scale
    CGSize tileSize = CGSizeMake(largerDimension * scale, largerDimension * scale);
    tiledLayer.tileSize = tileSize;
    #endif
 */
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

-(CGFloat)getContentViewHeight{    
    return self.attributedString.paragraphSize.height+self.font.lineHeight;    
}

-(void)layoutChange{    
    CGRect rect2 =  _textContentView.frame;
    rect2.size.height = self.attributedString.paragraphSize.height;
    _textContentView.frame= CGRectMake(rect2.origin.x, rect2.origin.y, rect2.size.width, MAX(rect2.size.height, 0));
    
    
     //NSLog(@"layoutChange  _textContentView.frame %@",NSStringFromCGRect(_textContentView.frame));
    
    self.contentSize=CGSizeMake(self.frame.size.width, _textContentView.frame.size.height+(self.font.lineHeight*2));
    
    for (UIView *view in _attachmentViews) {
        [view removeFromSuperview];
    }
    [_attributedString enumerateAttribute: FastTextAttachmentAttributeName inRange: NSMakeRange(0, [_attributedString length]) options: 0 usingBlock: ^(id value, NSRange range, BOOL *stop) {
        
        if ([value respondsToSelector: @selector(attachmentView)]) {
            UIView *view = [value attachmentView];
            [_attachmentViews addObject: view];
            
            CGRect rect = [self firstRectForNSRange: range];
            rect.size = [view frame].size;
            [view setFrame: rect];
            [self addSubview: view];
        }
    }];   
}

//#pragma mark

-(void)textStorageWillProcessEditing:(FastTextStorage *)storage{
    if(_delegateRespondsToDidBeginEditing)
        [self.delegate fastTextViewDidBeginEditing:self];
}

-(void)textStorageDidProcessEditing:(FastTextStorage *)storage{
    [self layoutChange];
    if(_delegateRespondsToDidEndEditing)
        [self.delegate fastTextViewDidEndEditing:self];
}

- (NSString *)text {
    return _attributedString.string;
}

- (void)setFont:(UIFont *)font {    
    _font = font;
    [_attributedString beginStorageEditing];
    [self.attributeConfig setFont:font];
    [self.attributedString buildParagraph:self.attributedString.paragraphSize.width];
    [_attributedString endStorageEditing];      
}

- (void)setText:(NSString *)text {
    
    [self.inputDelegate textWillChange:self];
    _attributedString =[[FastTextStorage alloc]initWithString:text];
    _attributedString.paragraphSize=CGSizeMake(_textContentView.frame.size.width, 0);
    _attributedString.delegate=self;
    
    [_attributedString beginStorageEditing];
    [_attributedString buildParagraph:_attributedString.paragraphSize.width];
    [_attributedString scanAttributes:NSMakeRange(0, _attributedString.length)];
    [_attributedString endStorageEditing];
    
    [self.inputDelegate textDidChange:self];
    
    [_textContentView refreshView];
    
//    if (self.attributedString.length>0 && _placeHolderView!=nil ) {
//        [_placeHolderView removeFromSuperview];
//        _placeHolderView=nil;
//    }
    
    if ( ((self.attributedString.length==2 &&![_attributedString.string isEqualToString:EMPTY_STRING])
          ||self.attributedString.length!=2)
        && _placeHolderView!=nil ) {
        [_placeHolderView removeFromSuperview];
        _placeHolderView=nil;
    }
    
    if(self.attributedString.length==2 && [_attributedString.string isEqualToString:EMPTY_STRING]){
        [_caretView removeFromSuperview];
    }

}

- (void)setAttributedString:(NSMutableAttributedString *)string {
    
   

    _attributedString =[[FastTextStorage alloc]initWithAttributedString:string];
    _attributedString.pragraghSpaceHeight=self.pragraghSpaceHeight;
    _attributedString.paragraphSize=CGSizeMake(_textContentView.frame.size.width, 0);
    _attributedString.delegate=self;
    
    if (string.length==0) {
        [self insertText:EMPTY_STRING];
    }
    
    [_attributedString beginStorageEditing];
    [_attributedString buildParagraph:_attributedString.paragraphSize.width];
    
    [_attributedString scanAttributes:NSMakeRange(0, _attributedString.length)];
    
    [_attributedString endStorageEditing];

    [_textContentView refreshView];
    
    //if (self.attributedString.length>0 && _placeHolderView!=nil ) {
    if ( ((self.attributedString.length==2 &&![_attributedString.string isEqualToString:EMPTY_STRING])
          ||self.attributedString.length!=2)
        && _placeHolderView!=nil ) {
        [_placeHolderView removeFromSuperview];
        _placeHolderView=nil;
    }
    
    if(self.attributedString.length==2 && [_attributedString.string isEqualToString:EMPTY_STRING]){
        [_caretView removeFromSuperview];
    }
    
}


- (void)setDelegate:(id<FastTextViewDelegate>)aDelegate {
    [super setDelegate:(id<UIScrollViewDelegate>)aDelegate];
    
    delegate = aDelegate;
    
    _delegateRespondsToShouldBeginEditing = [delegate respondsToSelector:@selector(fastTextViewShouldBeginEditing:)];
    _delegateRespondsToShouldEndEditing = [delegate respondsToSelector:@selector(fastTextViewShouldEndEditing:)];
    _delegateRespondsToDidBeginEditing = [delegate respondsToSelector:@selector(fastTextViewDidBeginEditing:)];
    _delegateRespondsToDidEndEditing = [delegate respondsToSelector:@selector(fastTextViewDidEndEditing:)];
    _delegateRespondsToDidChange = [delegate respondsToSelector:@selector(fastTextViewDidChange:)];
    _delegateRespondsToDidChangeSelection = [delegate respondsToSelector:@selector(fastTextViewDidChangeSelection:)];
    _delegateRespondsToDidSelectURL = [delegate respondsToSelector:@selector(fastTextView:didSelectURL:)];
    _delegateRespondsToSwipUp= [delegate respondsToSelector:@selector(fastTextViewSwipeUp:)];
    _delegateRespondsToSwipDown= [delegate respondsToSelector:@selector(fastTextViewSwipeDown:)];

    
}

- (void)setEditable:(BOOL)editable {
    
    if (editable) {
        
        if (_caretView==nil) {
            _caretView = [[FastCaretView alloc] initWithFrame:CGRectZero];
        }
        
        _tokenizer = [[UITextInputStringTokenizer alloc] initWithTextInput:self];
        _textChecker = [[UITextChecker alloc] init];
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:(int)(kCTUnderlineStyleThick|kCTUnderlinePatternDot)], kCTUnderlineStyleAttributeName, (id)[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f].CGColor, kCTUnderlineColorAttributeName, nil];
        self.correctionAttributes = dictionary;
        
    } else {
        
        if (_caretView) {
            [_caretView removeFromSuperview];
            _caretView=nil;
        }
        
        self.correctionAttributes=nil;
        if (_textChecker!=nil) {
            _textChecker=nil;
        }
        if (_tokenizer!=nil) {
            _tokenizer=nil;
        }
        
    }
    _editable = editable;
    
}


/*
 Searches for the CTLine containing a given string index (queryIndex), confining the search to the range [l,h).
 The line's index is returned and a line ref is stored in *foundLine.
 If the index is not found, a value outside [l,h) returned and *foundLine is not modified.
 Note that the index is interpreted as referring to a character, not to an intercharacter space.
 */
static CFIndex bsearchLines(CFArrayRef lines, CFIndex l, CFIndex h, CFIndex queryIndex, CTLineRef *foundLine)
{
    CFIndex orig_h = h;
    
    while (h > l) {
        CFIndex m = ( h + l - 1 ) >> 1;
        CTLineRef line = CFArrayGetValueAtIndex(lines, m);
        CFRange lineRange = CTLineGetStringRange(line);
        
        if (lineRange.location > queryIndex) {
            h = m;
        } else if ((lineRange.location + lineRange.length) > queryIndex) {
            if (foundLine)
                *foundLine = line;
            return m;
        } else {
            l = m + 1;
        }
    }
    return ( l < orig_h )? kCFNotFound : l;
}



/* Similar to bsearchLines(), but finds a CTRun within a CTLine. */
/* We can't do a binary search, because runs are visually ordered, not logically ordered (experimentally true, but undocumented) */
/* Hopefully a given character index will only ever be claimed by one run... */
/* Note: Probably a pre-composed character whose base or combining mark must be rendered from a fallback font will result in two runs generated from a single string index */
/*static CFIndex searchRuns(CFArrayRef runs, CFIndex l, CFIndex h, CFRange queryRange, CTRunRef *foundRun)
{
    while (l < h) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, l);
        CFRange runRange = CTRunGetStringRange(run);
        
        if (cfRangeOverlapsCFRange(runRange, queryRange)) {
            *foundRun = run;
            return l;
        }
        
        l ++;
    }
    
    return kCFNotFound;
}
 */


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Layout methods
/////////////////////////////////////////////////////////////////////////////

- (NSRange)rangeIntersection:(NSRange)first withSecond:(NSRange)second {

    NSRange result = NSMakeRange(NSNotFound, 0);
    
    if (first.location > second.location) {
        NSRange tmp = first;
        first = second;
        second = tmp;
    }
    
    if (second.location < first.location + first.length) {
        result.location = second.location;
        NSUInteger end = MIN(first.location + first.length, second.location + second.length);
        result.length = end - result.location;
    }
    
    return result;    
}
//wq ADD for 坐标变换 增加 ctx:(CGContextRef)ctx 参数
- (void)drawPathFromRects:(NSArray*)array cornerRadius:(CGFloat)cornerRadius ctx:(CGContextRef)ctx{
    
    if (array==nil || [array count] == 0) return;
    
    CGMutablePathRef _path = CGPathCreateMutable();
    
    CGRect firstRect = CGRectFromString([array lastObject]);
    CGRect lastRect = CGRectFromString([array objectAtIndex:0]);  
    if ([array count]>1) {
        lastRect.size.width = _textContentView.bounds.size.width-lastRect.origin.x;
    }
    
    if (cornerRadius>0) {
        CGPathAddPath(_path, NULL, [UIBezierPath bezierPathWithRoundedRect:firstRect cornerRadius:cornerRadius].CGPath);
        CGPathAddPath(_path, NULL, [UIBezierPath bezierPathWithRoundedRect:lastRect cornerRadius:cornerRadius].CGPath);
    } else {
        CGPathAddRect(_path, NULL, firstRect);
        CGPathAddRect(_path, NULL, lastRect);
    }
    
    if ([array count] > 1) {
                
        CGRect fillRect = CGRectZero;
        
        CGFloat originX = ([array count]==2) ? MIN(CGRectGetMinX(firstRect), CGRectGetMinX(lastRect)) : 0.0f;
        CGFloat originY = firstRect.origin.y + firstRect.size.height;
        CGFloat width = ([array count]==2) ? originX+MIN(CGRectGetMaxX(firstRect), CGRectGetMaxX(lastRect)) : _textContentView.bounds.size.width;
        CGFloat height =  MAX(0.0f, lastRect.origin.y-originY);
        
        fillRect = CGRectMake(originX, originY, width, height);
        
        if (cornerRadius>0) {
            CGPathAddPath(_path, NULL, [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius].CGPath);
        } else {
            CGPathAddRect(_path, NULL, fillRect);
        }

    }
    
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, _path);
    CGContextFillPath(ctx);
    CGPathRelease(_path);

}
//wq ADD for 坐标变换 增加 ctx:(CGContextRef)ctx 参数
- (void)drawBoundingRangeAsSelection:(NSRange)selectionRange cornerRadius:(CGFloat)cornerRadius  ctx:(CGContextRef)ctx {
	
    if (selectionRange.length == 0 || selectionRange.location == NSNotFound) {
        return;
    }
    
    NSMutableArray *pathRects = [[NSMutableArray alloc] init];       
    for (int j=0; j<[_attributedString.paragraphs count]; j++) {
       
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
        NSArray *lines = textParagraph.lines;
        CGPoint *origins =textParagraph.origins ;
        NSInteger count = [lines count];
        
        for (int i = 0; i < count; i++) {
            FastTextLine *fastline=[lines objectAtIndex:i];          
            CFRange lineRange =[textParagraph lineGetStringRange:fastline];// CTLineGetStringRange(line);
            NSRange range = NSMakeRange(lineRange.location==kCFNotFound ? NSNotFound : lineRange.location, lineRange.length);
            NSRange intersection = [self rangeIntersection:range withSecond:selectionRange];
            
            if (intersection.location != NSNotFound && intersection.length > 0) {
                CTLineRef line =[self.attributedString buildCTLineRef:fastline withParagraph:textParagraph] ;
                NSInteger lineindex=intersection.location-textParagraph.range.location;
                NSInteger linefinalIndex=intersection.location + intersection.length-textParagraph.range.location;                        
                
                CGFloat xStart = [textParagraph lineGetGetOffsetForStringIndex:line fastTextLine:fastline charIndex:lineindex secondaryOffset:NULL];  
                CGFloat xEnd =  [textParagraph lineGetGetOffsetForStringIndex:line fastTextLine:fastline charIndex:linefinalIndex secondaryOffset:NULL];
                
                CGPoint origin = origins[i];
                CGFloat ascent=fastline.ascent;
                CGFloat descent=fastline.descent;                 
                CGFloat origin_y=[textParagraph lineGetOriginY:origin.y];
                
                CGRect selectionRect = CGRectMake(origin.x + xStart, origin_y - descent, xEnd - xStart, ascent + descent);
                
                if (range.length==1) {
                    selectionRect.size.width = _textContentView.bounds.size.width;
                }
                
                [pathRects addObject:NSStringFromCGRect(selectionRect)];
                CFRelease(line);
                
            }
        }
    }
    //wq ADD for 坐标变换
    [self drawPathFromRects:pathRects cornerRadius:cornerRadius ctx:ctx];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
#if !TILED_LAYER_MODE
    if([keyPath isEqualToString:@"contentOffset"]){
        if (self.contentOffset.y!=oldOffset && !isInsertText) {
            [_textContentView refreshView];
            oldOffset=self.contentOffset.y;
        }
    }
#endif

}

-(CGRect)getVisibleRect{  
    
    return CGRectMake(0,self.contentOffset.y, _textContentView.frame.size.width, self.frame.size.height+18);
    //  return CGRectMake(0,_textContentView.frame.size.height-self.contentOffset.y-self.frame.size.height, _textContentView.frame.size.width, self.frame.size.height+18);
    
}




#if RENDER_WITH_LINEREF
//wq ADD for 坐标变换 增加 ctx:(CGContextRef)ctx 参数
- (void)drawContentInRect:(CGRect)rect ctx:(CGContextRef)ctx {

    double starttime=[[NSDate date]timeIntervalSince1970];
    
    [self.attributedString clearDeleteParagraphs]; //clear attributedString deleted paragraphs // 清理已删除的章节
    
    if ([self.attributedString isEditing]) {
        return;
    }
    
    @synchronized(self.attributedString) {

        //    double starttime=[[NSDate date]timeIntervalSince1970];
        
       //[[FastTextView selectionColor] setFill];
        CGContextSetFillColorWithColor(ctx, [FastTextView selectionColor].CGColor);

        [self drawBoundingRangeAsSelection:self.selectedRange cornerRadius:0.0f ctx:ctx];
        [self drawBoundingRangeAsSelection:self.markedRange cornerRadius:0.0f ctx:ctx];//gfthr add for markedRange IME（输入法）
        
        //CGContextRef ctx = UIGraphicsGetCurrentContext();
        
#if TILED_LAYER_MODE
        CGFloat ystart=rect.origin.y;
        CGFloat yend=rect.origin.y+rect.size.height;
        CGContextClipToRect(ctx, rect);
#else
        CGRect dirtyRect = [self getVisibleRect];
        CGContextClipToRect(ctx, dirtyRect);//CGContextGetClipBoundingBox(ctx);
        CGFloat ystart=dirtyRect.origin.y;
        CGFloat yend=dirtyRect.origin.y+dirtyRect.size.height;
#endif
        _visibleTextAttchList=[[NSMutableArray alloc]init];
                
        for (int j=0; j<[_attributedString.paragraphs count]; j++) {
            
            FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
            if (textParagraph==nil) {
                break;
            }
            @synchronized(textParagraph) {
                
                if (((textParagraph.rect.origin.y )>yend )) {
                    continue;
                }else if (((textParagraph.rect.origin.y +textParagraph.rect.size.height)<ystart )){
                    break;
                }
                
                NSArray *lines = textParagraph.linerefs;
                if (lines==nil) {
                    [_attributedString rebuildLayer:textParagraph context:ctx];
                    lines = textParagraph.linerefs;
                    
                }
                NSInteger count = [lines count];
                
                CGPoint *origins =textParagraph.origins ;
                
                for (int i = 0 ; i < count; i++) {
                    
                    CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex((CFArrayRef)lines, i);
                    
                    CGFloat ascent,descent,leading;
                    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                    
                    if (((textParagraph.rect.origin.y + origins[i].y)>yend )) {
                        continue;
                    }else if (((textParagraph.rect.origin.y + origins[i].y+ascent)<ystart )){
                        break;
                    }
                    
                    CGContextSetTextPosition(ctx, textParagraph.rect.origin.x + origins[i].x, textParagraph.rect.origin.y + origins[i].y);
                    
                    CTLineDraw(line, ctx);
            
                    CFArrayRef runs = CTLineGetGlyphRuns(line);
                    CFIndex runsCount = CFArrayGetCount(runs);
                    
                    CFRange linerange=CTLineGetStringRange(line);
                    for (CFIndex runsIndex = 0; runsIndex < runsCount; runsIndex++) {
                        CTRunRef run = CFArrayGetValueAtIndex(runs, runsIndex);
                        CFDictionaryRef attributes = CTRunGetAttributes(run);
                        id <FastTextAttachmentCell> attachmentCell = [( __bridge NSDictionary*)(attributes) objectForKey: FastTextAttachmentAttributeName];
                        if (attachmentCell != nil && [attachmentCell respondsToSelector: @selector(attachmentSize)] && [attachmentCell respondsToSelector: @selector(attachmentDrawInRect:)]) {                            
                            
                            CFRange runrange= CTRunGetStringRange(run);
                            NSRange nsrunrange=NSMakeRange(textParagraph.range.location+linerange.location+runrange.location, runrange.length);
                            [attachmentCell setRange:nsrunrange];
                            //NSLog(@"attachmentCell setRange: %@",NSStringFromRange(nsrunrange));
                            
                            CGPoint position;
                            CTRunGetPositions(run, CFRangeMake(0, 1), &position);
                            
                            CGSize size = [attachmentCell attachmentSize];
                            CGPoint baselineOffset = [attachmentCell cellBaselineOffset];
                            
                            if (!self.isImageSigleLine) {
                                baselineOffset=CGPointMake(0, baselineOffset.y);
                            }
                            
                            CGRect cellrect = { { textParagraph.rect.origin.x+origins[i].x + position.x+baselineOffset.x, textParagraph.rect.origin.y+origins[i].y + position.y+baselineOffset.y }, size };
                            UIGraphicsPushContext(ctx);//UIGraphicsGetCurrentContext() //WQ ADD for 坐标变换
                            [attachmentCell attachmentDrawInRect: cellrect];
                            UIGraphicsPopContext();
                            
                            TextAttchment *txtAttachment=[[TextAttchment alloc]init];
                            
                            txtAttachment.cellRect=cellrect;
                            txtAttachment.attachmentcell=attachmentCell;
                            [_visibleTextAttchList addObject:txtAttachment];
                        }
                    }
                }                
            }//end @synchronized(textParagraph)
        }
    }
       
    isInsertText=NO;
    /*if (actiontime!=nil) {
        double time3=[[NSDate date]timeIntervalSince1970];
        NSLog(@"drawContentInRect  beginedittime  %f",beginedittime);
        NSLog(@"%@",actiontime);
        actiontime=nil;
        NSLog(@"%@",txtreplacetime);
        txtreplacetime=nil;
        NSLog(@"drawContentInRect  txtchang  %f",txtchangetime);
        NSLog(@"drawContentInRect  carettime  %f",caretedittime);
        NSLog(@"drawContentInRect  selectrange  %f",selectedRangetime);
        NSLog(@"drawContentInRect  setneeddisplaytime  %f",setneeddisplaytime);
        NSLog(@"drawContentInRect  draw begintime %f",starttime);
        NSLog(@"drawContentInRect  draw  %f",time3-starttime);
        NSLog(@"drawContentInRect  totaltime  %f",time3-beginedittime);
    }
     */
}

#else

- (void)drawContentInRect:(CGRect)rect {
    
    double starttime=[[NSDate date]timeIntervalSince1970];
    
    
    [[FastTextView selectionColor] setFill];
    [self drawBoundingRangeAsSelection:self.selectedRange cornerRadius:0.0f];
    [self drawBoundingRangeAsSelection:self.markedRange cornerRadius:0.0f];//gfthr add for markedRange IME //（输入法）
    
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect dirtyRect = [self getVisibleRect];
    
    
    CGContextClipToRect(ctx, dirtyRect);
    
    CGFloat ystart=dirtyRect.origin.y;
    CGFloat yend=dirtyRect.origin.y+dirtyRect.size.height;
    
    _visibleTextAttchList=[[NSMutableArray alloc]init];
	
	for (int j=0; j<[_attributedString.paragraphs count]; j++) {
        
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
        
        if (((textParagraph.rect.origin.y )>yend )) {
            continue;
        }else if (((textParagraph.rect.origin.y + textParagraph.rect.size.height)<ystart )){
            break;
        }
        
        if (textParagraph.layer==NULL) {
            [_attributedString rebuildLayer:textParagraph context:ctx];
        }        
        
        CGContextDrawLayerInRect(ctx, textParagraph.rect, textParagraph.layer);       
        [_visibleTextAttchList addObjectsFromArray:textParagraph.textAttchmentList];
        
    }
    
    isInsertText=NO;
    
    if (actiontime!=nil) {
        double time3=[[NSDate date]timeIntervalSince1970];
        NSLog(@"drawContentInRect  beginedittime  %f",beginedittime);
        NSLog(@"%@",actiontime);
        actiontime=nil;
        NSLog(@"%@",txtreplacetime);
        txtreplacetime=nil;
        NSLog(@"drawContentInRect  txtchang  %f",txtchangetime);
        NSLog(@"drawContentInRect  carettime  %f",caretedittime);
        NSLog(@"drawContentInRect  selectrange  %f",selectedRangetime);
        NSLog(@"drawContentInRect  setneeddisplaytime  %f",setneeddisplaytime);
        NSLog(@"drawContentInRect  draw begintime %f",starttime);
        NSLog(@"drawContentInRect  draw  %f",time3-starttime);
        NSLog(@"drawContentInRect  totaltime  %f",time3-beginedittime);
    }
    
}


#endif
//wq ADD for 坐标变换

- (CGPoint)convertPoint:(CGPoint)point toView:(UIView *)view{
    point = [super convertPoint:point toView:_textContentView];
    point=CGPointMake(point.x, _textContentView.frame.size.height-point.y);
    return point;
}
//wq ADD for 坐标变换 -END

 //fix bug :gfthr when tap on the editor, the caret not on the image line // tap时光标不要在 图片行
- (NSInteger)closestWhiteSpaceIndexToPoint:(CGPoint)point {
    
    point = [self convertPoint:point toView:_textContentView];
    
    __block NSRange returnRange = NSMakeRange(_attributedString.length, 0);
    
    BOOL isfound=FALSE;
    
    for (int j=0; j<[_attributedString.paragraphs count]; j++) {
        if (isfound) {
            break;
        }
        
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
        
        NSArray *lines = textParagraph.lines;
        CGPoint *origins = textParagraph.origins;
                
        for (int i = 0; i < lines.count; i++) {
            CGFloat originsy=[textParagraph lineGetOriginY:origins[i].y];
            
            if (point.y > originsy) {
                FastTextLine *fastline=[lines objectAtIndex:i];
                CTLineRef line =[self.attributedString buildCTLineRef:fastline withParagraph:textParagraph] ;
                              
                BOOL lineHasImage= [self checkLineHasImage:line lineRange:fastline.range];
                
                CFRange cfRange =[textParagraph lineGetStringRange:fastline]; 
                NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length);
                CGPoint convertedPoint = CGPointMake(point.x - origins[i].x, point.y - originsy);
                CFIndex cfIndex = [textParagraph lineGetStringIndexForPosition:line fastTextLine:fastline piont:convertedPoint];
                NSInteger index = cfIndex == kCFNotFound ? NSNotFound : cfIndex;
                
                returnRange =NSMakeRange(index,0);
                
                if(range.location==NSNotFound){
                    isfound=TRUE;
                    break;
                }
                   
                
                if (index>=_attributedString.length) {
                    returnRange = NSMakeRange(_attributedString.length, 0);
                    isfound=TRUE;
                    break;
                }
                
                if (range.length <= 1) {
                    returnRange = NSMakeRange(range.location, 0);
                    if (lineHasImage) {
                        returnRange=[self changRangeImageLine:lines curParagraph:textParagraph curParagraphIndex:j curline:i];
                    }
                    isfound=TRUE;
                    break;
                }
                
                if (index == range.location) {
                    returnRange = NSMakeRange(range.location, 0);
                    if (lineHasImage) {
                        returnRange=[self changRangeImageLine:lines curParagraph:textParagraph curParagraphIndex:j curline:i];
                    }
                    isfound=TRUE;
                    break;
                }
                
                
                if (index >= (range.location+range.length)) {
                    
                    if (range.length > 1 && (([_attributedString.string characterAtIndex:(range.location+range.length)-1] == '\n')||([_attributedString.string characterAtIndex:(range.location+range.length)-1] == '\r'))) {
                        
                        returnRange = NSMakeRange(index-1, 0);
                        if (lineHasImage) {
                            returnRange=[self changRangeImageLine:lines curParagraph:textParagraph curParagraphIndex:j curline:i];
                        }
                        isfound=TRUE;
                        break;
                        
                    } else {
                        
                        returnRange = NSMakeRange(range.location+range.length, 0);
                        if (lineHasImage) {
                            returnRange=[self changRangeImageLine:lines curParagraph:textParagraph curParagraphIndex:j curline:i];
                        }
                        isfound=TRUE;
                        break;
                        
                    }
                    
                }
                /*
                [_attributedString.string enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop){

                    if (NSLocationInRange(index, enclosingRange)) {
                        
                        if (index > (enclosingRange.location+(enclosingRange.length/2))) {
                            
                            returnRange = NSMakeRange(subStringRange.location+subStringRange.length, 0);
                            
                        } else {
                            
                            returnRange = NSMakeRange(subStringRange.location, 0);
                            
                        }
                        
                        *stop = YES;
                    }
                    
                }];*/
                if (lineHasImage) {
                    returnRange=[self changRangeImageLine:lines curParagraph:textParagraph curParagraphIndex:j curline:i];
                }
                CFRelease(line);
                isfound=TRUE;
                break;
            }
        }

    }    
    
    
    return returnRange.location;
}

 //fix bug :gfthr ADD: move caret to next line or last line //把光标放到下一行或者最后一行，用于在图片行用
-(NSRange)changRangeImageLine:(NSArray *)lines curParagraph:(FastTextParagraph *)curParagraph curParagraphIndex:(int)paragraphIndex curline:(int)curline {
    NSRange returnRange = NSMakeRange(_attributedString.length, 0);
    if (curline==(lines.count-1) && paragraphIndex==([_attributedString.paragraphs count]-1)) {//last line //最后一行
        returnRange = NSMakeRange(_attributedString.length, 0);
    }else if(curline==(lines.count-1)){//next paragraph first line // 下一个章节的第一行
        
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:(paragraphIndex+1)];
        NSArray *newlines = textParagraph.lines;
        FastTextLine *nextline=[newlines objectAtIndex:0];
        CFRange nextcfRange =[textParagraph lineGetStringRange:nextline]; 
        NSRange nextrange = NSMakeRange(nextcfRange.location == kCFNotFound ? NSNotFound : nextcfRange.location, nextcfRange.length);
        if(nextrange.location==NSNotFound){
            returnRange = NSMakeRange(_attributedString.length, 0); 
        }
        returnRange=NSMakeRange(nextrange.location, 0);
    }else{//next line first  //获得下一行第一个
        FastTextLine *nextline=[lines objectAtIndex:(curline+1)];
        CFRange nextcfRange = [curParagraph lineGetStringRange:nextline]; 
        NSRange nextrange = NSMakeRange(nextcfRange.location == kCFNotFound ? NSNotFound : nextcfRange.location, nextcfRange.length);
        if(nextrange.location==NSNotFound){
            returnRange = NSMakeRange(_attributedString.length, 0);
        }
        returnRange=NSMakeRange(nextrange.location, 0);
    
    }
    return returnRange;

}
 //fix bug :gfthr ADD:to check line has image // 检查某一行是否有图片
-(BOOL)checkLineHasImage:(CTLineRef )line lineRange:(CFRange)lineRange{
    BOOL lineHasImage=FALSE;
    if (!self.isImageSigleLine) {
        return lineHasImage;
    }
    
    CFRange cfRange = lineRange; 
    if (cfRange.location == kCFNotFound ) {
        return lineHasImage;
    }
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runsCount = CFArrayGetCount(runs);
    
    for (CFIndex runsIndex = 0; runsIndex < runsCount; runsIndex++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, runsIndex);
        CFDictionaryRef attributes = CTRunGetAttributes(run);
        id <FastTextAttachmentCell> attachmentCell = [( __bridge NSDictionary*)(attributes) objectForKey: FastTextAttachmentAttributeName];
        if (attachmentCell != nil && [attachmentCell respondsToSelector: @selector(attachmentSize)] && [attachmentCell respondsToSelector: @selector(attachmentDrawInRect:)]) {
            lineHasImage=TRUE;
            break;
        }
    }    
    return  lineHasImage;       
}


- (NSInteger)closestIndexToPoint:(CGPoint)point {

    point = [self convertPoint:point toView:_textContentView];
    
    BOOL isfound=FALSE;
    CFIndex index = kCFNotFound;
    
    for (int j=0; j<[_attributedString.paragraphs count]; j++) {
        if (isfound) {
            break;
        }
        
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
        NSArray *lines = textParagraph.lines;
        CGPoint *origins = textParagraph.origins;        
        for (int i = 0; i < lines.count; i++) {
            CGFloat originsy=[textParagraph lineGetOriginY:origins[i].y];
            if (point.y > originsy) {
                FastTextLine *fastline=[lines objectAtIndex:i];
                
                CTLineRef line =[self.attributedString buildCTLineRef:fastline withParagraph:textParagraph] ;
                
                BOOL lineHasImage=[self checkLineHasImage:line lineRange:fastline.range];
                
                CGPoint convertedPoint = CGPointMake(point.x - origins[i].x, point.y - originsy);
                index = [textParagraph lineGetStringIndexForPosition:line fastTextLine:fastline piont:convertedPoint];
                //fix bug : gfthr ADD :when long press ,the caret not on the image line // 长按时光标不要放在图片行
                if (lineHasImage) {
                    NSRange returnRange=[self changRangeImageLine:lines curParagraph:textParagraph curParagraphIndex:j curline:i];
                    index=returnRange.location;
                }
                //fix bug end
                CFRelease(line);
                isfound=TRUE;
                break;
            }
        }
    }
    
    if (index == kCFNotFound) {
        index = [_attributedString length];
    }
    
    
    return index;
    
}

- (NSRange)characterRangeAtPoint_:(CGPoint)point {
    
    BOOL isfound=FALSE;
    __block NSRange returnRange = NSMakeRange(NSNotFound, 0);
    
    for (int j=0; j<[_attributedString.paragraphs count]; j++) {
        if (isfound) {
            break;
        }
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
        __block NSArray *lines =textParagraph.lines;
        
        CGPoint *origins = textParagraph.origins;
        
        for (int i = 0; i < lines.count; i++) {
            CGFloat origin_y=[textParagraph lineGetOriginY:origins[i].y];
            if (point.y > origin_y) { //wq ADD for 坐标变换
            //if (point.y > origin_y) {//
                
                FastTextLine *fastline=[lines objectAtIndex:i];                
                CTLineRef line =[self.attributedString buildCTLineRef:fastline withParagraph:textParagraph] ;
                
                CGPoint convertedPoint = CGPointMake(point.x - origins[i].x, point.y - origin_y);
                NSInteger index =[textParagraph lineGetStringIndexForPosition:line fastTextLine:fastline piont:convertedPoint];                 

                CFRange cfRange = [textParagraph lineGetStringRange:fastline];
                NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length);
                returnRange = range;
               
                [_attributedString.string enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop){
                    
                    if (index - subStringRange.location <= subStringRange.length) {
                        returnRange = subStringRange;
                        *stop = YES;
                    }
                    
                }];
                
                CFRelease(line);
                isfound=TRUE;
                break;
            }
        }        
    }
            
    return  returnRange;
    
}

- (NSRange)characterRangeAtIndex:(NSInteger)index {
     __block NSRange returnRange = NSMakeRange(NSNotFound, 0);
    
    for (int j=0; j<[_attributedString.paragraphs count]; j++) {
       
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
        __block NSArray *lines = textParagraph.lines;
        NSInteger count = [lines count];
       
        for (int i=0; i < count; i++) {
            FastTextLine *fastline=[lines objectAtIndex:i];
           
            CFRange cfRange =[textParagraph lineGetStringRange:fastline];
            NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length == kCFNotFound ? 0 : cfRange.length);

            if (index >= range.location && index < range.location+range.length) {
                
                if (range.length > 1 ) {
                   
                    [_attributedString.string enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop){
                        
                        if (index - subStringRange.location <= subStringRange.length) {
                            returnRange = subStringRange;
                            *stop = YES;
                        }
                        
                    }];
                    
                }
                
            }
        }
    }
    
   
    
    return returnRange;
    
}

-(void)applyCaretChangeForIndex:(NSInteger)index{
    return [self applyCaretChangeForIndex:index point:CGPointMake(-1.0f, -1.0f)];

}
/*
-(void)applyCaretChangeForIndex:(NSInteger)index point:(CGPoint)point{
    if (!_editing) {
        [_caretView removeFromSuperview];
    }
    
    if (!_caretView.superview) {
        [_textContentView addSubview:_caretView];
    }
    
    _caretView.frame = [self caretRectForIndex:index point:point];
    [_caretView delayBlink];
    
    CGRect frame = _caretView.frame;

    
    frame.size.height= frame.size.height;
    
    CGRect careRect=CGRectApplyAffineTransform (frame,CGAffineTransformMake(1.0, 0.0, 0.0, -1.0,0.0,self.contentSize.height));

    if ((careRect.origin.y- careRect.size.height)< self.contentOffset.y) {
        careRect.origin.y=careRect.origin.y-2*frame.size.height;
    }
   
    [self scrollRectToVisible:careRect animated:YES];
    
}
 */

//wq ADD for 坐标变换
-(void)applyCaretChangeForIndex:(NSInteger)index point:(CGPoint)point{
    if (!_editing) {
        [_caretView removeFromSuperview];
    }
    
    if (!_caretView.superview) {
        [_textContentView addSubview:_caretView];
    }
    
    CGRect careRect = [self caretRectForIndex:index point:point];
    
    _caretView.frame = careRect;
    //NSLog(@"_caretView.frame %@",NSStringFromCGRect(_caretView.frame));
    [_caretView delayBlink];
    
    //CGRect frame = _caretView.frame;
    /*if (self.font.lineHeight==0) {
     frame.origin.y += 18; //gfthr let the caret can visible // 让光标能看见,经过几次微调，调整为现在的状态
     }else{
     frame.origin.y +=  (self.font.lineHeight); //gfthr  let the caret can visible //让光标能看见,经过几次微调，调整为现在的状态
     }*/
    
    careRect.size.height= 3*MIN(30, MAX(careRect.size.height,25)) ;
    
    //    CGRect careRect=CGRectApplyAffineTransform (frame,CGAffineTransformMake(1.0, 0.0, 0.0, -1.0,0.0,self.contentSize.height));
    
    /* NSLog(@"careRect %@ self.contentOffset.y %f self.contentSize.height %f self.contentSize.height-self.contentOffset.y %f",NSStringFromCGRect(careRect),self.contentOffset.y,self.contentSize.height,self.contentSize.height-self.contentOffset.y);*/
    //    if ((careRect.origin.y- careRect.size.height)< self.contentOffset.y) {
    //        careRect.origin.y=careRect.origin.y-2*frame.size.height;
    //    }
    
    [self scrollRectToVisible:careRect animated:YES];
    
}
//wq ADD for 坐标变换 -END

//获得光标的RECT
- (CGRect)caretRectForIndex:(NSInteger)index {
    return [self caretRectForIndex:index point:CGPointMake(-1.0f, -1.0f)];
}

//fix bug/ gfthr  ADD
//add point paramete, so when operation include tap: doubletap: longpress: to get the caret rectangle, could be more accurate
//获得光标的RECT 增加了一个位置参数point，对于 tap: doubletap: longpress: 等操作来讲，可以获得更精准的光标位置
- (CGRect)caretRectForIndex:(NSInteger)index point:(CGPoint)point {    
    
    // no text / first index    
    if (_attributedString.length == 0 && index == 0) {
        caretLineIndex=0;
        caretLineWidth=0;
        if (self.selectedRange.length!=0) {
            caretLineIndex_selected=(caretLineIndex_selected<caretLineIndex)?caretLineIndex_selected: caretLineIndex;
        }
     /*   CGPoint origin = CGPointMake(0, -self.font.lineHeight);
       // NSLog(@"********* caretLineIndex %d caretLineWidth %f",caretLineIndex,caretLineWidth);
        return CGRectMake(origin.x, origin.y, 3, self.font.ascender + fabs(self.font.descender*2));
     */
        //NSLog(@"_textContentView.bounds %@",NSStringFromCGRect(_textContentView.bounds));
        
        CGPoint origin = CGPointMake(CGRectGetMinX(_textContentView.bounds), CGRectGetMaxY(_textContentView.bounds) - self.font.leading);//gfthr add for caret not in first line
        
        
        CGRect careRect=CGRectMake(origin.x, origin.y, 3, self.font.ascender + fabs(self.font.descender*2));
        
        careRect=CGRectApplyAffineTransform (careRect,CGAffineTransformMake(1.0, 0.0, 0.0, -1.0,0.0,_textContentView.frame.size.height));
        
        return careRect;
        
    } else if (_attributedString.length == 0 || index == 0) {        
        CGPoint origin = CGPointMake(CGRectGetMinX(_textContentView.bounds), CGRectGetMaxY(_textContentView.bounds) - self.font.leading);//gfthr add for caret not in first line
        
        
        CGRect careRect=CGRectMake(origin.x, origin.y, 3, self.font.ascender + fabs(self.font.descender*2));
        
        careRect=CGRectApplyAffineTransform (careRect,CGAffineTransformMake(1.0, 0.0, 0.0, -1.0,0.0,_textContentView.frame.size.height));
        return careRect;
    }
    
    // last index is newline
   /*f if (index == _attributedString.length && [_attributedString.string characterAtIndex:(index - 1)] == '\n' ) {
        
        FastTextParagraph *textParagraph=[_attributedString.paragraphs lastObject];
        
        NSArray *lines = textParagraph.lines;
        
        FastTextLine *fastline=[lines lastObject];        
        CTLineRef line =[self.attributedString buildCTLineRef:fastline withParagraph:textParagraph] ;
        CFRange range =fastline.range; //this place not use[textParagraph lineGetStringRange:line];//
        CGFloat xPos = [textParagraph lineGetGetOffsetForStringIndex:line fastTextLine:fastline charIndex:range.location secondaryOffset:NULL];
        CGFloat ascent=fastline.ascent, descent=fastline.descent;        
        double lineWidth =fastline.lineWidth;
        
        CGPoint origin;
        origin = textParagraph.origins[([lines count]-1)];       
        origin.y -= self.font.leading;        
        CGFloat  origin_y=[textParagraph lineGetOriginY:origin.y];
        
        caretLineIndex=[lines count]-1;
        caretLineWidth=origin.x+ lineWidth;
        if (self.selectedRange.length!=0) {
            caretLineIndex_selected=(caretLineIndex_selected<caretLineIndex)?caretLineIndex_selected: caretLineIndex;
        }
       
        //FIX BUG :gfthr ADD :
        //if caret is at the last charater,and the caret line is the image line,then the caret frame should do some special work ,send to the next line and use the font height
        // 如果光标是最后并且此行为图片行，则光标的大小需要特殊处理，放到下一行并且用字体大小的光标
        BOOL lineHasImage= [self checkLineHasImage:line lineRange:fastline.range];
        
        CFRelease(line);
        
        if (lineHasImage) {
            return CGRectMake(origin.x, floorf(origin_y + self.font.descender*2) , 3, self.font.ascender + fabs(self.font.descender*2));
        }
        //FIX BUG END        
        return CGRectMake(origin.x + xPos, floorf(origin.y - descent), 3, ceilf((descent*2) + ascent));
        
    }*/
    
    index = MAX(index, 0);
    index = MIN(_attributedString.string.length, index);
    
    BOOL isfound=FALSE;
    CGRect returnRect = CGRectZero;
    for (int j=0; j<[_attributedString.paragraphs count]; j++) {
        if (isfound) {
            break;
        }
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
        NSArray *lines = textParagraph.lines;
        NSInteger count = [lines count];
        CGPoint *origins = textParagraph.origins;      
     
        for (int i = 0; i < count; i++) {
            FastTextLine *fastline=[lines objectAtIndex:i];
           
            CFRange cfRange =[textParagraph lineGetStringRange:fastline];
            NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length);
     
            if ((index >=range.location) && (index <= range.location+range.length)) {
                CTLineRef line =[self.attributedString buildCTLineRef:fastline withParagraph:textParagraph] ;
                NSInteger lineindex=index-textParagraph.range.location;
                BOOL lineHasImage= [self checkLineHasImage:line lineRange:fastline.range];
                CGFloat ascent=fastline.ascent, descent=fastline.descent, xPos;
                xPos = [textParagraph lineGetGetOffsetForStringIndex:line fastTextLine:fastline charIndex:lineindex secondaryOffset:NULL];
                
                CFRelease(line);
                
                double lineWidth=fastline.lineWidth;
                CGPoint origin = origins[i];
                
                CGFloat  origin_y=[textParagraph lineGetOriginY:origin.y];
                
                if (_selectedRange.length>0 && index != _selectedRange.location && range.length == 1) {
                    xPos = _textContentView.bounds.size.width - 3.0f; // selection of entire line                    
                } else if ((([_attributedString.string characterAtIndex:index-1] == '\n')||([_attributedString.string characterAtIndex:index-1] == '\r')) && range.length == 1) {
                    xPos = 0.0f; // empty line                    
                }
                
                caretLineIndex=i;
                caretLineWidth=origin.x+ lineWidth;
                if (self.selectedRange.length!=0) {
                    caretLineIndex_selected=(caretLineIndex_selected<caretLineIndex)?caretLineIndex_selected: caretLineIndex;
                }
                // NSLog(@"********* caretLineIndex %d caretLineWidth %f",caretLineIndex,caretLineWidth);
                returnRect = CGRectMake(origin.x + xPos,  floorf(origin_y - descent), 3, ceilf((descent*2) + ascent));
                // gfthr add: make the caret positon more accurate 
                //更精准的控制光标
                point = [self convertPoint:point toView:_textContentView];
                if(point.x>=0 && point.y>=0 && !lineHasImage){
                    if (point.y > origin_y) {                        
                        isfound=TRUE;
                        break;
                    }
                }
                
                if (index == _attributedString.length && (([_attributedString.string characterAtIndex:(index - 1)] == '\n')||([_attributedString.string characterAtIndex:(index - 1)] == '\r')) ) {
//                    if (lineHasImage) {
                    
                        //wq ADD for 坐标变换
                        CGRect careRect=CGRectMake(origin.x, floorf(origin_y - descent*2 - self.font.ascender) , 3, self.font.ascender + fabs(self.font.descender*2));
                    
                        careRect=CGRectApplyAffineTransform (careRect,CGAffineTransformMake(1.0, 0.0, 0.0, -1.0,0.0,_textContentView.frame.size.height));
                        //wq ADD for 坐标变换 -END
                        return careRect;
//                    }
                }
            }       
        }        
    }   
    
    returnRect=CGRectApplyAffineTransform (returnRect,CGAffineTransformMake(1.0, 0.0, 0.0, -1.0,0.0,_textContentView.frame.size.height));
    return returnRect;
}

- (CGRect)firstRectForNSRange:(NSRange)range {
    //TODO get the range rect
    // 获得某个range的rect
    NSInteger index = range.location;
    CGRect returnRect = CGRectNull;
    
    BOOL isfound=FALSE;
    
    for (int j=0; j<[_attributedString.paragraphs count]; j++) {
        if (isfound) {
            break;
        }
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
        NSArray *lines = textParagraph.lines;
        NSInteger count = [lines count];
        CGPoint *origins = textParagraph.origins;
        
        for (int i = 0; i < count; i++) {
            FastTextLine *fastline=[lines objectAtIndex:i]; 
            CFRange lineRange = [textParagraph lineGetStringRange:fastline];
            NSInteger localIndex = index - lineRange.location;
            
            if (localIndex >= 0 && localIndex < lineRange.length) {
                CTLineRef line =[self.attributedString buildCTLineRef:fastline withParagraph:textParagraph] ;
                NSInteger finalIndex = MIN(lineRange.location + lineRange.length, range.location + range.length);
                
                NSInteger lineindex=index-textParagraph.range.location;
                NSInteger linefinalIndex=finalIndex-textParagraph.range.location;
                CGFloat xStart =  [textParagraph lineGetGetOffsetForStringIndex:line fastTextLine:fastline charIndex:lineindex secondaryOffset:NULL];
                    CGFloat xEnd =  [textParagraph lineGetGetOffsetForStringIndex:line fastTextLine:fastline charIndex:linefinalIndex secondaryOffset:NULL];
                CGPoint origin = origins[i];
                CGFloat ascent=fastline.ascent, descent=fastline.descent;
                
                CFRelease(line);
                
                returnRect = [_textContentView convertRect:CGRectMake(textParagraph.rect.origin.x+ origin.x + xStart, textParagraph.rect.origin.y+origin.y - descent, xEnd - xStart, ascent + (descent*2)) toView:self];
                break;
            }
        }        
    }
    
    return returnRect;
}

//wq ADD for 坐标变换
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self recaculate];//gfthr add for recaculate the size // 重算高度
    
    CGRect returnRect = [self caretRectForIndex:self.selectedRange.location];
    
    _caretView.frame =returnRect;
    
    NSLog(@"_caretView.frame %@ ",NSStringFromCGRect(_caretView.frame));
    CGRect caretViewframe = _caretView.frame;
    
    caretViewframe.size.height= 3*MIN(30, MAX(caretViewframe.size.height,26)) ;
    
    [self scrollRectToVisible:caretViewframe animated:YES];
    
    [_textContentView refreshView];
}
//wq ADD for 坐标变换 -END





/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Text Selection
/////////////////////////////////////////////////////////////////////////////

- (void)selectionChanged {
    
    _ignoreSelectionMenu = NO;
    
    if (self.selectedRange.length == 0) {
    
        if (_selectionView!=nil) {
            [_selectionView removeFromSuperview];
            _selectionView=nil;
        }       
        _longPress.minimumPressDuration = 0.5f;
        
    } else {
        
        _longPress.minimumPressDuration = 0.0f;
        
        if ((_caretView!=nil) && _caretView.superview) {
            [_caretView removeFromSuperview];
        }
        
        if (_selectionView==nil) {
            
            FastSelectionView *view = [[FastSelectionView alloc] initWithFrame:_textContentView.bounds];
            [_textContentView addSubview:view];
            _selectionView=view;
            
        }
        CGRect begin = [self caretRectForIndex:_selectedRange.location];
        CGRect end = [self caretRectForIndex:_selectedRange.location+_selectedRange.length];

        [_selectionView setBeginCaret:begin endCaret:end];
               
    }
      
}

- (NSRange)markedRange {
    return _markedRange;
}

- (NSRange)selectedRange {
    return _selectedRange;
}

- (void)setMarkedRange:(NSRange)range {    
    _markedRange = range;
}

- (void)setSelectedRange:(NSRange)range {
    _selectedRange = NSMakeRange(range.location == NSNotFound ? NSNotFound : MAX(0, range.location), range.length);
    [self selectionChanged];
}

- (void)setCorrectionRange:(NSRange)range {

    if (NSEqualRanges(range, _correctionRange) && range.location == NSNotFound && range.length == 0) {
        _correctionRange = range;
        return;
    }
    
    _correctionRange = range;
    if (range.location != NSNotFound && range.length > 0) {
        
        if (_caretView.superview) {
            [_caretView removeFromSuperview];
        }
        
        [self removeCorrectionAttributesForRange:_correctionRange];
        [self showCorrectionMenuForRange:_correctionRange];

        
    } else {
        
        if (!_caretView.superview) {
            [_textContentView addSubview:_caretView];
            [_caretView delayBlink];
        }
        
    }     
}

- (void)setLinkRange:(NSRange)range {
    
    _linkRange = range;
    
    if (_linkRange.length>0) {
        
        if (_caretView.superview!=nil) {
            [_caretView removeFromSuperview];
        }
        
    } else {
        
        if (_caretView.superview==nil) {
            if (!_caretView.superview) {
                [_textContentView addSubview:_caretView];
                _caretView.frame = [self caretRectForIndex:self.selectedRange.location];
                [_caretView delayBlink];
            }
        }
        
    }
   
}

- (void)setLinkRangeFromTextCheckerResults:(NSTextCheckingResult*)results {
            
    if (_linkRange.length>0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[results URL] absoluteString] delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open", nil];
        [actionSheet showInView:self];
    }
    
}

+ (UIColor*)selectionColor {
    static UIColor *color = nil;
    if (color == nil) {
        color = [UIColor colorWithRed:0.800f green:0.867f blue:0.929f alpha:1.0f];    
    }    
    return color;
}

+ (UIColor*)caretColor {
    static UIColor *color = nil;
    if (color == nil) {
        color = [UIColor colorWithRed:0.259f green:0.420f blue:0.949f alpha:1.0f];
    }
    return color;
}

+ (UIColor*)spellingSelectionColor {
    static UIColor *color = nil;
    if (color == nil) {
        color = [UIColor colorWithRed:1.000f green:0.851f blue:0.851f alpha:1.0f];
    }
    return color;
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UITextInput methods
/////////////////////////////////////////////////////////////////////////////


// MARK: UITextInput - Replacing and Returning Text

- (NSString *)textInRange:(UITextRange *)range {
    FastIndexedRange *r = (FastIndexedRange *)range;
    //IOS7 BUG FIX
    if ((r.range.location+r.range.length)<=[_attributedString.string length]) {
        return ([_attributedString.string substringWithRange:r.range]);
    }else{
        return @"";
    }
    
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text {
    
    FastIndexedRange *r = (FastIndexedRange *)range;

    NSRange selectedNSRange = self.selectedRange;
    if ((r.range.location + r.range.length) <= selectedNSRange.location) {
        selectedNSRange.location -= (r.range.length - text.length);
    } else {
        selectedNSRange = [self rangeIntersection:r.range withSecond:_selectedRange];
    }
    [_attributedString replaceCharactersInRange:r.range withString:text];
    self.selectedRange = selectedNSRange;    
    _dirty=YES;
    
}

// MARK: UITextInput - Working with Marked and Selected Text

- (UITextRange *)selectedTextRange {
    return [FastIndexedRange rangeWithNSRange:self.selectedRange];
}

- (void)setSelectedTextRange:(UITextRange *)range {
    FastIndexedRange *r = (FastIndexedRange *)range;
    self.selectedRange = r.range;
    if (self.selectedRange.length == 0) {
        [self applyCaretChangeForIndex:self.selectedRange.location];
    }
}

- (UITextRange *)markedTextRange {
    return [FastIndexedRange rangeWithNSRange:self.markedRange];    
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange {    
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if ([menuController isMenuVisible]) {
        [menuController setMenuVisible:NO animated:NO];
    }
    

    isInsertText=TRUE;
    
    actiontime=[NSString stringWithFormat:@"markedText %@",markedText];
    beginedittime=[[NSDate date]timeIntervalSince1970];
      
    if (markedText!=nil && [markedText length]>0) {  //gfthr add for fix baidu input bug baidu3.5.5
        [self.attributedString beginStorageEditing];        
        
        NSRange selectedNSRange = self.selectedRange;
        NSRange markedTextRange = self.markedRange;        
        
        if (markedTextRange.location != NSNotFound) {
            if (!markedText)
                markedText = @"";
            
            [self.attributedString replaceCharactersInRange:markedTextRange withString:markedText];
            markedTextRange.length =markedText.length;           
            
        } else if (selectedNSRange.length > 0) {
            lastMarkedText=nil;
            [self.attributedString replaceCharactersInRange:selectedNSRange withString:markedText];
            markedTextRange.location = selectedNSRange.location;
            markedTextRange.length = markedText.length;        
            
        } else {
            lastMarkedText=nil;
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:markedText attributes:self.attributeConfig.attributes];
            [self.attributedString insertAttributedString:string atIndex:selectedNSRange.location];
            
            markedTextRange.location = selectedNSRange.location;
            markedTextRange.length = markedText.length;
            
        }
        
        selectedNSRange = NSMakeRange(selectedRange.location + markedTextRange.location, selectedRange.length);
        //NSLog(@"setMarkedText selectedNSRange %@",NSStringFromRange(selectedNSRange));
        
        txtreplacetime=self.attributedString.buildParagraghTime;        
        double begintxttime=[[NSDate date]timeIntervalSince1970];
        
        [self.attributedString endStorageEditing];

        double endtxttime=[[NSDate date]timeIntervalSince1970];
        txtchangetime=endtxttime-begintxttime;
        
        double beginselectedRangetime=[[NSDate date]timeIntervalSince1970];
        self.markedRange = markedTextRange;
        self.selectedRange = selectedNSRange;
        double endselectedRangetime=[[NSDate date]timeIntervalSince1970];
        selectedRangetime=endselectedRangetime-beginselectedRangetime;

        _dirty=YES;
        
        
        double beginCarettime=[[NSDate date]timeIntervalSince1970];                    
        
        if (self.selectedRange.length == 0 && isFirstResponser) {
            [self applyCaretChangeForIndex:self.selectedRange.location];
        }
        double endCarettime=[[NSDate date]timeIntervalSince1970];
        caretedittime=endCarettime-beginCarettime;

        /*
        if (![markedText isEqualToString:lastMarkedText]) { //baidu 4.0 markedText 和 lastMarkedText 老是相等
            [_textContentView refreshView];
            NSLog(@"_textContentView refreshView");
        }else{
            isInsertText=NO;
        }
         */
        [_textContentView refreshView];//fixbug baidu 4.0 markedText 和 lastMarkedText 老是相等
        lastMarkedText=markedText; 
        setneeddisplaytime=[[NSDate date]timeIntervalSince1970];
        
    }else{//gfthr fix bug:delete markedText left one char and avoid baidu bug baidu3.5.5      
        
        NSRange selectedNSRange = self.selectedRange;
        NSRange markedTextRange = self.markedRange;
        if (markedTextRange.location != NSNotFound) {
            if (!markedText)
                markedText = @"";
            [self.attributedString beginStorageEditing];
            [self.attributedString replaceCharactersInRange:markedTextRange withString:markedText];
            markedTextRange.length = markedText.length;
            selectedNSRange = NSMakeRange(selectedRange.location + markedTextRange.location, selectedRange.length);

            self.markedRange = markedTextRange;
            self.selectedRange = selectedNSRange;
            
            [self.attributedString endStorageEditing];
            
            if (self.selectedRange.length == 0 && isFirstResponser) {
                [self applyCaretChangeForIndex:self.selectedRange.location];
            }
            
            if (![markedText isEqualToString:lastMarkedText]) {
                [_textContentView refreshView];
            }else{
                isInsertText=NO;
            }

            lastMarkedText=markedText;          
        }
    }
   
    
}

- (void)unmarkText {
    
    NSRange markedTextRange = self.markedRange;
    
    if (markedTextRange.location == NSNotFound)
        return;
    
    markedTextRange.location = NSNotFound;
    self.markedRange = markedTextRange;   
    
}

// MARK: UITextInput - Computing Text Ranges and Text Positions

- (UITextPosition*)beginningOfDocument {
    return [FastIndexedPosition positionWithIndex:0];
}

- (UITextPosition*)endOfDocument {
    return [FastIndexedPosition positionWithIndex:_attributedString.length];
}

- (UITextRange*)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition {

    FastIndexedPosition *from = (FastIndexedPosition *)fromPosition;
    FastIndexedPosition *to = (FastIndexedPosition *)toPosition;    
    NSRange range = NSMakeRange(MIN(from.index, to.index), ABS(to.index - from.index));
    return [FastIndexedRange rangeWithNSRange:range];    
    
}

- (UITextPosition*)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset {

    FastIndexedPosition *pos = (FastIndexedPosition *)position;    
    NSInteger end = pos.index + offset;
	
    if (end > _attributedString.length || end < 0)
        return nil;
    
    return [FastIndexedPosition positionWithIndex:end];
}

- (UITextPosition*)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset {

    FastIndexedPosition *pos = (FastIndexedPosition *)position;
    NSInteger newPos = pos.index;
    
    switch (direction) {
        case UITextLayoutDirectionRight:
            newPos += offset;
            break;
        case UITextLayoutDirectionLeft:
            newPos -= offset;
            break;
        UITextLayoutDirectionUp: // not supported right now
            break; 
        UITextLayoutDirectionDown: // not supported right now
            break;
        default:
            break;

    }
    	
    if (newPos < 0)
        newPos = 0;
    
    if (newPos > _attributedString.length)
        newPos = _attributedString.length;
    
    return [FastIndexedPosition positionWithIndex:newPos];
}

// MARK: UITextInput - Evaluating Text Positions

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other {
    FastIndexedPosition *pos = (FastIndexedPosition *)position;
    FastIndexedPosition *o = (FastIndexedPosition *)other;
    
    if (pos.index == o.index) {
        return NSOrderedSame;
    } if (pos.index < o.index) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition {
    FastIndexedPosition *f = (FastIndexedPosition *)from;
    FastIndexedPosition *t = (FastIndexedPosition *)toPosition;
    return (t.index - f.index);
}

// MARK: UITextInput - Text Input Delegate and Text Input Tokenizer

- (id <UITextInputTokenizer>)tokenizer {
    return _tokenizer;
}


// MARK: UITextInput - Text Layout, writing direction and position

- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction {

    FastIndexedRange *r = (FastIndexedRange *)range;
    NSInteger pos = r.range.location;
    
    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            pos = r.range.location;
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:            
            pos = r.range.location + r.range.length;
            break;
    }
    
    return [FastIndexedPosition positionWithIndex:pos];        
}

- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction {

    FastIndexedPosition *pos = (FastIndexedPosition *)position;
    NSRange result = NSMakeRange(pos.index, 1);
    
    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            result = NSMakeRange(pos.index - 1, 1);
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:            
            result = NSMakeRange(pos.index, 1);
            break;
    }
    
    return [FastIndexedRange rangeWithNSRange:result];   
}

- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {
    return UITextWritingDirectionLeftToRight;
}

- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range {
    // only ltr supported for now.
}

// MARK: UITextInput - Geometry

- (CGRect)firstRectForRange:(UITextRange *)range {
    
    FastIndexedRange *r = (FastIndexedRange *)range;    
    return [self firstRectForNSRange:r.range];   
}

- (NSArray *)selectionRectsForRange:(UITextRange *)range{
    return [[NSArray alloc] init]; //need TODO 
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    
    FastIndexedPosition *pos = (FastIndexedPosition *)position;
	return [self caretRectForIndex:pos.index];    
}

- (UIView *)textInputView {
    return _textContentView;
}

// MARK: UITextInput - Hit testing

- (UITextPosition*)closestPositionToPoint:(CGPoint)point {
    
    FastIndexedPosition *position = [FastIndexedPosition positionWithIndex:[self closestIndexToPoint:point]];
    return position;
    
}

- (UITextPosition*)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range {
	
    FastIndexedPosition *position = [FastIndexedPosition positionWithIndex:[self closestIndexToPoint:point]];
    return position;
    
}

- (UITextRange*)characterRangeAtPoint:(CGPoint)point {
	
    FastIndexedRange *range = [FastIndexedRange rangeWithNSRange:[self characterRangeAtPoint_:point]];
    return range;
    
}

// MARK: UITextInput - Styling Information

- (NSDictionary*)textStylingAtPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {

    FastIndexedPosition *pos = (FastIndexedPosition*)position;
    NSInteger index = MAX(pos.index, 0);
    index = MIN(index, _attributedString.length-1);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    if (self.attributedString!=nil && self.attributedString.length>0) {
        NSDictionary *attribs = [self.attributedString attributesAtIndex:index effectiveRange:nil];
        
        
        CTFontRef ctFont = (__bridge CTFontRef)[attribs valueForKey:(NSString*)kCTFontAttributeName];
        UIFont *font = [UIFont fontWithName:(NSString*)CFBridgingRelease(CTFontCopyFamilyName(ctFont)) size:CTFontGetSize(ctFont)];
        
        [dictionary setObject:font forKey:UITextInputTextFontKey];
        
    }

    
    return dictionary;

}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIKeyInput methods
/////////////////////////////////////////////////////////////////////////////

- (BOOL)hasText {
    return (_attributedString.length != 0);
}

- (void)insertText:(NSString *)text {
    NSString *newText=text;
    if ([text isEqualToString:@"\n"]) {
        newText=[NSString stringWithFormat:@"\n%@",EMPTY_STRING];
    }
    isInsertText=TRUE;
    
    _textContentView.tiledLayer.isChangeFrame=TRUE;
    
    actiontime=[NSString stringWithFormat:@"insertText %@",newText];
    
    beginedittime=[[NSDate date]timeIntervalSince1970];
    NSAttributedString *newString = [[NSAttributedString alloc] initWithString:newText attributes:self.attributeConfig.attributes];
    caretedittime=[[NSDate date]timeIntervalSince1970];
    NSRange oldrange= NSMakeRange(self.selectedRange.location, newString.length);
    
    [self insertAttributedString:newString isRefresh:YES range:oldrange];
    
    selectedRangetime=[[NSDate date]timeIntervalSince1970];
    
    if (self.selectedRange.length == 0) {
        [self applyCaretChangeForIndex:self.selectedRange.location];
    }
    
    
    
    setneeddisplaytime=[[NSDate date]timeIntervalSince1970];
    
    _dirty=YES;
    displayFlags=FastDisplayRect;
    [_textContentView refreshView];

     _dirty=YES;
}


- (void)insertAttributedString:(NSAttributedString *)newString isRefresh:(BOOL)isRefresh range:(NSRange)range{
    
    NSRange selectedNSRange = self.selectedRange;
    NSRange markedTextRange = self.markedRange;
    
    NSString *text=newString.string;
    
    /*if (_correctionRange.location != NSNotFound && _correctionRange.length > 0){
     ace
     [_mutableAttributedString replaceCharactersInRange:self.correctionRange withAttributedString:newString];
     selectedNSRange.length = 0;
     selectedNSRange.location = (self.correctionRange.location+text.length);
     self.correctionRange = NSMakeRange(NSNotFound, 0);
     
     } else*/
    [self.attributedString beginStorageEditing];
    if (markedTextRange.location != NSNotFound) {
        
        [self.attributedString replaceCharactersInRange:markedTextRange withAttributedString:newString];
        selectedNSRange.location = markedTextRange.location + text.length;
        selectedNSRange.length = 0;
        markedTextRange = NSMakeRange(NSNotFound, 0);
        
    } else if (selectedNSRange.length > 0) {
        
        [self.attributedString replaceCharactersInRange:selectedNSRange withAttributedString:newString];
        selectedNSRange.length = 0;
        selectedNSRange.location = (selectedNSRange.location + text.length);
        
    } else {
        
        [self.attributedString insertAttributedString:newString atIndex:selectedNSRange.location];
        selectedNSRange.location += text.length;
        
    }
    
    if (isRefresh) {
        [self.attributedString refreshParagraghInRange:range];
    }
    
    [self.attributedString endStorageEditing];
    
    txtreplacetime=self.attributedString.buildParagraghTime;
    
    self.markedRange = markedTextRange;
    self.selectedRange = selectedNSRange;
    /*
     if (text.length > 1 || ([text isEqualToString:@" "] || [text isEqualToString:@"\n"])) {
     //[self checkSpellingForRange:[self characterRangeAtIndex:self.selectedRange.location-1]];
     [self checkLinksForRange:NSMakeRange(0, self.attributedString.length)];
     }
     */

   
}



- (void)insertAttributedString:(NSAttributedString *)newString {
    NSRange range=NSMakeRange(NSNotFound, 0);
    [self insertAttributedString:newString isRefresh:NO range:range];
}

- (void)deleteBackward  {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if ([menuController isMenuVisible]) {
        [menuController setMenuVisible:NO animated:NO];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCorrectionMenuWithoutSelection) object:nil];
    
    NSRange selectedNSRange = self.selectedRange;
    NSRange markedTextRange = self.markedRange;
    [self.attributedString beginStorageEditing];

  /*  if (_correctionRange.location != NSNotFound && _correctionRange.length > 0) {
        
        [_mutableAttributedString beginStorageEditing];
        [_mutableAttributedString deleteCharactersInRange:self.correctionRange];
        [_mutableAttributedString endStorageEditing];
        self.correctionRange = NSMakeRange(NSNotFound, 0);
        selectedNSRange.length = 0;
        
    } else*/
        
    if (markedTextRange.location != NSNotFound) {
        
        //[self.attributedString beginStorageEditing];
        [self.attributedString deleteCharactersInRange:selectedNSRange];
        //[self.attributedString endStorageEditing];
        
        selectedNSRange.location = markedTextRange.location;
        selectedNSRange.length = 0;
        markedTextRange = NSMakeRange(NSNotFound, 0);
        
    } else if (selectedNSRange.length > 0) {
        
         if ([_attributedString.string characterAtIndex:selectedNSRange.location] == '\n' && selectedNSRange.length==1) {
             //NSLog(@"selectedNSRange.length > 0");
             
             //fix bug: IOS7 new bug >>> gfthr ADD delete the image bug
             //删除时，删除整张图片
             NSRange checkImageRang=NSMakeRange(MAX(0, selectedNSRange.location-1), 2) ;
             unichar attachmentCharacter = FastTextAttachmentCharacter;
             
             if ([[_attributedString.string substringWithRange:checkImageRang] isEqualToString:[NSString stringWithFormat:@"%@\n",[NSString stringWithCharacters:&attachmentCharacter length:1]]]) {
                 selectedNSRange=checkImageRang;
             }
             //fix bug end
             
         }
        
        
        [self.attributedString deleteCharactersInRange:selectedNSRange];
        
        selectedNSRange.length = 0;
        
    } else if (selectedNSRange.location > 0) {
        
        NSInteger index = MAX(0, selectedNSRange.location-1);
        index = MIN(_attributedString.length-1, index);
        if ([_attributedString.string characterAtIndex:index] == ' ') {
            [self performSelector:@selector(showCorrectionMenuWithoutSelection) withObject:nil afterDelay:0.2f];
        }
        
        NSInteger itmp=selectedNSRange.location - 1;
        if (itmp>=0 && itmp<[[_attributedString string] length]) { //fix ios7 删除字符时的bug
            
            selectedNSRange = [[_attributedString string] rangeOfComposedCharacterSequenceAtIndex:selectedNSRange.location - 1];
            //fix bug: gfthr ADD delete the image bug
            //删除时，删除整张图片
            NSRange checkImageRang=NSMakeRange(MAX(0, selectedNSRange.location-1), 2) ;
            unichar attachmentCharacter = FastTextAttachmentCharacter;
            
            if ([[_attributedString.string substringWithRange:checkImageRang] isEqualToString:[NSString stringWithFormat:@"%@\n",[NSString stringWithCharacters:&attachmentCharacter length:1]]]) {
                selectedNSRange=checkImageRang;
            }
            //fix bug end
            [self.attributedString deleteCharactersInRange:selectedNSRange];
        }
        
        
        selectedNSRange.length = 0;
    }
    
    //fix bug: gfthr ADD check selectrange line is have image and move to next line
    //看看selectrange 这一行 是否有图片，有则 往下一行
    selectedNSRange= [self checkSelectedNSRangeLineImage:selectedNSRange];
    //fix bug end
    
    [self.attributedString endStorageEditing];
    self.markedRange = markedTextRange;
    self.selectedRange = selectedNSRange;
    if (self.selectedRange.length == 0) {
        [self applyCaretChangeForIndex:self.selectedRange.location];
    }
    _dirty=YES;
    displayFlags=FastDisplayRect;
    [_textContentView refreshView];
}


-(NSRange)checkSelectedNSRangeLineImage:(NSRange)selectedNSRange{

     __block NSRange returnRange = selectedNSRange;
    
    for (int j=0; j<[_attributedString.paragraphs count]; j++) {               
        FastTextParagraph *textParagraph=[_attributedString.paragraphs objectAtIndex:j];
        __block NSArray *lines = textParagraph.lines;
       
        for (int i = 0; i < lines.count; i++) {
            FastTextLine *fastline=[lines objectAtIndex:i];

            CFRange cfRange = [textParagraph lineGetStringRange:fastline];
            if (cfRange.location == kCFNotFound ) {
                return returnRange;
            }
           
            long start=cfRange.location;
            long end=cfRange.location+cfRange.length;
            
            if (selectedNSRange.location>=start && selectedNSRange.location<=end) {
                CTLineRef line =[self.attributedString buildCTLineRef:fastline withParagraph:textParagraph] ;
                BOOL lineHasImage= [self checkLineHasImage:line lineRange:fastline.range ];
                if (lineHasImage) {
                    returnRange=[self changRangeImageLine:lines curParagraph:textParagraph curParagraphIndex:j curline:i];
                }
                CFRelease(line);
                return returnRange;
            }
            
        }
        
    }
        
    return  returnRange;
    
}

- (void)deleteWithRange:(NSRange)range  {
    
    if (range.length > 0) {
        
        [self.attributedString beginStorageEditing];
        [self.attributedString deleteCharactersInRange:range];
        [self.attributedString endStorageEditing];        
    }     

    self.markedRange = NSMakeRange(NSNotFound, 0);
    self.selectedRange = NSMakeRange(range.location, 0);
     _dirty=YES;
    displayFlags=FastDisplayRect;
    [_textContentView refreshView];
    
}

//fix bug :gfthr ADD add attachment cell
//增加附件cell
-(void)addAttachmentWithCell:(NSObject <FastTextAttachmentCell> *)cell{

    [self.attributedString beginStorageEditing];
    
    UITextRange *selectedTextRange = [self selectedTextRange];
    if (!selectedTextRange) {
        UITextPosition *endOfDocument = [self endOfDocument];
        selectedTextRange = [self textRangeFromPosition:endOfDocument toPosition:endOfDocument];
    }
    UITextPosition *startPosition = [selectedTextRange start] ;     
    
    // TODO: Clone attributes of the beginning of the selected range?
    unichar attachmentCharacter = FastTextAttachmentCharacter;
    [self replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"\n%@\n%@",[NSString stringWithCharacters:&attachmentCharacter length:1],EMPTY_STRING]];
    
    startPosition=[self positionFromPosition:startPosition inDirection:UITextLayoutDirectionRight offset:1];
    UITextPosition *endPosition = [self positionFromPosition:startPosition offset:1];
    selectedTextRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    NSUInteger st = ((FastIndexedPosition *)(selectedTextRange.start)).index;
    NSUInteger en = ((FastIndexedPosition *)(selectedTextRange.end)).index;
    
    if (en < st) {
        return;
    }
    NSUInteger contentLength = [[self.attributedString string] length];
    if (en > contentLength) {
        en = contentLength; // but let's not crash
    }
    if (st > en)
        st = en;
    NSRange cr = [[self.attributedString string] rangeOfComposedCharacterSequencesForRange:(NSRange){ st, en - st }];
    if (cr.location + cr.length > contentLength) {
        cr.length = ( contentLength - cr.location ); // but let's not crash
    }
    
    [self.attributedString addAttribute: FastTextAttachmentAttributeName value:cell range:cr];
    
    [self.attributedString  scanAttributes:cr];
    
    [self.attributedString endStorageEditing];
    
    
    if (self.selectedRange.length == 0) {
        [self applyCaretChangeForIndex:self.selectedRange.location];
    }
    [_textContentView refreshView];
    
    _dirty=YES;
    
}
//fix bug end


//fix bug :gfthr ADD edit attachment cell
//编辑附件cell
-(void)editAttachmentWithCell:(NSObject <FastTextAttachmentCell> *)cell rang:(NSRange)range{    

    [self.attributedString beginStorageEditing];
    [self.attributedString addAttribute: FastTextAttachmentAttributeName value:cell range:range];
    [self.attributedString scanAttributes:range];
    
    [self.attributedString endStorageEditing];
    if (self.selectedRange.length == 0) {
        [self applyCaretChangeForIndex:self.selectedRange.location];
    }
    [_textContentView refreshView];
     _dirty=YES;    
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Data Detectors (links)
/////////////////////////////////////////////////////////////////////////////

- (NSTextCheckingResult*)linkAtIndex:(NSInteger)index {
    
    NSRange range = [self characterRangeAtIndex:index];
    if (range.location==NSNotFound || range.length == 0) {
        return nil;
    }
    
    __block NSTextCheckingResult *link = nil;
    NSError *error = nil;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    [linkDetector enumerateMatchesInString:[self.attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        if ([result resultType] == NSTextCheckingTypeLink) {
            *stop = YES;
            link = result;
        }
        
    }];

    return link;
    
}

- (void)checkLinksForRange:(NSRange)range {
    
    NSDictionary *linkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)[UIColor blueColor].CGColor, kCTForegroundColorAttributeName, [NSNumber numberWithInt:(int)kCTUnderlineStyleSingle], kCTUnderlineStyleAttributeName, nil];
    
    NSError *error = nil;
	NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
	[linkDetector enumerateMatchesInString:[self.attributedString string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {

        if ([result resultType] == NSTextCheckingTypeLink) {
            [self.attributedString addAttributes:linkAttributes range:[result range]];
        }

    }];    
}


- (NSMutableAttributedString *)stripStyle:(NSAttributedString *) attrstring{
    
    return [NSAttributedString stripStyle:attrstring];   
      
}



- (BOOL)selectedLinkAtIndex:(NSInteger)index {
    
    NSTextCheckingResult *_link = [self linkAtIndex:index];
    if (_link!=nil) {
        [self setLinkRange:[_link range]];
        return YES;
    }
    
    return NO;
}

- (void)openLink:(NSURL*)aURL {
    
    [[UIApplication sharedApplication] openURL:aURL];
    
    //self.
    
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Spell Checking
/////////////////////////////////////////////////////////////////////////////

- (void)insertCorrectionAttributesForRange:(NSRange)range {
    [self.attributedString beginStorageEditing];
    [self.attributedString addAttributes:self.correctionAttributes range:range];    
    [self.attributedString endStorageEditing];
    _dirty=YES;
    
}

- (void)removeCorrectionAttributesForRange:(NSRange)range {
    [self.attributedString beginStorageEditing];
    [self.attributedString removeAttribute:(NSString*)kCTUnderlineStyleAttributeName range:range];
    [self.attributedString endStorageEditing];
     _dirty=YES;    
}

- (void)checkSpellingForRange:(NSRange)range {        
    NSInteger location = range.location-1;
    NSInteger currentOffset = MAX(0, location);
    NSRange currentRange;
    NSString *string = self.attributedString.string;
    NSRange stringRange = NSMakeRange(0, string.length-1);
    NSArray *guesses;
    BOOL done = NO;
    
    NSString *language = [[UITextChecker availableLanguages] objectAtIndex:0];
    if (!language) {
        language = @"en_US";
    }
    
    while (!done) {
        
        currentRange = [_textChecker rangeOfMisspelledWordInString:string range:stringRange startingAt:currentOffset wrap:NO language:language];
        
        if (currentRange.location == NSNotFound || currentRange.location > range.location) {
            done = YES;
            continue;
        }

        guesses = [_textChecker guessesForWordRange:currentRange inString:string language:language];
        
        if (guesses!=nil) {           
            [self.attributedString addAttributes:self.correctionAttributes range:currentRange];
        }
        
        currentOffset = currentOffset + (currentRange.length-1);
        
    }    
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Gestures
/////////////////////////////////////////////////////////////////////////////

- (FastTextWindow*)fastTextWindow {
    
    if (_textWindow==nil) {
        
        FastTextWindow *window = nil;
        
        for (FastTextWindow *aWindow in [[UIApplication sharedApplication] windows]){
            if ([aWindow isKindOfClass:[FastTextWindow class]]) {
                window = aWindow;
                window.frame = [[UIScreen mainScreen] bounds];
                break;
            }
        }
        
        if (window==nil) {
            window = [[FastTextWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        }
        
        window.windowLevel = UIWindowLevelStatusBar;
        window.hidden = NO;
        _textWindow=window;
        
    }
    
    return _textWindow;
    
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {

    if (gesture.state==UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        if (_linkRange.length>0 && gesture.state == UIGestureRecognizerStateBegan) {
            NSTextCheckingResult *link = [self linkAtIndex:_linkRange.location];
            [self setLinkRangeFromTextCheckerResults:link];
            gesture.enabled=NO;
            gesture.enabled=YES;
        }
        
    
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if ([menuController isMenuVisible]) {
            [menuController setMenuVisible:NO animated:NO];
        }
        
        CGPoint point = [gesture locationInView:self];
              
        BOOL _selection = (_selectionView!=nil);

        if (!_selection && _caretView!=nil) {
            [_caretView show];
        }
        
        _textWindow = [self fastTextWindow];
        [_textWindow updateWindowTransform];
        [_textWindow setType:_selection ? FastWindowMagnify : FastWindowLoupe];

        //point.y -= 20.0f;
        NSInteger index =[self closestIndexToPoint:point];
               
        if (_selection) {
            
            if (gesture.state == UIGestureRecognizerStateBegan) {
                _textWindow.selectionType = (index > (_selectedRange.location+(_selectedRange.length/2))) ? FastSelectionTypeRight : FastSelectionTypeLeft;
            }
            
            CGRect rect = CGRectZero;
            if (_textWindow.selectionType==FastSelectionTypeLeft) {
                
                NSInteger begin = MAX(0, index);
                begin = MIN(_selectedRange.location+_selectedRange.length-1, begin);
                
                NSInteger end = _selectedRange.location + _selectedRange.length;
                end = MIN(_attributedString.string.length, end-begin);
                
                self.selectedRange = NSMakeRange(begin, end);
                index = _selectedRange.location;
                
            } else {
                
                NSInteger length = MIN(index-_selectedRange.location, _attributedString.string.length-_selectedRange.location);
                length = MAX(1, length);                    
                self.selectedRange = NSMakeRange(self.selectedRange.location, length);
                index = (_selectedRange.location+_selectedRange.length); 
                
            }
            
            rect = [self caretRectForIndex:index];
            
            if (gesture.state == UIGestureRecognizerStateBegan) {
                
                [_textWindow showFromView:_textContentView rect:[_textContentView convertRect:rect toView:_textWindow]];

            } else {
                
                [_textWindow renderWithContentView:_textContentView fromRect:[_textContentView convertRect:rect toView:_textWindow]];
                
            }
            
        } else {
            
            CGPoint location = [gesture locationInView:_textWindow];
            CGRect rect = CGRectMake(location.x, location.y, _caretView.bounds.size.width, _caretView.bounds.size.height);
            
            self.selectedRange = NSMakeRange(index, 0);
            
            if (gesture.state == UIGestureRecognizerStateBegan) {
                
                [_textWindow showFromView:_textContentView rect:rect];
                
            } else {
                
                [_textWindow renderWithContentView:_textContentView fromRect:rect];
                
            }
            
        }       
       
        //check the attachment type,fire the event
        //确定是否是slide或者图片等附件类型，如果是则触发事件
        
        //wq ADD for 坐标变换
        CGPoint newpoint=CGPointApplyAffineTransform (point,CGAffineTransformMake(1.0, 0.0, 0.0, -1.0,0.0,_textContentView.frame.size.height));
        //wq ADD for 坐标变换 -END
        
        for (TextAttchment *attch in _visibleTextAttchList) {
            if ( CGRectContainsPoint(CGRectInset([_textContentView convertRect:attch.cellRect toView:self], 5.0f, 5.0f) , newpoint)) {
                if ([self.delegate respondsToSelector:@selector(fastTextView:txtAttachmentLongPress:)]) {
                    [self.delegate fastTextView:self txtAttachmentLongPress:attch];
                }
                
                return;
            }
        }

        [self applyCaretChangeForIndex:index point:[gesture locationInView:self]];
    } else {
        
        if (_caretView!=nil) {
            [_caretView delayBlink];
        }
        
        if ((_textWindow!=nil)) {
            [_textWindow hide:YES];
            _textWindow=nil;
        }
        
        if (gesture.state == UIGestureRecognizerStateEnded) {
            if (self.selectedRange.location!=NSNotFound && self.selectedRange.length>0) {
                [self showMenu];
            }else{
                if (_editable && ![self isFirstResponder]) {
                    [self becomeFirstResponder];
                }
                //FIX BUG: when long press ,show menu
                // 某些用户要求选择结束后出现此菜单
                if (![[UIMenuController sharedMenuController] isMenuVisible]) {
                    [self performSelector:@selector(showMenu) withObject:nil afterDelay:0.35f];
                }
            }
        }
    }
    
    displayFlags=FastDisplayRect;
    [_textContentView refreshView];

    
}

- (void)doubleTap:(UITapGestureRecognizer*)gesture {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showMenu) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCorrectionMenu) object:nil];

    NSInteger index = [self closestWhiteSpaceIndexToPoint:[gesture locationInView:self]];
    NSRange range = [self characterRangeAtIndex:index];
        
    if (range.location!=NSNotFound && range.length>0) {
        
        [self.inputDelegate selectionWillChange:self];
        self.selectedRange = range;
        [self.inputDelegate selectionDidChange:self];       

        [self applyCaretChangeForIndex:index point:[gesture locationInView:self]];
       
    }
    if (![[UIMenuController sharedMenuController] isMenuVisible]) {
        [self performSelector:@selector(showMenu) withObject:nil afterDelay:0.1f];
    }

    displayFlags=FastDisplayRect;
    [_textContentView refreshView];   
    
}

- (void)tap:(UITapGestureRecognizer*)gesture {
    BOOL isShowMenu=TRUE;
          
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showMenu) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCorrectionMenu) object:nil];
    
    self.correctionRange = NSMakeRange(NSNotFound, 0);
   
    if (self.selectedRange.length>0) {
        self.selectedRange = NSMakeRange(_selectedRange.location, 0);
    }
        
    NSInteger index = [self closestWhiteSpaceIndexToPoint:[gesture locationInView:self]];
    
    if (_delegateRespondsToDidSelectURL && !_editing) {
        if ([self selectedLinkAtIndex:index]) {
            return;
        }
    }
      
    [self.inputDelegate selectionWillChange:self];
    
    self.markedRange = NSMakeRange(NSNotFound, 0);
     NSRange oldSelectedRange=self.selectedRange;

    self.selectedRange = NSMakeRange(index, 0);
  
    [self applyCaretChangeForIndex:index point:[gesture locationInView:self]];
    
    if ((oldSelectedRange.location==self.selectedRange.location)
        &&(oldSelectedRange.length==self.selectedRange.length) ) {
        if (isSecondTap) {
            isShowMenu=TRUE; 
        }else{
            isShowMenu=FALSE;
        }
        isSecondTap=!isSecondTap;
    }else{
        isShowMenu=FALSE;
        isSecondTap=YES;
    }
    
    [self.inputDelegate selectionDidChange:self];
    //bug fix : [self becomeFirstResponder] should place here to avoid 2 bugs: the caret positon bug and some break prison software conflict
    // [self becomeFirstResponder]; 应该放在后面 以避免两个BUG：光标定位的BUG 及某些越狱版手势软件 拦截  becomeFirstResponder的问题
    
    if (_editable && ![self isFirstResponder]) {
        [self becomeFirstResponder];
        isShowMenu=FALSE;
    }
    
    if (isShowMenu) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if ([menuController isMenuVisible]) {
            
            [menuController setMenuVisible:NO animated:NO];
            
        } else {
            
            if (index==self.selectedRange.location) {
                [self performSelector:@selector(showMenu) withObject:nil afterDelay:0.35f];
            } else {
                if (_editing) {
                    [self performSelector:@selector(showCorrectionMenu) withObject:nil afterDelay:0.35f];
                }
            }
            
        }
        
    }

    displayFlags=FastDisplayRect;
    [_textContentView refreshView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ( (oldOffset>self.contentOffset.y)&& (self.contentOffset.y<=0 )&& _delegateRespondsToSwipUp) { //down
        [self.delegate fastTextViewSwipeDown:self];
    }else if ( (oldOffset< self.contentOffset.y) && _delegateRespondsToSwipUp) { //up
        [self.delegate fastTextViewSwipeUp:self];
    }

}

-(void)swipeUp:(UISwipeGestureRecognizer *)recognizer{
   
    if(recognizer.direction==UISwipeGestureRecognizerDirectionUp && _delegateRespondsToSwipUp){
        return [self.delegate fastTextViewSwipeUp:self];
    }
        
}
-(void)swipeDown:(UISwipeGestureRecognizer *)recognizer{
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown && _delegateRespondsToSwipDown && self.contentOffset.y<=0){
        return [self.delegate fastTextViewSwipeDown:self];
    }
    
}



/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIGestureRecognizerDelegate
/////////////////////////////////////////////////////////////////////////////

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if ([menuController isMenuVisible]) {
            [menuController setMenuVisible:NO animated:NO];
        }
    }
    
    return NO;
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer==_longPress) {
        
        if (_selectedRange.length>0 && _selectionView!=nil) {            
            return CGRectContainsPoint(CGRectInset([_textContentView convertRect:_selectionView.frame toView:self], -20.0f, -20.0f) , [gestureRecognizer locationInView:self]);
        }
        
    }
    
    return YES;
    
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIActionSheetDelegate
/////////////////////////////////////////////////////////////////////////////

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
       
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        
        if (_delegateRespondsToDidChange) {
            [self.delegate fastTextView:self didSelectURL:[NSURL URLWithString:actionSheet.title]];
        } else {
            [self openLink:[NSURL URLWithString:actionSheet.title]];
        }
        
    } else {
        
        [self becomeFirstResponder];
        
    }
    
    [self setLinkRange:NSMakeRange(NSNotFound, 0)];

}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIResponder
/////////////////////////////////////////////////////////////////////////////

- (BOOL)canBecomeFirstResponder {

    if (_editable && _delegateRespondsToShouldBeginEditing) {
        return [self.delegate fastTextViewShouldBeginEditing:self];
    }
    isFirstResponser=YES;
    
    return YES;
}

- (BOOL)becomeFirstResponder {
    isFirstResponser=YES;
    if (_editable) {
        
        _editing = YES;

        if (_delegateRespondsToDidBeginEditing) {
            [self.delegate fastTextViewDidBeginEditing:self];
        }
        [self selectionChanged];       
    
    }
    if (_placeHolderView!=nil ) {
        [_placeHolderView removeFromSuperview];
        _placeHolderView=nil;
    }
     
    return [super becomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
    
    if (_editable && _delegateRespondsToShouldEndEditing) {
        return [self.delegate fastTextViewShouldEndEditing:self];
    }
    
    return YES;
}

- (BOOL)resignFirstResponder {

    if (_editable) {
        
        _editing = NO;	

        if (_delegateRespondsToDidEndEditing) {
            [self.delegate fastTextViewDidEndEditing:self];
        }
        
        [self selectionChanged];
        
    }
    
    [_caretView removeFromSuperview];//resignFirstResponder should remove caret // 需要去掉光标
    
    if (![self.attributedString.string isEqualToString:EMPTY_STRING] ) {//self.attributedString.length>0
        [_placeHolderView removeFromSuperview];
        _placeHolderView=nil;
    }else{
        [self showPlaceHolderView];
    }
    
    isFirstResponser=NO;

	return [super resignFirstResponder];
    
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIMenu Presentation
/////////////////////////////////////////////////////////////////////////////

- (CGRect)menuPresentationRect {
    

    CGRect rect = [_textContentView convertRect:_caretView.frame toView:self];
    
    if (_selectedRange.location != NSNotFound && _selectedRange.length > 0) {
        
        if (_selectionView!=nil) {
            rect = [_textContentView convertRect:_selectionView.frame toView:self];
        } else {
            rect = [self firstRectForNSRange:_selectedRange];
        }
        
    } else if (_editing && _correctionRange.location != NSNotFound && _correctionRange.length > 0) {
        
        rect = [self firstRectForNSRange:_correctionRange];
        
    } 
    
    return rect;
    
}

- (void)showMenu {
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if ([menuController isMenuVisible]) {
        [menuController setMenuVisible:NO animated:NO]; 
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [menuController setMenuItems:nil];
        CGRect rect=[self menuPresentationRect];
        
        //wq 去掉坐标变换
        [menuController setTargetRect:rect inView:_textContentView];
        //[menuController setTargetRect:rect inView:self];
        //wq ADD for 坐标变换 -END
        
        [menuController update];
        [menuController setMenuVisible:YES animated:YES]; 
    });
    
    
    
}

- (void)showCorrectionMenu {
    
    if (_editing) {
        
        NSRange range = [self characterRangeAtIndex:self.selectedRange.location];
        if (range.location!=NSNotFound && range.length>1) {
            
            NSString *language = [[UITextChecker availableLanguages] objectAtIndex:0];
            if (!language)
                language = @"en_US";
            self.correctionRange = [_textChecker rangeOfMisspelledWordInString:_attributedString.string range:range startingAt:0 wrap:YES language:language];
            
        }
    }
    
}

- (void)showCorrectionMenuWithoutSelection {
    
    if (_editing) {
        
        NSRange range = [self characterRangeAtIndex:self.selectedRange.location];
        [self showCorrectionMenuForRange:range];
        
    } else {
        
        [self showMenu];
        
    }
    
}

- (void)showCorrectionMenuForRange:(NSRange)range {
    
    return;
    
    //--- temp delete
    if (range.location==NSNotFound || range.length==0) return;
    
    range.location = MAX(0, range.location);
    range.length = MIN(_attributedString.string.length, range.length);
    
    [self removeCorrectionAttributesForRange:range];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if ([menuController isMenuVisible]) return;
    _ignoreSelectionMenu = YES;
    
    NSString *language = [[UITextChecker availableLanguages] objectAtIndex:0];
    if (!language) {
        language = @"en_US";
    }    
    
    NSArray *guesses = [_textChecker guessesForWordRange:range inString:_attributedString.string language:language];
    
    [menuController setTargetRect:[self menuPresentationRect] inView:self];
    
    if (guesses!=nil && [guesses count]>0) {
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        if (self.menuItemActions==nil) {
            self.menuItemActions = [NSMutableDictionary dictionary];
        }
        
        for (NSString *word in guesses){
            
            NSString *selString = [NSString stringWithFormat:@"spellCheckMenu_%i:", [word hash]];
            SEL sel = sel_registerName([selString UTF8String]);
            
            [self.menuItemActions setObject:word forKey:NSStringFromSelector(sel)]; 
            class_addMethod([self class], sel, [[self class] instanceMethodForSelector:@selector(spellingCorrection:)], "v@:@");
            
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:word action:sel];
            [items addObject:item];
            if ([items count]>=4) {
                break;
            }
        }
        
        [menuController setMenuItems:items];  
        
        
        
    } else {
        
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"No Replacements Found" action:@selector(spellCheckMenuEmpty:)];
        [menuController setMenuItems:[NSArray arrayWithObject:item]];
        
    }
    
    [menuController setMenuVisible:YES animated:YES];
    
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIMenu Actions
/////////////////////////////////////////////////////////////////////////////

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (self.correctionRange.length>0 || _ignoreSelectionMenu) {
        if ([NSStringFromSelector(action) hasPrefix:@"spellCheckMenu"]) {
            return YES;
        }
        return NO;
    }

    if (action==@selector(cut:)) {
        return (_selectedRange.length>0 && _editing);
    } else if (action==@selector(copy:)) {
        return ((_selectedRange.length>0));
    } else if ((action == @selector(select:) || action == @selector(selectAll:))) {
        return (_selectedRange.length==0 && [self hasText]);
    } else if (action == @selector(paste:)) {
        return (_editing && [[UIPasteboard generalPasteboard] containsPasteboardTypes:[NSArray arrayWithObjects:@"public.utf8-plain-text",@"public.text",TangyuanAttributeStringUTI, nil]]);
    } else if (action == @selector(delete:)) {
        return NO;
    }

    return [super canPerformAction:action withSender:sender];
    
}

- (void)spellingCorrection:(UIMenuController*)sender {
    
    NSRange replacementRange = _correctionRange;
    
    if (replacementRange.location==NSNotFound || replacementRange.length==0) {
        replacementRange = [self characterRangeAtIndex:self.selectedRange.location];
    }
    if (replacementRange.location!=NSNotFound && replacementRange.length!=0) {
        NSString *text = [self.menuItemActions objectForKey:NSStringFromSelector(_cmd)];
        [self.inputDelegate textWillChange:self];       
        [self replaceRange:[FastIndexedRange rangeWithNSRange:replacementRange] withText:text];
        [self.inputDelegate textDidChange:self];
        replacementRange.length = text.length;
        [self removeCorrectionAttributesForRange:replacementRange];
    }
    
    self.correctionRange = NSMakeRange(NSNotFound, 0);
    self.menuItemActions = nil;
    [sender setMenuItems:nil];

}

- (void)spellCheckMenuEmpty:(id)sender {

    self.correctionRange = NSMakeRange(NSNotFound, 0);
    
}

- (void)menuDidHide:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    if (_selectionView) {
        [self showMenu];
    }
}

- (void)paste:(id)sender {    
    
    /* this block is the richtext paste , should be consider later
    NSData *pasteData = [[UIPasteboard generalPasteboard] dataForPasteboardType:TangyuanAttributeStringUTI];
    
    if (pasteData) {
        NSAttributedString *pastestr=(NSAttributedString *)[NSKeyedUnarchiver unarchiveObjectWithData:pasteData];        
        if (pastestr!=nil) {
            NSMutableAttributedString *mutepastestr=[pastestr mutableCopy];
            [mutepastestr addAttributes:[TextConfig editorAttributeConfig].attributes range:NSMakeRange(0, [mutepastestr length])];            
            [self insertAttributedString:mutepastestr];
             _dirty=YES;
            return;
        }        
    }
    */
    NSString *pasteText = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.utf8-plain-text"];
    
    if (pasteText!=nil) {
        [self insertText:pasteText];
        return;
    }
    
    NSString *pasteText2 = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.text"];
    
    if (pasteText2!=nil) {
        [self insertText:pasteText2];
        return;
    }
   
    
}

- (void)selectAll:(id)sender {
    
    NSString *string = [_attributedString string];
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.selectedRange = [_attributedString.string rangeOfString:trimmedString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    if (self.selectedRange.length == 0) {
        [self applyCaretChangeForIndex:self.selectedRange.location];
    }
    displayFlags=FastDisplayRect;
    [_textContentView refreshView];
    
}

- (void)select:(id)sender {
    
    //wq ADD for 坐标变换
    CGPoint point=CGPointApplyAffineTransform (_caretView.center,CGAffineTransformMake(1.0, 0.0, 0.0, -1.0,0.0,_textContentView.frame.size.height));
    //wq ADD for 坐标变换 -END

    NSRange range = [self characterRangeAtPoint_:point];
    //NSRange range = [self characterRangeAtPoint_:_caretView.center];
    
    
    self.selectedRange = range;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    if (self.selectedRange.length == 0) {
        [self applyCaretChangeForIndex:self.selectedRange.location];
    }
    displayFlags=FastDisplayRect;
    [_textContentView refreshView];

}

- (void)cut:(id)sender {
    
    NSString *string = [_attributedString.string substringWithRange:_selectedRange];
    unichar attachmentCharacter = FastTextAttachmentCharacter;
    string =[string stringByReplacingOccurrencesOfString:[NSString stringWithCharacters:&attachmentCharacter length:1] withString:@""];
    [[UIPasteboard generalPasteboard] setValue:string forPasteboardType:@"public.utf8-plain-text"];
    
    [self.inputDelegate textWillChange:self];
    [self.attributedString beginStorageEditing];
    [self.attributedString deleteCharactersInRange:_selectedRange];
    [self.attributedString endStorageEditing];
    [self.inputDelegate textDidChange:self];
    
    self.selectedRange = NSMakeRange(_selectedRange.location, 0);
    
    _dirty=YES;
    if (self.selectedRange.length == 0) {
        [self applyCaretChangeForIndex:self.selectedRange.location];
    }
    
   
    
    displayFlags=FastDisplayRect;
    [_textContentView refreshView];
   
    /* this block is the richtext paste , should be consider later
    [[UIPasteboard generalPasteboard] setValue:string forPasteboardType:@"public.text"];
   
    NSAttributedString *cutstr=[self.attributedString attributedSubstringFromRange:_selectedRange];
    
    cutstr =[self stripStyle:cutstr];
    
    NSData *cutData = [NSKeyedArchiver archivedDataWithRootObject:cutstr];
    if(cutData){
        [[UIPasteboard generalPasteboard] setData:cutData forPasteboardType: TangyuanAttributeStringUTI];
        
        [_mutableAttributedString setAttributedString:self.attributedString];
        [_mutableAttributedString deleteCharactersInRange:_selectedRange];
        
        [self.inputDelegate textWillChange:self];
        [self setAttributedString:_mutableAttributedString];
        [self.inputDelegate textDidChange:self];
        
        self.selectedRange = NSMakeRange(_selectedRange.location, 0);
         _dirty=YES;
    }*/
    
}

- (void)copy:(id)sender {
 
    NSString *string = [self.attributedString.string substringWithRange:_selectedRange];
    unichar attachmentCharacter = FastTextAttachmentCharacter;    
    string =[string stringByReplacingOccurrencesOfString:[NSString stringWithCharacters:&attachmentCharacter length:1] withString:@""];
    [[UIPasteboard generalPasteboard] setValue:string forPasteboardType:@"public.utf8-plain-text"];
    
    displayFlags=FastDisplayRect;
    [_textContentView refreshView];
    
    /* this block is the richtext paste , should be consider later
     [[UIPasteboard generalPasteboard] setValue:string forPasteboardType:@"public.text"];
     NSAttributedString *copystr=[self.attributedString attributedSubstringFromRange:_selectedRange];
    
    copystr =[self stripStyle:copystr];
    
    
    NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:copystr];
    if(copyData){
        [[UIPasteboard generalPasteboard] setData:copyData forPasteboardType:TangyuanAttributeStringUTI];
    }  
     */
    
}

- (void)delete:(id)sender {
            
    [self.inputDelegate textWillChange:self];
    [self.attributedString beginStorageEditing];
    [self.attributedString deleteCharactersInRange:_selectedRange];
    [self.attributedString endStorageEditing];
    [self.inputDelegate textDidChange:self];   
    
    self.selectedRange = NSMakeRange(_selectedRange.location, 0);
     _dirty=YES;
    if (self.selectedRange.length == 0) {
        [self applyCaretChangeForIndex:self.selectedRange.location];
    }
    displayFlags=FastDisplayRect;
    [_textContentView refreshView];
}

- (void)replace:(id)sender {
    
    
}

@end

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: FastIndexedPosition
/////////////////////////////////////////////////////////////////////////////

@implementation FastIndexedPosition 
@synthesize index=_index;

+ (FastIndexedPosition *)positionWithIndex:(NSUInteger)index {
    FastIndexedPosition *pos = [[FastIndexedPosition alloc] init];
    pos.index = index;
    return pos;
}

@end


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: FastIndexedRange
/////////////////////////////////////////////////////////////////////////////

@implementation FastIndexedRange 
@synthesize range=_range;

+ (FastIndexedRange *)rangeWithNSRange:(NSRange)theRange {
    if (theRange.location == NSNotFound)
        return nil;
    
    FastIndexedRange *range = [[FastIndexedRange alloc] init];
    range.range = theRange;
    return range;
}

- (UITextPosition *)start {
    return [FastIndexedPosition positionWithIndex:self.range.location];
}

- (UITextPosition *)end {
	return [FastIndexedPosition positionWithIndex:(self.range.location + self.range.length)];
}

-(BOOL)isEmpty {
    return (self.range.length == 0);
}

@end


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: FastContentView
/////////////////////////////////////////////////////////////////////////////

@implementation FastContentView

@synthesize delegate=_delegate;
#if TILED_LAYER_MODE
@synthesize tiledLayer=_tiledLayer;
#endif

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.userInteractionEnabled = NO;
        //wq ADD for 坐标变换
        //self.layer.geometryFlipped = YES; //造成CaTiledLayer抖动的元凶？？
        //wq ADD for 坐标变换 -END
        self.backgroundColor = [UIColor whiteColor];
        //self.layer.needsDisplayOnBoundsChange=NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#if TILED_LAYER_MODE
+ (Class)layerClass {
    return [ContentViewTiledLayer class];
}

- (ContentViewTiledLayer *)tiledLayer {
    return (ContentViewTiledLayer *)self.layer;
}
#endif



-(void)refreshView{
   
    [_delegate setDisplayFlags:FastDisplayRect];
     //wq ADD for 坐标变换
    [self setNeedsDisplayInRect:[_delegate getVisibleRect]];
    
    //[self setNeedsDisplayInRect:self.bounds];
     //wq ADD for 坐标变换 -END
    [self setNeedsLayout];
    
}

-(void)refreshAllView{
    
    [_delegate setDisplayFlags:FastDisplayRect];
    //wq ADD for 坐标变换
    //[self setNeedsDisplayInRect:[_delegate getVisibleRect]];
    
    [self setNeedsDisplayInRect:self.bounds];
    //wq ADD for 坐标变换 -END
    [self setNeedsLayout];
    
}



- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    // Flip the coordinate system
    //wq ADD for 坐标变换

    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //wq ADD for 坐标变换 -END

    CGRect rect = CGContextGetClipBoundingBox(ctx);
    if (_delegate!=nil ) {
        [_delegate drawContentInRect:rect ctx:ctx];
    }
    
}


//- (void)drawRect:(CGRect)rect {
//
//    if (_delegate!=nil ) {
//        [_delegate drawContentInRect:rect];
//    }   
//}

-(void)dealloc{
    //NSLog(@"FastContentView dealloc");
}
@end


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: FastCaretView
/////////////////////////////////////////////////////////////////////////////

@implementation FastCaretView

static const NSTimeInterval kInitialBlinkDelay = 0.6f;
static const NSTimeInterval kBlinkRate = 1.0;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [FastTextView caretColor];
    }    
    return self;
}

- (void)show {
    
    [self.layer removeAllAnimations];
    
}

- (void)didMoveToSuperview {

    if (self.superview) {
        
        [self delayBlink];
        
    } else {
        
        [self.layer removeAllAnimations];
        
    }
}

- (void)delayBlink {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.0f], nil];
    animation.calculationMode = kCAAnimationCubic;
    animation.duration = kBlinkRate;
    animation.beginTime = CACurrentMediaTime() + kInitialBlinkDelay;
    animation.repeatCount = CGFLOAT_MAX;
    [self.layer addAnimation:animation forKey:@"BlinkAnimation"];
    
}
- (void)dealloc {

}

@end


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: FastLoupeView
/////////////////////////////////////////////////////////////////////////////

@implementation FastLoupeView

- (id)init {
    if ((self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 127.0f, 127.0f)])) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIImage imageNamed:@"loupe-lo.png"] drawInRect:rect];
    
    if ((_contentImage!=nil)) {
        CGContextSaveGState(ctx);
        
        CGContextClipToMask(ctx, rect, [UIImage imageNamed:@"loupe-mask.png"].CGImage);
        //wq ADD for 坐标变换
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
        CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        //wq ADD for 坐标变换 -END

        
        [_contentImage drawInRect:rect];        
        CGContextRestoreGState(ctx);
        
    }
    
    [[UIImage imageNamed:@"loupe-hi.png"] drawInRect:rect];
    
}

- (void)setContentImage:(UIImage *)image {
    
    _contentImage=nil;
    _contentImage = image;
    [self setNeedsDisplay];

}

- (void)dealloc {
    _contentImage=nil;
}

@end


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: FastTextWindow
/////////////////////////////////////////////////////////////////////////////

@implementation FastTextWindow

@synthesize showing=_showing;
@synthesize selectionType=_selectionType;
@synthesize type=_type;

static const CGFloat kLoupeScale = 1.2f;
static const CGFloat kMagnifyScale = 1.0f;
static const NSTimeInterval kDefaultAnimationDuration = 0.15f;

- (id)initWithFrame:(CGRect)frame {    
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        _type = FastWindowLoupe;
    }
    return self;
}

- (NSInteger)selectionForRange:(NSRange)range {
    return range.location;
}

- (void)showFromView:(UIView*)view rect:(CGRect)rect {
        
    CGPoint pos = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    
    if (!_showing) {
        
        if (_view==nil) {
            UIView *view;
            if (_type==FastWindowLoupe) {
                view = [[FastLoupeView alloc] init];
            } else {
                view = [[FastMagnifyView alloc] init];
            }
            [self addSubview:view];
            _view=view;
        }
                        
        CGRect frame = _view.frame;
        frame.origin.x = floorf(pos.x - (_view.bounds.size.width/2));
        frame.origin.y = floorf(pos.y - _view.bounds.size.height);
        
        if (_type==FastWindowMagnify) {
            
            frame.origin.y = MAX(frame.origin.y+8.0f, 0.0f);
            frame.origin.x += 2.0f;
            
        } else {
            
            frame.origin.y = MAX(frame.origin.y-10.0f, -40.0f);
            
        }
        
        CGRect originFrame = frame;
        frame.origin.y += frame.size.height/2;
        _view.frame = frame;
        _view.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        _view.alpha = 0.01f;
        
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            
            _view.alpha = 1.0f;
            _view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            _view.frame = originFrame;

        } completion:^(BOOL finished) {
            
            _showing=YES;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.0f*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self renderWithContentView:view fromRect:rect];
            });
            
        }];
        
    }
    
}

- (void)hide:(BOOL)animated {
    
    if ((_view!=nil)) {
        
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                        
            CGRect frame = _view.frame;
            CGPoint center = _view.center;
            frame.origin.x = floorf(center.x-(frame.size.width/2));
            frame.origin.y = center.y;
            _view.frame = frame;
            _view.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            
        } completion:^(BOOL finished) {

            _showing=NO;
            [_view removeFromSuperview];
            _view=nil;
            self.windowLevel = UIWindowLevelNormal;
            self.hidden = YES;

        }];
        
    }
    
}

- (UIImage*)screenshotFromCaretFrame:(CGRect)rect inView:(UIView*)view scale:(BOOL)scale {
    
    //wq ADD for 坐标变换
    CGRect offsetRect = [self convertRect:rect toView:view];
   
    offsetRect=CGRectApplyAffineTransform (offsetRect,CGAffineTransformMake(1.0, 0.0, 0.0, -1.0,0.0,view.frame.size.height));
    
    offsetRect.origin.y += ((UIScrollView*)view.superview).contentOffset.y;
    if ([_view isKindOfClass:[FastLoupeView class]]) {
        offsetRect.origin.y -= _view.bounds.size.height -12.0f; //此处参数不好调整????
    }else{
        offsetRect.origin.y -= _view.bounds.size.height + 38.0f; //此处参数不好调整????
    }
     //wq ADD for 坐标变换 -END
    
    offsetRect.origin.x -= (_view.bounds.size.width/2);
    
    //CGFloat magnifyScale = 1.0f;     
    if (scale) {
        //CGFloat max = 24.0f;
       // magnifyScale = max/offsetRect.size.height;
       // NSLog(@"max %f scale %f", max, magnifyScale);
    } else if (rect.size.height < 22.0f) {
        //magnifyScale = 22.0f/offsetRect.size.height;
        //NSLog(@"cale %f", magnifyScale);
    }

    UIGraphicsBeginImageContextWithOptions(_view.bounds.size, YES, [[UIScreen mainScreen] scale]);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor);
    UIRectFill(CGContextGetClipBoundingBox(ctx));
    CGContextSaveGState(ctx);

    CGContextTranslateCTM(ctx, 0, view.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    
    //CGContextConcatCTM(ctx, CGAffineTransformMakeScale(magnifyScale, magnifyScale));
    
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(-(offsetRect.origin.x),offsetRect.origin.y));
    
   
    UIView *selectionView = nil;
    CGRect selectionFrame = CGRectZero;
    
    for (UIView *subview in view.subviews){
        if ([subview isKindOfClass:[FastSelectionView class]]) {
            selectionView = subview;
        }
    }
    
    if (selectionView!=nil) {
        selectionFrame = selectionView.frame;
        CGRect newFrame = selectionFrame;
        newFrame.origin.y = (selectionFrame.size.height - view.bounds.size.height) - ((selectionFrame.origin.y + selectionFrame.size.height) - view.bounds.size.height);
        selectionView.frame = newFrame;
    }
    
    [view.layer renderInContext:ctx];
    
    if (selectionView!=nil) {
        selectionView.frame = selectionFrame;
    }
    
    
    CGContextRestoreGState(ctx);
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return aImage;
    
}

- (void)renderWithContentView:(UIView*)view fromRect:(CGRect)rect {
    
    CGPoint pos = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    
    if (_showing && _view!=nil) {
        
        CGRect frame = _view.frame;
        frame.origin.x = floorf((pos.x - (_view.bounds.size.width/2)) + (rect.size.width/2));
        frame.origin.y = floorf(pos.y - _view.bounds.size.height);

        if (_type==FastWindowMagnify) {
            frame.origin.y = MAX(0.0f, frame.origin.y);
            rect = [self convertRect:rect toView:view];
        } else {
            frame.origin.y = MAX(frame.origin.y-10.0f, -40.0f);
            rect = [self convertRect:rect toView:view];
        }
      
      
        _view.frame = frame;

        UIImage *image = [self screenshotFromCaretFrame:rect inView:view scale:(_type==FastWindowMagnify)];
        [(FastLoupeView*)_view setContentImage:image];
        
    }
    
}

- (void)updateWindowTransform {
    
    self.frame = [[UIScreen mainScreen] bounds];
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
            self.layer.transform = CATransform3DIdentity;
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.layer.transform = CATransform3DMakeRotation((M_PI/180)*90, 0, 0, 1);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.layer.transform = CATransform3DMakeRotation((M_PI/180)*-90, 0, 0, 1);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.layer.transform = CATransform3DMakeRotation((M_PI/180)*180, 0, 0, 1);
            break;
        default:
            break;
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateWindowTransform];
}

- (void)dealloc {
    _view=nil;
}

@end


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: FastMagnifyView
/////////////////////////////////////////////////////////////////////////////

@implementation FastMagnifyView

- (id)init {
    if ((self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 145.0f, 59.0f)])) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIImage imageNamed:@"magnifier-ranged-lo.png"] drawInRect:rect];
    
    if ((_contentImage!=nil)) {
        CGContextSaveGState(ctx);
        CGContextClipToMask(ctx, rect, [UIImage imageNamed:@"magnifier-ranged-mask.png"].CGImage);
        
        //wq ADD for 坐标变换
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
        CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        //wq ADD for 坐标变换 -END
        
        [_contentImage drawInRect:rect];        
        CGContextRestoreGState(ctx);
        
    }
    
    [[UIImage imageNamed:@"magnifier-ranged-hi.png"] drawInRect:rect];
    
}

- (void)setContentImage:(UIImage *)image {
    
    _contentImage=nil;
    _contentImage = image;
    [self setNeedsDisplay];
    
}

- (void)dealloc {
    _contentImage=nil;
}

@end


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: FastSelectionView
/////////////////////////////////////////////////////////////////////////////

@implementation FastSelectionView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
       
        self.backgroundColor = [UIColor clearColor]; 
        self.userInteractionEnabled = NO;
        //wq ADD for 坐标变换
        //self.layer.geometryFlipped = YES; //坐标转换
        //wq ADD for 坐标变换 -END
        
    }
    return self;
}

- (void)setBeginCaret:(CGRect)begin endCaret:(CGRect)end {
    
    if(!self.superview) return;
    
    self.frame = CGRectMake(begin.origin.x, begin.origin.y + begin.size.height, end.origin.x - begin.origin.x, (end.origin.y-end.size.height)-begin.origin.y);   
    begin = [self.superview convertRect:begin toView:self];
    end = [self.superview convertRect:end toView:self];
    

    if (_leftCaret==nil) {
        UIView *view = [[UIView alloc] initWithFrame:begin];
        view.backgroundColor = [FastTextView caretColor];
        [self addSubview:view]; 
        _leftCaret=view;
    }
    
    if (_leftDot==nil) {
        UIImage *dotImage = [UIImage imageNamed:@"drag-dot.png"];
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotImage.size.width, dotImage.size.height)];
        [view setImage:dotImage];
        [self addSubview:view];
        _leftDot = view;
    }
    
    CGFloat _dotShadowOffset = 5.0f;
    _leftCaret.frame = begin;
    _leftDot.frame = CGRectMake(floorf(_leftCaret.center.x - (_leftDot.bounds.size.width/2)), _leftCaret.frame.origin.y-(_leftDot.bounds.size.height-_dotShadowOffset), _leftDot.bounds.size.width, _leftDot.bounds.size.height);
    
    if (_rightCaret==nil) {
        UIView *view = [[UIView alloc] initWithFrame:end];
        view.backgroundColor = [FastTextView caretColor];
        [self addSubview:view];
        _rightCaret = view;
    }
    
    if (_rightDot==nil) {
        UIImage *dotImage = [UIImage imageNamed:@"drag-dot.png"];
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotImage.size.width, dotImage.size.height)];
        [view setImage:dotImage];
        [self addSubview:view];
        _rightDot = view;
    }
    
    _rightCaret.frame = end;
    _rightDot.frame = CGRectMake(floorf(_rightCaret.center.x - (_rightDot.bounds.size.width/2)), CGRectGetMaxY(_rightCaret.frame), _rightDot.bounds.size.width, _rightDot.bounds.size.height);    

}

- (void)dealloc {    
    _leftCaret=nil;
    _rightCaret=nil;
    _rightDot=nil;
    _leftDot=nil;
}

@end
