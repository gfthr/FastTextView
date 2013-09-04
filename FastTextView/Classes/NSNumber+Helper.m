//
//  NSNumber+Helper.m
//  imaibei
//
//  Created by wang qiang on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSNumber+Helper.h"

@implementation NSNumber (Helper)

+(NSNumber *)getObjectNumberInt:(id)obj{
    return [NSNumber numberWithInt:[self getObjectIntValue:obj]] ;
}

+(NSNumber *)getObjectNumberFloat:(id)obj{
    return [NSNumber numberWithFloat:[self getObjectFloatValue:obj]] ;
}

+(NSInteger)getObjectIntValue:(id)obj{

    NSNumber *_intvalue= (NSNumber *)obj;
    
    if (_intvalue!=nil && _intvalue!=(NSNumber *)[NSNull null]){
        return _intvalue.intValue;
    } else {
        return 0;
    }  
        
}

+(float)getObjectFloatValue:(id)obj{    
    
    NSNumber *_intvalue= (NSNumber *)obj;
    
    if (_intvalue!=nil && _intvalue!=(NSNumber *)[NSNull null]){
        return _intvalue.floatValue;
    } else {
        return 0.0f;
    }  
    
}

+(double)getObjectDoubleValue:(id)obj{
    
    NSNumber *_intvalue= (NSNumber *)obj;
    
    if (_intvalue!=nil && _intvalue!=(NSNumber *)[NSNull null]){
        return _intvalue.doubleValue;
    } else {
        return 0.0f;
    }
    
}

+(double)strToDouble:(NSString *)obj{
    NSNumberFormatter *f=[[NSNumberFormatter alloc]init];
    return[f numberFromString:obj].doubleValue;
}

+(NSString *)doubleToString:(double)val{
    NSNumberFormatter *f=[[NSNumberFormatter alloc]init];
    return [f stringFromNumber:[NSNumber numberWithDouble:val]];
}


@end
