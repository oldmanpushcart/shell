#!/bin/ksh

# write by  : oldmanpushcart@gmail.com
# date		: 2013-06-16
# version	: 0.06

typeset PROG=$(basename $0)

function usage {
cat <<EOF
Usage: ${PROG} [OPTION]...
Find out the highest cpu consumed threads of java, and print the stack of these threads.
Example: ${PROG} -t 10 -p 12345

OPTION:
    -p, PID    find out the highest cpu consumed threads from the specifed java process,
    -t, TOP    set the thread count to show, default is 5
    -h, HELP   display this help and exit
EOF
exit $1;
}

while getopts "t:p:h" options
do
	case ${options} in
	t)	typeset TOP=$OPTARG;;
	p)	typeset PID=$OPTARG;;
	h)	usage  0;;
	\?)	usage -1;;
	esac
done;

#check env
if [[ -n $JAVA_HOME && -x $JAVA_HOME/bin/jstack ]]; then
	typeset JSTACK_CMD=$JAVA_HOME/bin/jstack
else
	echo "Error: jstack not found on PATH and JAVA_HOME!" 1>&2;
	exit -1;
fi

#check args
if [[ ! $PID ]]; then
	echo "Error: the arguments -pid is need!" 1>&2;
	exit -1;
fi
[[ $TOP ]]|| TOP=5;

typeset TMP_FILE="/tmp/$PROG"_jstack."$$"
$JSTACK_CMD $PID > $TMP_FILE
[[ $? ]]&&exit $?;

ps -eo user,pid,ppid,%cpu|sort -nk4|tail -$TOP|awk '$2==pid{print $3"\t"$4}' pid=$PID|while read line;
do
    typeset nid="0x"$(echo "$line"|awk '{print $1}'|xargs -I{} echo "obase=16;{}"|bc|tr 'A-Z' 'a-z')
    typeset cpu=$(echo "$line"|awk '{print $2}')
    cat $TMP_FILE|awk '/nid='"$nid"'/,/^$/{print $0"\t"(isF++?"":"cpu="'"$cpu"'"%");}'
done;
