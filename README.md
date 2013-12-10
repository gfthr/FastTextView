FastTextView
============

The best rich editor  (TextView) on IOS platform , should be the fastest , opensourced by chineseall.com ,developed by gfthr (gfthr@sina.com).

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

中文介绍 :
============
FastTextView是一个富文本（Rich Text）编辑器，支持在文字中插入视图，文字输入性能极高。由中文在线(chineseall.com)开源，由gfthr 开发。

代码在开源代码EGOTextView（https://github.com/enormego/EGOTextView）基础上做了很大的改进（有约50%的代码改动），提高了大量文字输入的性能，这也是命名为FastTextView的原因。 

主要性能如下： 

1)插入文本速度很快，特别是针对大量文字的输入（进过测试，输入50万字的反应速度还是很快；而其他的文字编辑器，输入几千字就会变卡）。
为提高文字插入的速度，作者引入了新的NSMutableAttributedString的子类FastTextStorage，任何文字的修改都只需要很少时间来重建某些文字段落，从而大大提高文字输入效率。 

2)支持插入图片 

3)支持插入表情 

4)支持iOS 7 

这也许是iOS上最好的开源富文本编辑器。 