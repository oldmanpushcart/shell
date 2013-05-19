#!/bin/ksh

# write by	: oldmanpushcart@gmail.com
# date		: 2012-05-19
# version	: 0.05

typeset top=${1:-10}
typeset pid=${2:-$(pgrep -u $USER java|head -1)}
typeset tmp_file=/tmp/java_$pid_$$.trace

$JAVA_HOME/bin/jstack $pid > $tmp_file
ps H -eo user,pid,ppid,tid,time,%cpu --sort=%cpu|tail -$top|awk '$2==pid{print $4"\t"$6}' pid=$pid|while read line;
do
    typeset nid="0x"$(echo "$line"|awk '{print $1}'|xargs -I{} echo "obase=16;{}"|bc|tr 'A-Z' 'a-z')
    typeset cpu=$(echo "$line"|awk '{print $2}')
    cat $tmp_file|awk '/nid='"$nid"'/,/^$/{print $0"\t"(isF++?"":"cpu="'"$cpu"'"%");}'
done;

rm -f $tmp_file
