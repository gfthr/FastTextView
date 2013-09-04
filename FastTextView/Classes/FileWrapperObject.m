//
//  FileWrapperObject.m
//  tangyuanReader
//
//  Created by leo on 13-8-15.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import "FileWrapperObject.h"

@implementation FileWrapperObject
@synthesize filePath;
@synthesize fileName;


-(void)dealloc{
    fileName = nil;
    filePath = nil;
}

@end
