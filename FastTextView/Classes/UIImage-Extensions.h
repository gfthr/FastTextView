//
//  UIImage-Extensions.h
//  The9AdPlatform
//
//  Created by zhang xiaodong on 11-5-31.
//  Copyright 2011 the9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (CS_Extensions)
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToMinimumSizeAdv:(CGSize)targetSize;
- (CGSize)sizeByScalingProportionallyToSize:(CGSize)targetSize;

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSizeAdv:(CGSize)targetSize ;

- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;


- (UIImage*) addStarToThumb:(UIImage*)thumb;
@end;
