//
//  fastTextView_DemoViewController.m
//  fastTextView_Demo
//
//  Created by Devin Doty on 4/18/11.
//  Copyright 2011 enormfast. All rights reserved.
//

#import "DemoViewController.h"
#import "FastTextView.h"

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import "ImageAttachmentCell.h"
#import "SlideAttachmentCell.h"
#import "EmotionAttachmentCell.h"
#import <CoreText/CoreText.h>
#import "UIImage-Extensions.h"
#import "NSAttributedString+TextUtil.h"
#import "TextConfig.h"
#import "TestViewController.h"

#define NAVBAR_HEIGHT 44.0f
#define TABBAR_HEIGHT 49.0f
#define STATUS_HEIGHT 20.0f

#define TOP_VIEW_HEIGHT 33.0f
#define TOP_VIEW_WIDTH 48.0f

#define ARRSIZE(a)      (sizeof(a) / sizeof(a[0]))

#define ios7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

@implementation DemoViewController

@synthesize fastTextView=_fastTextView;
@synthesize textView=_textView;
@synthesize topview;

#pragma mark -
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(ios7){
        origin_y= NAVBAR_HEIGHT+STATUS_HEIGHT;
    }else{
        origin_y=0;
    }
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"UITextView", @"FastTextView", nil]];
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    [segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segment;
    
    if (_textView==nil) {
        
        UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textView.font = self.fastTextView.font;
        [self.view addSubview:textView];
        self.textView = textView;
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    
    if (_fastTextView==nil) {
        
        FastTextView *view = [[FastTextView alloc] initWithFrame:CGRectMake(0, origin_y, self.view.bounds.size.width, self.view.bounds.size.height-origin_y)];
        
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.delegate = (id<FastTextViewDelegate>)self;
        view.attributeConfig=[TextConfig editorAttributeConfig];
        view.delegate = (id<FastTextViewDelegate>)self;
        view.placeHolder=@"章节内容";
        [view setFont:[UIFont systemFontOfSize:17]];
        view.pragraghSpaceHeight=15;
        view.backgroundColor=[UIColor clearColor];
        
        [self.view addSubview:view];
        self.fastTextView = view;
        
        NSString *default_txt = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"a.txt"];
       // #endif
        
        NSError *error;
        NSString *base_content=[NSString stringWithContentsOfFile:default_txt encoding:NSUTF8StringEncoding error:&error];
        
        NSMutableAttributedString *parseStr=[[NSMutableAttributedString alloc]initWithString:base_content];
        [parseStr addAttributes:[self defaultAttributes] range:NSMakeRange(0, [parseStr length])];
        self.fastTextView.attributedString=parseStr;
        //[view becomeFirstResponder];
        
    }
     
    [segment setSelectedSegmentIndex:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
  
}

-(NSDictionary *)defaultAttributes{
    
    NSString *fontName = @"Helvetica";
    CGFloat fontSize= 17.0f;
    UIColor *color = [UIColor blackColor];
    //UIColor *strokeColor = [UIColor whiteColor];
    //CGFloat strokeWidth = 0.0;
    CGFloat paragraphSpacing = 0.0;
    CGFloat lineSpacing = 0.0;
    //CGFloat minimumLineHeight=24.0f;
    
    
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName,
                                             fontSize, NULL);
    
    CTParagraphStyleSetting settings[] = {
        { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing },
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
        // { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minimumLineHeight },
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, ARRSIZE(settings));
    
    //apply the current text style //2
    /* NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
     (id)color.CGColor, kCTForegroundColorAttributeName,
     (__bridge id)fontRef, kCTFontAttributeName,
     (id)strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
     (id)[NSNumber numberWithFloat: strokeWidth], (NSString *)kCTStrokeWidthAttributeName,
     (__bridge id) paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
     nil];
     */
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)color.CGColor, kCTForegroundColorAttributeName,
                           (__bridge id)fontRef, kCTFontAttributeName,
                           //(id)strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
