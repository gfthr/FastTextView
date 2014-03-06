FastTextView
============

The best rich editor  (TextView) on IOS platform , should be the fastest , opensourced by  [www.chineseall.com](http://www.chineseall.com/ "http://chineseall.com/")  ,developed by gfthr (gfthr@sina.com).

FastTextView is inspired by EGOTextView , and made some significant improvement to enchance peformance on large text input speed , changed about 50% code , so named new project FastTextView.

some feature list blow:

1)insert text is very fast on large text input (about 50K on iphone4), because we introduced a new subclass of NSMutableAttributedString named 'FastTextStorage',any modification on text only need little time to rebuild some invalidate paragragh,this is a good base and  could be more fast and more stable


2)insert attachment cell is easy and you can custom youself attachment cell


3)caret behaviour like normal editor


4)eliminate duplicate setNeedDisplay request 

5)surpport IOS7 

6)demo app surpport emotion 


Thank you the ChinesAll.com , the china best digital content puslisher !

This editor is used on the ChinesAll's writing and reading mobile app tangyuan (see www.itangyuan.com) 


demo 
============
![demo1](https://raw.github.com/gfthr/FastTextView/master/screenshot/demo1.png "demo1")

![demo2](https://raw.github.com/gfthr/FastTextView/master/screenshot/demo2.png "demo2")


Install Method 1 :
============
1.put FastTextViewLib to the parrael directory, add  FastTextViewLib.xcodeproj to your main project

2.TARGETS->your target->link binary with libraries->add libFastTextViewLib.a

3.PROJECT->header search paths-> ../FastTextViewLib/FastTextViewLib/Class

4.TARGETS->header search paths-> ../FastTextViewLib/FastTextViewLib/Class

5.PROJECT->Other linker Flags ->-all_load

6.TARGETS->Other linker Flags ->-all_load

7.import framework: QuartzCore.framework,CoreText.framework,AssetsLibrary.framework,CoreGraphics.framework

Install Method 2 :
============
1.copy  all files in FastTextViewLib 's folder Resources and Class to you project folder and add these files to your project

2.build

that's all!



below is example code  for export html
============

```
- (NSString *)htmlStringWithAttachmentPath:(NSString *)attachpath ChapterAuthor:(ChapterAuthor *)chapterAuthor
{
    NSString *storeString = @"";
    
    NSAttributedString *newAttrStr=[self copy];
    NSMutableDictionary *textParagraphMap=[[NSMutableDictionary alloc]init];
    
    TextParagraph *textParagraph;
    NSRange longRange;
    unsigned int longPos = 0;
    while ((longPos < [newAttrStr length]) &&
           (textParagraph = [newAttrStr attribute:FastTextParagraphAttributeName atIndex:longPos longestEffectiveRange:&longRange inRange:NSMakeRange(0, [newAttrStr length])])){
        
        NSLog(@"textParagraph %@",textParagraph);
        [textParagraphMap setValue:NSStringFromRange(longRange) forKey:textParagraph.key];
        
        longPos = longRange.location + longRange.length;
    }
    
    NSDictionary *effectiveAttributes;
    NSRange range;
    unsigned int pos = 0;
    while ((pos < [newAttrStr length]) &&
           (effectiveAttributes = [newAttrStr attributesAtIndex:pos effectiveRange:&range])) {
        
        NSString *plainString=[[newAttrStr attributedSubstringFromRange:range] string];
        
        //一下三个替换步骤不可错误！
        //替换img的魔术占位符
        unichar attachmentCharacter = FastTextAttachmentCharacter;
        plainString=[plainString stringByReplacingOccurrencesOfString:[NSString stringWithCharacters:&attachmentCharacter length:1] withString:@""];
        //编码html标签
        plainString = [plainString stringByAddingHTMLEntities];
        //替换\n为<br/>标签
        plainString=[plainString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        
        
        NSRange paragraphRange = NSMakeRange(NSNotFound, NSNotFound) ;
        TextParagraph *textParagraph=[effectiveAttributes objectForKey:FastTextParagraphAttributeName];
        
        if (textParagraph!=nil) {
            NSString *rangstr= [textParagraphMap objectForKey:[NSString md5:[textParagraph description]]];
            paragraphRange=NSRangeFromString(rangstr);
        }
        if (paragraphRange.location!=NSNotFound && paragraphRange.location==range.location) {
            storeString=[storeString stringByAppendingString:@"<p>"];
        }
        
        //附件处理
        id<FastTextAttachmentCell> attachmentcell = [effectiveAttributes objectForKey:FastTextAttachmentAttributeName];
        NSInteger ifile=1;
        if (attachmentcell && [attachmentcell isKindOfClass:[SlideAttachmentCell class]])
        {
            SlideAttachmentCell *slideCell=(SlideAttachmentCell *)attachmentcell;
            FileWrapperObject  *fileWrapper =slideCell.fileWrapperObject;
            if (fileWrapper!=nil) {
                
                NSString *filepath=fileWrapper.filePath;
                
               
                UIImage *attimg= [UIImage imageWithContentsOfFile:filepath];
                NSString *newPath=[attachpath stringByAppendingPathComponent:fileWrapper.fileName];
                NSError *error;
                [[NSFileManager defaultManager] copyItemAtPath:filepath toPath:newPath error:&error];
             
                ifile++;
                
                if ([attachmentcell isKindOfClass:[SlideAttachmentCell class]]){
                    SlideAttachmentCell *cell=(SlideAttachmentCell*) attachmentcell;
                    NSInteger thumbImageWidth=DEFAULT_thumbImageWidth;
                    NSInteger thumbImageHeight=DEFAULT_thumbImageHeight;
                    if (attimg!=nil) {
                        CGSize size=[attimg sizeByScalingProportionallyToSize:CGSizeMake(thumbImageWidth, thumbImageHeight)];
                        thumbImageWidth=size.width;
                        thumbImageHeight=size.height;
                    }
                    
                    storeString=[storeString stringByAppendingFormat:@"<img src=\"%@\" height=\"%d\" width=\"%d\"" ,fileWrapper.fileName,thumbImageHeight,thumbImageWidth];
                    if (![NSString isEmptyOrNull:cell.txtdesc]) {
                        storeString=[storeString stringByAppendingFormat:@" title=\"%@\" ",cell.txtdesc];
                    }
                    
                    storeString=[storeString stringByAppendingString:@"/>"];
                }
            }
            
        }else{
            //文本
            storeString=[storeString stringByAppendingFormat:@"%@", plainString];
        }
        if (paragraphRange.length!=NSNotFound
            && (paragraphRange.location+paragraphRange.length)==(range.location+range.length)) {
            storeString=[storeString stringByAppendingString:@"</p>"];
        }
        
        pos = range.location + range.length;
    }
    NSString *chaptertitle=chapterAuthor.title;
    if ([NSString isEmptyOrNull:chaptertitle]) {
        chaptertitle=@"";
    }
    storeString=[NSString stringWithFormat:@"<html><head><meta name=\"chapter:timestamp\" content=\"%d\" /><title>%@</title></head><body>%@</body></html>",chapterAuthor.timestamp,chaptertitle,storeString];
    return storeString;
}

```



中文介绍 :
============
FastTextView是一个富文本（Rich Text）编辑器，支持在文字中插入视图，文字输入性能极高。由[中文在线](http://www.chineseall.com/ "中文在线")开源，由gfthr 开发。

代码在开源代码[EGOTextView](https://github.com/enormego/EGOTextView) 基础上做了很大的改进（有约50%的代码改动），提高了大量文字输入的性能，这也是命名为FastTextView的原因。 

主要性能如下： 

1)插入文本速度很快，特别是针对大量文字的输入（进过测试，输入50万字的反应速度还是很快；而其他的文字编辑器，输入几千字就会变卡）。
为提高文字插入的速度，作者引入了新的NSMutableAttributedString的子类FastTextStorage，任何文字的修改都只需要很少时间来重建某些文字段落，从而大大提高文字输入效率。 

2)支持插入图片 

3)支持插入表情 

4)支持iOS 7 

这也许是iOS上最好的开源富文本编辑器。 
