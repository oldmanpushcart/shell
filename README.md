unixtools
=========

我在unixtools下积累的常用工具

Java线程过高问题排查
```
curl -sLk "https://raw.github.com/oldmanpushcart/unixtools/master/javatop.sh" | ksh -s 5 `pgrep -u admin java`
```