//                           (id)[NSNumber numberWithFloat: strokeWidth], (NSString *)kCTStrokeWidthAttributeName,
                           //(__bridge id) paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
                           nil];
    
    CFRelease(fontRef);
    return attrs;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Actions

- (void)segmentChanged:(UISegmentedControl*)sender {
    
    if (sender.selectedSegmentIndex == 0) {
    
        self.fastTextView.hidden = YES;
        self.textView.hidden = NO;
        [self.textView becomeFirstResponder];
        
    } else {
                
        self.textView.hidden = YES;
        self.fastTextView.hidden = NO;
        [self.fastTextView becomeFirstResponder];
        self.view.backgroundColor=[UIColor whiteColor];
        
    }
    
}


#pragma mark -
#pragma mark fastTextViewDelegate

- (BOOL)fastTextViewShouldBeginEditing:(FastTextView *)textView {
    return YES;
}

- (BOOL)fastTextViewShouldEndEditing:(FastTextView *)textView {
    return YES;
}

- (void)fastTextViewDidBeginEditing:(FastTextView *)textView {
}

- (void)fastTextViewDidEndEditing:(FastTextView *)textView {
}

- (void)fastTextViewDidChange:(FastTextView *)textView {

}

- (void)fastTextView:(FastTextView*)textView didSelectURL:(NSURL *)URL {
        
}



