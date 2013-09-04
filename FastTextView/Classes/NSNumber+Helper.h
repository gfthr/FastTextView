//
//  NSNumber+Helper.h
//  imaibei
//
//  Created by wang qiang on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Helper)

+(NSNumber *)getObjectNumberInt:(id)obj;

+(NSNumber *)getObjectNumberFloat:(id)obj;

+(NSInteger)getObjectIntValue:(id)obj;

+(float)getObjectFloatValue:(id)obj;

+(double)getObjectDoubleValue:(id)obj;

+(double)strToDouble:(NSString *)obj;

+(NSString *)doubleToString:(double)val;

@end
