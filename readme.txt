说明

crash日志符号化窗口小程序，为了方便像我这样的鼠标党。

原理依然是执行terminal命令，下面是用到的命令：

获取app的UUID
dwarfdump --uuid ***.app/***
获取dsym的UUID
dwarfdump --uuid ***.dSYM
查找symbolicatecrash
find /Applications/Xcode.app -name symbolicatecrash -type f
执行symbolicatecrash
symbolicatecrash ***.crash ***.app > crash.log
建立快捷方式
sudo ln -s /Applications/Xcode.app/Contents/SharedFrameworks/DTDeviceKitBase.framework/Versions/A/Resources/symbolicatecrash /usr/local/bin/symbolicatecrash

如果遇到 "DEVELOPER_DIR" is not defined 的报错，执行以下命令：
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

执行atos 代码里没使用这个命令
xcrun atos -o  ***.app/*** -arch armv7 -l 0x161efff -f ***.crash




下一步  批量处理的办法