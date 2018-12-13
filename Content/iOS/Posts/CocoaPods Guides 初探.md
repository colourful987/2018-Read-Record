###pod install vs. pod update
pod install 侧重于 install(uninstall)，即增加新repo或者移除旧repo的时候需要调用，此时把安装好的repos的version全部写入到 `Podfile.lock`文件中🔐起来，之后再次调用 `pod install` 跟踪的是lock文件中的锁死版本的repo，即使podfile中修改了version也不会去下载新版本的仓库。
换句话说，`pod install` 仅解决那些没有在 `podfile.lock` 加入依赖的repos，我猜测是和podfile做对比，对比的结果是“加入还是移除”，这可比判断每个仓库的最新版本高效的多。

个人认为之所有要有 podfile.lock，主要原因有两点：

* 首先标记下载和安装了哪些repos，以及对应的version，而且是锁死了版本，即使不小心修改了podfile，也不会去下载新的repo；
* 同时一旦添加新的pods或者要移除旧的pods，`pod install`会根据 podfile和 podfile.lock 比对找到，然后去下载最新的或者移除旧的

`pod outdated`会列出所有过时的pod，以及新版本，当然只是 podfile中规定的版本和实际当然工程repo的版本比较。

`pod update` 仅做到了版本的更新，下载最新的pod 然后更新.lock里面记录的版本。