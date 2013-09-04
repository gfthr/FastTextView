//
//  TextAttchment.h
//  FastTextView_Demo
//
//  Created by 王 强 on 13-6-5.
//
//

#import <Foundation/Foundation.h>
#import "FastTextView.h"

@interface TextAttchment : NSObject{

}
@property (assign, readwrite) CGRect cellRect;
@property (nonatomic, strong) id<FastTextAttachmentCell> attachmentcell;

    
@end
