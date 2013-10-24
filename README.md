FastTextView
============

The best rich editor  (TextView) on IOS platform , should be the fastest , opensourced by gfthr (gfthr@sina.com).

FastTextView is inspired by EGOTextView , and made some significant improvement to enchance peformance on large text input speed , changed about 50% code , so named new project FastTextView.

some feature list blow:

1)insert text is very fast on large text input (about 50K on iphone4), because we introduced a new subclass of NSMutableAttributedString named 'FastTextStorage',any modification on text only need little time to rebuild some invalidate paragragh,this is a good base and  could be more fast and more stable


2)insert attachment cell is easy and you can custom youself attachment cell


3)caret behaviour like normal editor


4)eliminate duplicate setNeedDisplay request 


Thank you the ChinesAll.com , the china best digital content puslisher !

This editor is used on the ChinesAll's writing and reading mobile app tangyuan (see www.itangyuan.com) 


demo 
============
![demo1](https://raw.github.com/gfthr/FastTextView/master/screenshot/demo1.png "demo1")

![demo2](https://raw.github.com/gfthr/FastTextView/master/screenshot/demo2.png "demo2")



Install
============
1.put FastTextViewLib to the parrael directory, add  FastTextViewLib.xcodeproj to your main project

2.TARGETS->your target->link binary with libraries->add libFastTextViewLib.a

3.PROJECT->header search paths-> ../FastTextViewLib/FastTextViewLib/Class

4.TARGETS->header search paths-> ../FastTextViewLib/FastTextViewLib/Class

5.PROJECT->Other linker Flags ->-all_load

6.TARGETS->Other linker Flags ->-all_load

7.import framework: QuartzCore.framework,CoreText.framework,AssetsLibrary.framework,CoreGraphics.framework


that's all!