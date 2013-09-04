// Copyright 2011 The Omni Group.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import "SlideAttachmentCell.h"

#import <ImageIO/CGImageSource.h>
#import "UIImage-Extensions.h"
#import <CoreText/CoreText.h>
//#import "NXCacheImageManager.h"

//#include <math.h> 
static inline double radians (double degrees) {return degrees * M_PI/180;}

#define SLIDE_FULL_MARGIN 304
#define SLIDE_FULL_MARGIN_READING 320

#define SLIDE_MARGIN 10
#define SLIDE_BEYWEEN_MARGIN 10
#define SLIDE_BACKGROUND @""
#define SLIDE_COMMETGROUND @""

///#import "RESTClient.h"
//#import "const.h"

//RCS_ID("$Id$");

@interface SlideAttachmentCell ()
- (void)_cacheImage;
@end

@implementation SlideAttachmentCell
@synthesize thumbImageWidth;
@synthesize thumbImageHeight;
@synthesize isNeedThumb;
@synthesize txtdesc;
@synthesize range;
//@synthesize fileWrapper=_fileWrapper;
@synthesize fileUrlDic;
@synthesize imgRect;
@synthesize cellRect;
@synthesize fileWrapperObject = _fileWrapperObject;


- (void)dealloc;
{
    NSLog(@"SlideAttachmentCell dealloc %@",fileUrlDic);   
    //_fileWrapper=nil;
    _fileWrapperObject = nil;
    fileUrlDic=nil;
    CGImageRelease(drawImageRef);
    _image = nil;
}

-(id)init{
    self = [super init];
    if(self){
        NSLog(@"SlideAttachmentCell init");
    }
    return self;
}

#pragma mark -
#pragma mark OATextAttachmentCell subclass
- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeBool:self.isNeedThumb forKey:@"isNeedThumb"];
	[coder encodeFloat:self.thumbImageWidth forKey:@"thumbImageWidth"];
	[coder encodeFloat:self.thumbImageHeight forKey:@"thumbImageHeight"];
    [coder encodeObject:self.txtdesc forKey:@"txtdesc"];
 
//    if (self.fileWrapper!=nil) {
//        [coder encodeObject:[self.fileWrapper regularFileContents] forKey:@"fileWrapperData"];
//        [coder encodeObject:self.fileWrapper.filename forKey:@"filename"];    
//    }
//    if (self.fileUrlPath!=nil) {
//        [coder encodeObject:self.fileUrlPath forKey:@"fileUrlPath"];
//    }
   
}


- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {		
		self.isNeedThumb= [coder decodeBoolForKey:@"isNeedThumb"];
		self.thumbImageWidth= [coder decodeFloatForKey:@"thumbImageWidth"];
        self.thumbImageHeight= [coder decodeFloatForKey:@"thumbImageHeight"];
        self.txtdesc= [coder decodeObjectForKey:@"txtdesc"];
        
//        NSData *data = [coder decodeObjectForKey:@"fileWrapperData"];
//        if (data!=nil) {
//            self.fileWrapper= [[NSFileWrapper alloc]initRegularFileWithContents:data];
//            self.fileWrapper.filename=[coder decodeObjectForKey:@"filename"];
//        }
        //self.fileUrlPath= [coder decodeObjectForKey:@"fileUrlPath"];
	}
	return self;
}

//- (id)initWithFileWrapper:(NSFileWrapper *)_newfileWrapper
//{
//    if (!(self = [super init]))
//        return nil;
//    //self.fileWrapper = _newfileWrapper;
//    return self;
//}

- (id)initWithFileWrapperObject:(FileWrapperObject *)_fileWpObj{
    if (!(self = [super init]))
        return nil;
    self.fileWrapperObject = _fileWpObj;
    return self;
}


- (id)initWithFileUrlDic:(NSDictionary *)_fileUrl;{
    if (!(self = [super init]))
        return nil;
    self.fileUrlDic = _fileUrl;
    return self;
}

//-(void) setNewFileWrapper:(NSFileWrapper *)_newfileWrapper{
//
//    //self.fileWrapper = _newfileWrapper;
//    if (_image)
//        _image=nil;
////        CFRelease(_image);
//    
//    
//}

-(UIImage *)attachmentImageOrignal{
    if(self.fileWrapperObject != nil){
        return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[fileUrlDic objectForKey:@"attachPath"] stringByAppendingFormat:@"/%@",self.fileWrapperObject.fileName]]]];
    }else{
        return _image;
    }
}

-(NSString *)attachmentBigImageURl{
    NSLog(@"self.fileWrapper.filename:%@",self.fileWrapperObject.fileName);
    return self.fileWrapperObject.fileName;
}


-(UIImage *)attachmentImage{
    return _image;
}

