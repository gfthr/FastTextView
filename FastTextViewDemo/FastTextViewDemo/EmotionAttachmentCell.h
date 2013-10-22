// Copyright 2011 The Omni Group.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//
// $Id$

#import "FastTextView.h"
#define SLIDE_IMG_WIDTH DEFAULT_thumbImageWidth
#define SLIDE_IMG_HEIGHT DEFAULT_thumbImageHeight

#import "FileWrapperObject.h"

@interface EmotionAttachmentCell : NSObject <FastTextAttachmentCell,NSCoding>
{
    //NSFileWrapper *_fileWrapper;
    //NSDictionary *fileUrlDic;
    FileWrapperObject *_fileWrapperObject;
@private
    //CGImageRef _image;
    UIImage *_image;
    CGPoint leftmargin;
    CGSize fullcellsize;
    CGSize txtsize;
    //CGRect imgRect;
    
    //by yangzongming
    CGRect cellRect;
    CGImageRef drawImageRef;
}
//@property (assign, readwrite) BOOL isNeedThumb;
//@property (assign, readwrite) CGFloat thumbImageWidth;
//@property (assign, readwrite) CGFloat thumbImageHeight;
//@property (nonatomic, strong) NSString *txtdesc;
@property (nonatomic,readwrite) NSRange range ;
//@property (nonatomic,strong)  NSFileWrapper *fileWrapper;
//@property (nonatomic,strong)  NSDictionary *fileUrlDic;

@property (nonatomic,strong)FileWrapperObject *fileWrapperObject;

@property (nonatomic,assign)CGRect imgRect;
@property (nonatomic,assign)CGRect cellRect;

- (id)initWithFileWrapperObject:(FileWrapperObject *)_fileWpObj;

////- (id)initWithFileWrapper:(NSFileWrapper *)_fileWrapper;
//- (id)initWithFileUrlDic:(NSDictionary *)_fileUrl;
//
//-(NSString *)attachmentBigImageURl;//by yangzongming
//-(UIImage *)attachmentImageOrignal;// by yangzongming
//-(UIImage *)attachmentImage; //by yangzongming
//-(CGRect)attachmentRect; //by yangzongming 

-(CGRect)cellRect;
- (UIView *)attachmentView;
- (CGSize) attachmentSize;
- (void) attachmentDrawInRect: (CGRect)r;
//-(void) setNewFileWrapper:(NSFileWrapper *)_newfileWrapper;


@end

