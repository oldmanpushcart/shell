#!/bin/ksh

# write by    : oldmanpushcart@gmail.com
# date        : 2014-01-16
# version     : 0.07

typeset top=${1:-10}
typeset pid=${2:-$(pgrep -u $USER java)}
typeset tmp_file=/tmp/java_${pid}_$$.trace

# fix for alibaba-inc.com
export JAVA_HOME=/opt/taobao/java

$JAVA_HOME/bin/jstack $pid > $tmp_file
ps H -eo user,pid,ppid,tid,time,%cpu --sort=%cpu --no-headers\
	| tail -$top\
	| awk -v "pid=$pid" '$2==pid{print $4"\t"$6}'\
	| while read line;
do
	typeset nid=$(echo "$line"|awk '{printf("0x%x",$1)}')
        typeset cpu=$(echo "$line"|awk '{print $2}')
        awk -v "cpu=$cpu" '/nid='"$nid"'/,/^$/{print $0"\t"(isF++?"":"cpu="cpu"%");}' $tmp_file
done

rm -f $tmp_file