-(CGRect)cellRect{
    return cellRect;
}

-(CGRect)attachmentRect{
    return imgRect;
}

- (UIView *)attachmentView{
    return nil;
}
- (CGSize) attachmentSize{
    [self _cacheImage];
    
    return _image ? fullcellsize : CGSizeZero;
}
- (void) attachmentDrawInRect: (CGRect)cellFrame{
    //NSLog(@"attachmentDrawInRect self.fileWrapper %@ ,NSStringFromCGSize(_image.size) %@ _image %@ CGImage %@",[self.fileWrapper filename],NSStringFromCGSize(_image.size) ,_image,_image.CGImage);
    
    self.cellRect = cellFrame;
    
    if([self fileWrapperObject] == nil){
        // bookid chapterid  HttpPath
        NSLog(@"阅读：这里没有本地图片，需要去网络获取：%@",self.fileUrlDic);
        
        
    }
    
    [self _cacheImage];
    if (!_image)
        return; 
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //cellFrame = CGContextConvertRectToDeviceSpace(ctx, cellFrame);
       
   // if (self.txtdesc!=nil) {
      //  NSLog(@"_image.size.width %@", NSStringFromCGSize(_image.size) );
    
    CGSize imgsize=CGSizeMake(_image.size.width/2, _image.size.height/2);
        
        CGRect txtrect=CGRectMake(cellFrame.origin.x+(cellFrame.size.width -SLIDE_IMG_WIDTH)/2,
                                  cellFrame.origin.y+SLIDE_MARGIN,
                                  txtsize.width, txtsize.height);
        
        CGRect imgrect=CGRectMake(cellFrame.origin.x+ (cellFrame.size.width-imgsize.width)/2,
                                  txtrect.origin.y+txtrect.size.height+SLIDE_BEYWEEN_MARGIN,
                                  imgsize.width,
                                  imgsize.height);
        if (txtsize.height==0) {
            imgrect=CGRectMake(cellFrame.origin.x+ (cellFrame.size.width-imgsize.width)/2,
                               cellFrame.origin.y+SLIDE_MARGIN,
                               imgsize.width,
                               imgsize.height);

        }
            
        self.imgRect = imgrect;
    
    
    NSString *bgImageName = @"writing_picbox_bg";
    
    
    
        //@"reading_picbox"
        UIGraphicsPushContext(ctx);
        UIImage *imgpicbox=[UIImage imageNamed:bgImageName];        
        imgpicbox=[imgpicbox stretchableImageWithLeftCapWidth:imgpicbox.size.width*0.5 topCapHeight:imgpicbox.size.height*0.5];
        [imgpicbox drawInRect:cellFrame];

    
       // [_image drawInRect:imgrect];
            UIGraphicsPopContext();
            //drawImageRef = _image.CGImage;
            CGContextDrawImage(ctx, imgrect, _image.CGImage);
            //CGImageRelease(drawImageRef);
////        CGContextTranslateCTM(ctx, 0.0,  cellFrame.size.height);
////        CGContextScaleCTM(ctx, 1.0, -1.0);
    
//        [self.txtdesc drawInRect:txtrect withFont:[UIFont systemFontOfSize:12] lineBreakMode:NSLineBreakByWordWrapping];
        if (self.txtdesc!=nil) {
        
            // setting up attributed string of the catagory name to draw with Core Text
            NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:self.txtdesc];
            //        [name setFont:helloWorldFont];
            //        [name setTextColor:[UIColor blackColor]];
            
            
            //        CGContextTranslateCTM(ctx, 0.0,  -cellFrame.size.height);
            
            // getting frames for the text
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge  CFAttributedStringRef)name);
            CFRelease(CFBridgingRetain(name));
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddRect(path, NULL, txtrect);
            CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
            CGPathRelease(path);
            CFRelease(framesetter);
            
            // draw the text
            CTFrameDraw(textFrame, ctx);
            CFRelease(textFrame);

        }
        
   /* }else{
        CGRect imgrect=CGRectMake(cellFrame.origin.x+ (cellFrame.size.width-_image.size.width)/2,
                                  cellFrame.origin.y+SLIDE_MARGIN,
                                  _image.size.width,
                                  _image.size.height);
        //imgrect=CGContextConvertRectToUserSpace(ctx, imgrect);
        //CGContextDrawImage(ctx, imgrect, _image);
        UIGraphicsPushContext(ctx);        
        [_image drawInRect:imgrect];        
        UIGraphicsPopContext();
        
    }*/

}



#pragma mark -
#pragma mark Private

