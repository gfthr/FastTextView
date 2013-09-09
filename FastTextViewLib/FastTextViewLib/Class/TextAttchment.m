//
//  TextAttchment.m
//  FastTextView_Demo
//
//  Created by 王 强 on 13-6-5.
//
//

#import "TextAttchment.h"

@implementation TextAttchment
@synthesize cellRect,attachmentcell;

-(void)dealloc{
    self.attachmentcell=nil;
    
    NSLog(@"TextAttchment delloc");
}

@end
