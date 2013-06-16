#!/bin/ksh

# write by	: oldmanpushcart@gmail.com
# date		: 2013-06-16
# version	: 0.06

#!/bin/ksh

typeset top=${1:-10}
typeset pid=${2:-$(pgrep -u $USER java)}
typeset tmp_file=/tmp/java_$pid_$$.trace

$JAVA_HOME/bin/jstack $pid > $tmp_file
ps -eo user,pid,ppid,%cpu|sort -nk4|tail -$top|awk '$2==pid{print $3"\t"$4}' pid=$pid|while read line;
do
	typeset nid="0x"$(echo "$line"|awk '{print $1}'|xargs -I{} echo "obase=16;{}"|bc|tr 'A-Z' 'a-z')
	typeset cpu=$(echo "$line"|awk '{print $2}')
	cat $tmp_file|awk '/nid='"$nid"'/,/^$/{print $0"\t"(isF++?"":"cpu="'"$cpu"'"%");}'
done;

rm -f $tmp_file

