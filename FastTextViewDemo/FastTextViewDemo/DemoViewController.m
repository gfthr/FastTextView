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
#import <CoreText/CoreText.h>
#import "UIImage-Extensions.h"
#import "NSAttributedString+TextUtil.h"
#import "TextConfig.h"

#define NAVBAR_HEIGHT 44.0f
#define TABBAR_HEIGHT 49.0f
#define STATUS_HEIGHT 20.0f

#define ARRSIZE(a)      (sizeof(a) / sizeof(a[0]))

@implementation DemoViewController

@synthesize fastTextView=_fastTextView;
@synthesize textView=_textView;

#pragma mark -
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"UITextView", @"FastTextView", nil]];
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    [segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segment;
//    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]
//                                             initWithTitle:@"图片"
//                                             style:UIBarButtonItemStylePlain
//                                             target:self
//                                             action:@selector(attachImage:)];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]
                                            initWithTitle:@"幻灯"
                                            style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(attachSlide:)];
    
    
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
        
        FastTextView *view = [[FastTextView alloc] initWithFrame:self.view.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.delegate = (id<FastTextViewDelegate>)self;
        view.attributeConfig=[TextConfig editorAttributeConfig];
        view.delegate = (id<FastTextViewDelegate>)self;
        view.placeHolder=@"章节内容";
        [view setFont:[UIFont systemFontOfSize:17]];
        view.pragraghSpaceHeight=15;
        
        [self.view addSubview:view];
        self.fastTextView = view;
        
        NSString *default_txt = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"b.txt"];
        
        #if TARGET_IPHONE_SIMULATOR
            default_txt = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"b.txt"];
        #endif       
        
        NSError *error;
        NSString *base_content=[NSString stringWithContentsOfFile:default_txt encoding:NSUTF8StringEncoding error:&error];
        
        NSMutableAttributedString *parseStr=[[NSMutableAttributedString alloc]initWithString:base_content];
        [parseStr addAttributes:[self defaultAttributes] range:NSMakeRange(0, [parseStr length])];
        self.fastTextView.attributedString=parseStr;
        [view becomeFirstResponder];
        
    }
     
    [segment setSelectedSegmentIndex:1];
    
  
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



- (void)attachSlide:(id)sender;
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
    // [[OUIAppController controller] dismissPopoverAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissModalViewControllerAnimated:YES];
    //[[OUIAppController controller] dismissPopoverAnimated:YES];
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

- (void)dealloc {
    _textView=nil;
    _fastTextView=nil;
}


#pragma mark Removing toolbar

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.fastTextView.frame = CGRectMake(self.fastTextView.frame.origin.x, self.fastTextView.frame.origin.y, self.fastTextView.frame.size.width, [[UIScreen mainScreen] bounds].size.height - NAVBAR_HEIGHT - kbSize.height-STATUS_HEIGHT);
    
//    NSLog(@"[[UIScreen mainScreen] bounds].size.height %f kbSize.height %f",[[UIScreen mainScreen] bounds].size.height,kbSize.height);
    //
    //    [self _logScrollInfo:@"good"];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    self.fastTextView.frame = CGRectMake(self.fastTextView.frame.origin.x, self.fastTextView.frame.origin.y, self.fastTextView.frame.size.width, [[UIScreen mainScreen] bounds].size.height-NAVBAR_HEIGHT-TABBAR_HEIGHT-STATUS_HEIGHT);
    
//    NSLog(@"[[UIScreen mainScreen] bounds].size.height %f NAVBAR_HEIGHT %f TABBAR_HEIGHT %f",[[UIScreen mainScreen] bounds].size.height,NAVBAR_HEIGHT,TABBAR_HEIGHT);
}



@end
