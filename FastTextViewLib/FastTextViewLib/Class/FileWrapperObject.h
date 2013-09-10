//
//  FileWrapperObject.h
//  tangyuanReader
//
//  Created by leo on 13-8-15.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileWrapperObject : NSObject{
    NSString *filePath;
    NSString *fileName;
}

@property (nonatomic,strong)NSString *filePath;
@property (nonatomic,strong)NSString *fileName;

@end
