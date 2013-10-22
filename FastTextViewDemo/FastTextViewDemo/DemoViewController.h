//
//  fastTextView_DemoViewController.h
//  fastTextView_Demo
//
//  Created by Devin Doty on 4/18/11.
//  Copyright 2011 enormfast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacialView.h"

@class FastTextView;
@interface DemoViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIScrollViewDelegate,facialViewDelegate> {
    
    FastTextView *_fastTextView;
    UITextView *_textView;
    BOOL isAddSlide;
    UIPageControl *pageControl;
    UIScrollView *scrollView;
    CGFloat origin_y;
}

@property(nonatomic,strong) FastTextView *fastTextView;
@property(nonatomic,strong) UITextView *textView;
@property(retain,nonatomic) IBOutlet UIView *topview;



@end
