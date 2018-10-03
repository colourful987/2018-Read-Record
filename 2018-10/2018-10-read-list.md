> Theme: 暂定
> Source Code Read Plan:
>
> - [ ] GCD 底层libdispatch
> - [ ] TableView Reload 原理，博文总结
>
> - [x] `objc_msgSend` 汇编实现收尾
> - [x] Custom UIViewController Transitions (实现App Store和知乎的转场效果)



# 2018/10/01 - 2018/10/03
Transition Animation 学习模仿App Store Today 中的点击转场动画，使用iPhone录屏来看实现，感觉是使用了约束实现的。

目前做的效果还不理想，之后修改觉得ok了放出来，现在连demo都称不上，一直在纠结的点是一开始就把toView的视图放上去，让toView内容做动画呢，还是fromView snapshot后搞个虚假视图做动画。

