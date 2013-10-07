#!/bin/ksh

# cleanup
rm -f xssh
rm -f xssh.ex
rm -f lchosts

# download
curl -s "https://raw.github.com/oldmanpushcart/unixtools/master/taobao/xssh.ex"|iconv -f UTF-8 -t GBK > xssh.ex
curl -s "https://raw.github.com/oldmanpushcart/unixtools/master/taobao/xssh"|iconv -f UTF-8 -t GBK > xssh
curl -s "https://raw.github.com/oldmanpushcart/unixtools/master/taobao/lchosts"|iconv -f UTF-8 -t GBK > lchosts

# chmod
chmod +x xssh
chmod +x lchosts