- (IBAction)attachSlide:(id)sender;
{
    //    [self _logScrollInfo:@"fsfsdfsd"];
    //    NSLog(@"editor frame %@",NSStringFromCGRect(_editor.frame));
    //    return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    isAddSlide=true;
    [self presentModalViewController:picker animated:YES];
    
    //    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
    //    [picker release];
    //
    //       [[OUIAppController controller] presentPopover:popover fromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    //[picker release];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)_addAttachmentFromAsset:(ALAsset *)asset;
{
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSMutableData *data = [NSMutableData dataWithLength:[rep size]];
    
    NSError *error = nil;
    if ([rep getBytes:[data mutableBytes] fromOffset:0 length:[rep size] error:&error] == 0) {
        NSLog(@"error getting asset data %@", [error debugDescription]);
    } else {
//        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
//        wrapper.filename = [[rep url] lastPathComponent];
        UIImage *img=[UIImage imageWithData:data];
        
        NSString *newfilename=[NSAttributedString scanAttachmentsForNewFileName:_fastTextView.attributedString];
        
     
        
        NSArray *_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * _documentDirectory = [[NSString alloc] initWithString:[_paths objectAtIndex:0]];
        
        
        UIImage *thumbimg=[img imageByScalingProportionallyToSize:CGSizeMake(1024,6000)];
        
        NSString *pngPath=[_documentDirectory stringByAppendingPathComponent:newfilename];
        
        //[[AppDelegate documentDirectory] stringByAppendingPathComponent:@"tmp.jpg"];
        
        
        [UIImageJPEGRepresentation(thumbimg,0.7)writeToFile:pngPath atomically:YES];
                
        UITextRange *selectedTextRange = [_fastTextView selectedTextRange];
        if (!selectedTextRange) {
            UITextPosition *endOfDocument = [_fastTextView endOfDocument];
            selectedTextRange = [_fastTextView textRangeFromPosition:endOfDocument toPosition:endOfDocument];
        }
        UITextPosition *startPosition = [selectedTextRange start] ; // hold onto this since the edit will drop
        
        unichar attachmentCharacter = FastTextAttachmentCharacter;
        [_fastTextView replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"\n%@\n",[NSString stringWithCharacters:&attachmentCharacter length:1]]];
            
        startPosition=[_fastTextView positionFromPosition:startPosition inDirection:UITextLayoutDirectionRight offset:1];
        UITextPosition *endPosition = [_fastTextView positionFromPosition:startPosition offset:1];
        selectedTextRange = [_fastTextView textRangeFromPosition:startPosition toPosition:endPosition];
    
             
        NSMutableAttributedString *mutableAttributedString=[_fastTextView.attributedString mutableCopy];
    
        NSUInteger st = ((FastIndexedPosition *)(selectedTextRange.start)).index;
        NSUInteger en = ((FastIndexedPosition *)(selectedTextRange.end)).index;
        
        if (en < st) {
            return;
        }
        NSUInteger contentLength = [[_fastTextView.attributedString string] length];
        if (en > contentLength) {
            en = contentLength; // but let's not crash
        }
        if (st > en)
            st = en;
        NSRange cr = [[_fastTextView.attributedString string] rangeOfComposedCharacterSequencesForRange:(NSRange){ st, en - st }];
        if (cr.location + cr.length > contentLength) {
            cr.length = ( contentLength - cr.location ); // but let's not crash
        }
               
        if(isAddSlide){
            
            FileWrapperObject *fileWp = [[FileWrapperObject alloc] init];
            [fileWp setFileName:newfilename];
            [fileWp setFilePath:pngPath];
            
            SlideAttachmentCell *cell = [[SlideAttachmentCell alloc] initWithFileWrapperObject:fileWp] ;
            //ImageAttachmentCell *cell = [[ImageAttachmentCell alloc] init];
            cell.isNeedThumb=TRUE;
            cell.thumbImageWidth=200.0f;
            cell.thumbImageHeight=200.0f;
            cell.txtdesc=@"幻灯片测试";
            
            [mutableAttributedString addAttribute: FastTextAttachmentAttributeName value:cell  range:cr];
            
            //[mutableAttributedString addAttribute:fastTextAttachmentAttributeName value:cell  range:selectedTextRange];

        
        }else{
//            ImageAttachmentCell *cell = [[ImageAttachmentCell alloc] initWithFileWrapper:wrapper] ;
//            //ImageAttachmentCell *cell = [[ImageAttachmentCell alloc] init];
//            cell.isNeedThumb=TRUE;
//            cell.thumbImageWidth=200.0f;
//            cell.thumbImageHeight=200.0f;
//            
//            [mutableAttributedString addAttribute: fastTextAttachmentAttributeName value:cell  range:cr];
        }
        
        
        
        
        if (mutableAttributedString) {
            _fastTextView.attributedString = mutableAttributedString;
        }
       
        //[_editor setValue:attachment forAttribute:OAAttachmentAttributeName inRange:selectedTextRange];

        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init] ;
    [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
             resultBlock:^(ALAsset *asset){
                 // This get called asynchronously (possibly after a permissions question to the user).
                 [self _addAttachmentFromAsset:asset];
             }
            failureBlock:^(NSError *error){
                NSLog(@"error finding asset %@", [error debugDescription]);
            }];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)_addEmotion:(NSString *)emotionImgName;
{
    
    UITextRange *selectedTextRange = [_fastTextView selectedTextRange];
    if (!selectedTextRange) {
        UITextPosition *endOfDocument = [_fastTextView endOfDocument];
        selectedTextRange = [_fastTextView textRangeFromPosition:endOfDocument toPosition:endOfDocument];
    }
    UITextPosition *startPosition = [selectedTextRange start] ; // hold onto this since the edit will drop
    
    unichar attachmentCharacter = FastTextAttachmentCharacter;
    [_fastTextView replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"%@",[NSString stringWithCharacters:&attachmentCharacter length:1]]];
    
