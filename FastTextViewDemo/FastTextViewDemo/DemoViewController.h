//
//  fastTextView_DemoViewController.h
//  fastTextView_Demo
//
//  Created by Devin Doty on 4/18/11.
//  Copyright 2011 enormfast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FastTextView;
@interface DemoViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    FastTextView *_fastTextView;
    UITextView *_textView;
    BOOL isAddSlide;
    
}

@property(nonatomic,strong) FastTextView *fastTextView;
@property(nonatomic,strong) UITextView *textView;

@end
