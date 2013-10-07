#!/bin/ksh

rm -f xssh
rm -f xssh.ex

curl -s "https://raw.github.com/oldmanpushcart/unixtools/master/taobao/xssh.ex"|iconv -f UTF-8 -t GBK > xssh.ex
curl -s "https://raw.github.com/oldmanpushcart/unixtools/master/taobao/xssh"|iconv -f UTF-8 -t GBK > xssh