- (void)_cacheImage;
{
    
    if (_image)
        return;
    
 //   NSFileWrapper *fileWrapper = self.attachment.fileWrapper;
//    OBASSERT(fileWrapper);
//    OBASSERT([fileWrapper isRegularFile]);
    
    // The caller should make sure we don't get instantiated for something that isn't an image. Also, a real implementation would have a PDF specific path that would potentially draw via CGPDF* for printing instead of (or in addition to)           caching a bitmap (for screen). We also might want to flush our image cache if we get scrolled off screen... Probably lots of room for optimization.
    if(self.fileWrapperObject != nil){
        //图片本地存在
        //_image=[UIImage imageWithData:[self.fileWrapper regularFileContents]];
        _image = [UIImage imageWithContentsOfFile:self.fileWrapperObject.filePath];
    }else{
        //本地不存在图片，需要去网络抓取,并生成一个占位图片位置
        
        NSLog(@"图片width:%f  height:%f",self.thumbImageWidth,self.thumbImageHeight);
        _image = [UIImage imageNamed:@"nopic_read.png"];
        //_image = [_image stretchableImageWithLeftCapWidth:self.thumbImageWidth topCapHeight:self.thumbImageHeight];
        _image = [_image imageByScalingToSize:CGSizeMake(self.thumbImageWidth, self.thumbImageHeight)];
        _image = [_image addStarToThumb:[UIImage imageNamed:@"no_pic_read2.png"]];
        NSLog(@"_imageSize:%@",NSStringFromCGSize(_image.size));
        NSLog(@"****");
    }
    //[testimage size].height
    //[testimage imageOrientation]
    
//    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)[self.fileWrapper regularFileContents]);
//    if (!dataProvider) {
//        //OBASSERT_NOT_REACHED("Unable to create the data provider");
//        return;
//    }
//    
//    CGImageSourceRef imageSource = CGImageSourceCreateWithDataProvider(dataProvider, NULL/*options*/);
//    CFRelease(dataProvider);
//    if (!imageSource) {
//        //OBASSERT_NOT_REACHED("Unable to create the image source");
//        return;
//    }
//
//    size_t imageCount = CGImageSourceGetCount(imageSource);
//    if (imageCount == 0) {
//        CFRelease(imageSource);
//        //OBASSERT_NOT_REACHED("No images found");
//        return;
//    }
//
//    _image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL/*options*/);
//    CFRelease(imageSource);
    
    //wq 缩略 阅读状态不要压缩
    
    NSLog(@"不压缩情况下图片大小：%@ 压缩情况下：w:%f h:%f",NSStringFromCGSize(_image.size),self.thumbImageWidth*2,self.thumbImageHeight*2);
    if (_image) {// && isNeedThumb && self.thumbImageWidth>0 && self.thumbImageHeight>0
        _image=[_image imageByScalingProportionallyToSize:CGSizeMake(self.thumbImageWidth*2,self.thumbImageHeight*2)];
              //_image=CGImageRetain(thumbimg.CGImage);
        //[thumbimg release];
        drawImageRef=CGImageRetain(_image.CGImage);
    }
    //OBPOSTCONDITION(_image);
  
    
    CGSize imgsize=CGSizeMake(_image.size.width/2, _image.size.height/2);
    
    if (self.txtdesc!=nil) {
        txtsize=[self.txtdesc sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SLIDE_IMG_WIDTH, 100) lineBreakMode:UILineBreakModeWordWrap];
        
        fullcellsize=CGSizeMake(SLIDE_IMG_WIDTH + SLIDE_MARGIN*2, imgsize.height + SLIDE_MARGIN*2 +txtsize.height+SLIDE_BEYWEEN_MARGIN);
    }else{
        txtsize=CGSizeZero;
        
        fullcellsize=CGSizeMake(SLIDE_IMG_WIDTH + SLIDE_MARGIN*2, imgsize.height + SLIDE_MARGIN*2);
    }
    

        leftmargin=CGPointMake( (SLIDE_FULL_MARGIN-SLIDE_IMG_WIDTH - SLIDE_MARGIN*2)/2, 0);
   
    
    
//    NSLog(@"self.fileWrapper %@ ,NSStringFromCGSize(_image.size) %@ _image %@ CGImage %@",[self.fileWrapper filename],NSStringFromCGSize(_image.size) ,_image,_image.CGImage);
//    NSLog(@"CGImageGetHeight %zu , CGImageGetWidth %zu testimage %@ ",CGImageGetHeight(_image),CGImageGetWidth(_image),NSStringFromCGSize(testimage.size));
    
}

- (CGPoint)cellBaselineOffset
{
    
    [self _cacheImage];
    
    return _image ? leftmargin : CGPointZero;
    
    //return CGPointZero;
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"SlideAttachmentCell %@ %@", NSStringFromRange( self.range),self.txtdesc];
}

@end
