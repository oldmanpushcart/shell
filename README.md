unixtools
=========

我在unixtools下积累的常用工具
PS，这里所有的工具都是给淘宝环境下使用，如果你不能理解脚本中的含义，请勿自己使用，谢谢呐。

Java线程过高问题排查
```
curl -sLk "https://raw.github.com/oldmanpushcart/unixtools/master/javatop.sh" | ksh -s 5 `pgrep -u admin java`
```
