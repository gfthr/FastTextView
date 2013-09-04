//
//  ContentViewTiledLayer.m
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

#import "ContentViewTiledLayer.h"

@implementation ContentViewTiledLayer
@synthesize isChangeFrame=_isChangeFrame;
+ (CFTimeInterval)fadeDuration {
    return 0;
}
/*

+ (BOOL)needsDisplayForKey:(NSString *)key{
   
    //NSLog(@"(BOOL)needsDisplayForKey:(NSString *)key %@",key);
    if ([key isEqualToString:@"frame"]) {
        return NO;
    }
    if ([key isEqualToString:@"bounds"]) {
        return NO;
    }
    if ([key isEqualToString:@"isChangeFrame"]) {
        return NO;
    }
    if ([key isEqualToString:@"visibleRect"]) {
        return NO;
    }
    if ([key isEqualToString:@"contentsRect"]) {
        return NO;
    }  
    
    
    return [super needsDisplayForKey:key];
}
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    //NSLog(@"tiledlayer -(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx");
    [super drawLayer:layer inContext:ctx];
    
}

-(void)drawInContext:(CGContextRef)ctx{
    if (_isChangeFrame) {
        
        [self.delegate drawLayer:self inContext:ctx];
        self.isChangeFrame=FALSE;
        //NSLog(@"tiledlayer -canceld- (void)drawInContext:(CGContextRef)ctx");
        return;
    }
    //NSLog(@"tiledlayer --(void)drawInContext:(CGContextRef)ctx");
    [super  drawInContext:ctx];
}

*/



@end