//    startPosition=[_fastTextView positionFromPosition:startPosition inDirection:UITextLayoutDirectionRight offset:1];
    UITextPosition *endPosition = [_fastTextView positionFromPosition:startPosition offset:1];
    selectedTextRange = [_fastTextView textRangeFromPosition:startPosition toPosition:endPosition];
    
    
    NSMutableAttributedString *mutableAttributedString=[_fastTextView.attributedString mutableCopy];
    
    NSUInteger st = ((FastIndexedPosition *)(selectedTextRange.start)).index;
    NSUInteger en = ((FastIndexedPosition *)(selectedTextRange.end)).index;
    
    if (en < st) {
        return;
    }
    NSUInteger contentLength = [[_fastTextView.attributedString string] length];
    if (en > contentLength) {
        en = contentLength; // but let's not crash
    }
    if (st > en)
        st = en;
    NSRange cr = [[_fastTextView.attributedString string] rangeOfComposedCharacterSequencesForRange:(NSRange){ st, en - st }];
    if (cr.location + cr.length > contentLength) {
        cr.length = ( contentLength - cr.location ); // but let's not crash
    }
    
    FileWrapperObject *fileWp = [[FileWrapperObject alloc] init];
    [fileWp setFileName:emotionImgName];
    [fileWp setFilePath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:emotionImgName]];
    EmotionAttachmentCell *cell = [[EmotionAttachmentCell alloc] initWithFileWrapperObject:fileWp] ;
    [mutableAttributedString addAttribute: FastTextAttachmentAttributeName value:cell  range:cr];
    
    if (mutableAttributedString) {
        _fastTextView.attributedString = mutableAttributedString;
    }
}



#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _textView=nil;
    _fastTextView=nil;
}

-(void)viewDidAppear:(BOOL)animated{

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 35)];
    [backButton setTitle:@"test" forState:UIControlStateNormal];
     
     //setImage:[UIImage imageNamed:@"navbar_bt_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(testButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = cancel;
    //[self.navigationItem addLeftBarButtonItem:cancel];
    
}

-(void)testButtonClick:(id)sender{
    
    NSBundle *libBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"Test" withExtension:@"bundle"]];

    TestViewController *vc=[[TestViewController alloc]initWithNibName:@"TestViewController" bundle:libBundle];
    [self presentModalViewController:vc animated:YES];
}

- (void)dealloc {
    _textView=nil;
    _fastTextView=nil;
}


#pragma mark Removing toolbar

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyBoardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.fastTextView.frame = CGRectMake(self.fastTextView.frame.origin.x, origin_y, self.fastTextView.frame.size.width,self.view.bounds.size.height -origin_y - keyBoardSize.height-TOP_VIEW_HEIGHT );
    
    self.topview.frame = CGRectMake(0, self.fastTextView.frame.origin.y+ self.fastTextView.frame.size.height, self.fastTextView.frame.size.width, TOP_VIEW_HEIGHT);
    
    [self.view addSubview:self.topview];
    [self.view bringSubviewToFront:self.topview];
    

}

- (void)keyboardWillHide:(NSNotification *)notification{
    self.fastTextView.frame = CGRectMake(self.fastTextView.frame.origin.x, origin_y, self.fastTextView.frame.size.width, self.view.bounds.size.height-origin_y);
    
    [self.topview removeFromSuperview];

}

-(IBAction)dismissKeyBoard:(id)sender {
    [_fastTextView resignFirstResponder];
}

-(IBAction)bold:(id)sender {
    if (_fastTextView.selectedRange.length>0) {
        CTFontRef font = CTFontCreateWithName((CFStringRef)[UIFont boldSystemFontOfSize:17].fontName, 17, NULL);
        [_fastTextView.attributedString beginStorageEditing];
        [_fastTextView.attributedString addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:_fastTextView.selectedRange];
        [_fastTextView.attributedString refreshParagraghInRange:_fastTextView.selectedRange];
        [_fastTextView.attributedString endStorageEditing];
        [_fastTextView refreshAllView];
    }
}

-(IBAction)italic:(id)sender {
    if (_fastTextView.selectedRange.length>0) {
        CTFontRef font = CTFontCreateWithName((CFStringRef)[UIFont italicSystemFontOfSize:17].fontName, 17, NULL);
        
        [_fastTextView.attributedString beginStorageEditing];
        [_fastTextView.attributedString addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:_fastTextView.selectedRange];
        [_fastTextView.attributedString refreshParagraghInRange:_fastTextView.selectedRange];
        [_fastTextView.attributedString endStorageEditing];
        [_fastTextView refreshAllView];
    }
}

