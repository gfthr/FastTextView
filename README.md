FastTextView
============

The best rich editor  (TextView) on IOS platform , should be the fastest , opensourced by gfthr.

FastTextView is inspired by EGOTextView , and made some significant improvement to enchance peformance on large text input speed , changed about 50% code , so named new project FastTextView.

some feature list blow:

1)insert text is very fast on large text input (about 50K on iphone4), because we introduced a new subclass of NSMutableAttributedString named 'FastTextStorage',any modification on text only need little time to rebuild some invalidate paragragh,this is a good base and  could be more fast and more stable


2)insert attachment cell is easy and you can custom youself attachment cell


3)caret behaviour like normal editor


4)eliminate duplicate setNeedDisplay request 


Thank you the ChinesAll.com , the china best digital content puslisher !

This editor is used on the ChinesAll's writing and reading mobile app tangyuan (see www.itangyuan.com) 