-(IBAction)underline:(id)sender {
    if (_fastTextView.selectedRange.length>0) {
        CTFontRef font = CTFontCreateWithName((CFStringRef)[UIFont systemFontOfSize:17].fontName, 17, NULL);
        [_fastTextView.attributedString beginStorageEditing];
        [_fastTextView.attributedString addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:_fastTextView.selectedRange];
        
        //下划线
        [_fastTextView.attributedString addAttribute:(id)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleThick] range:_fastTextView.selectedRange];
        //下划线颜色
        [_fastTextView.attributedString addAttribute:(id)kCTUnderlineColorAttributeName value:(id)[UIColor redColor].CGColor range:_fastTextView.selectedRange];
        
        [_fastTextView.attributedString refreshParagraghInRange:_fastTextView.selectedRange];
        [_fastTextView.attributedString endStorageEditing];
        [_fastTextView refreshAllView];
    }
}

-(IBAction)showFace:(UIButton*)sender
{
	sender.tag=!sender.tag;
	if (sender.tag) {
		[_fastTextView resignFirstResponder];
        UIView *inputView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        [inputView setBackgroundColor:[UIColor grayColor]];
        
		scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
        [scrollView setBackgroundColor:[UIColor grayColor]];
		for (int i=0; i<3; i++) {
			FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(320*i, 0, 320, 180)];
			[fview loadFacialView:i size:CGSizeMake(45, 45)];
			fview.delegate=self;
			[scrollView addSubview:fview];
			
		}
		scrollView.contentSize=CGSizeMake(320*3, 180);
        scrollView.showsVerticalScrollIndicator  = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.scrollEnabled = YES;
        scrollView.pagingEnabled=YES;
        scrollView.delegate = self;
        
        //定义PageControll
        pageControl = [[UIPageControl alloc] init];
        [pageControl setBackgroundColor:[UIColor grayColor]];
        pageControl.frame = CGRectMake(130, 180, 60, 20);//指定位置大小
        pageControl.numberOfPages = 3;//指定页面个数
        pageControl.currentPage = 0;//指定pagecontroll的值，默认选中的小白点（第一个）
        [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        //添加委托方法，当点击小白点就执行此方法
        [inputView addSubview:scrollView];
        [inputView addSubview:pageControl];
        
        _fastTextView.inputView=inputView;
		[_fastTextView becomeFirstResponder];
        //		[scrollView release];
        //        [pageControl release];
        //[buttonFace setBackgroundImage:[UIImage imageNamed:@"btn_comment_keyboard"] forState:UIControlStateNormal];
        // NSLog(@"self.frame.size.height %f",self.frame.size.height);
		
	}else {
		_fastTextView.inputView=nil;
        
		[_fastTextView reloadInputViews];
		[_fastTextView becomeFirstResponder];
        //[buttonFace setBackgroundImage:[UIImage imageNamed:@"btn_comment_face"] forState:UIControlStateNormal];
	}
    
}

//scrollview的委托方法，当滚动时执行
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = scrollView.contentOffset.x / 320;//通过滚动的偏移量来判断目前页面所对应的小白点
    pageControl.currentPage = page;//pagecontroll响应值的变化
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

//pagecontroll的委托方法
- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;//获取当前pagecontroll的值
    [scrollView setContentOffset:CGPointMake(320 * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
}



-(void)selectedFacialView:(NSString*)str
{
    
    [self _addEmotion:str];
    //NSLog(@"selectedFacialView %@",str);
    /*
    NSString *i_transCharacter = [m_pEmojiDic objectForKey:[NSString stringWithFormat:@"%@",str]];
	//判断输入框是否有内容，追加转义字符
	if (textView.text == nil) {
		self.textView.text = i_transCharacter;
	}
	else {
		self.textView.text = [textView.text stringByAppendingString:i_transCharacter];
	}
    */
	
}



@end
