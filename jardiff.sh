#!/bin/ksh

typeset JAR_DIR=${1}
typeset TMP_DIR=/tmp/jardiff/$$
typeset JAR_LST=/tmp/jardiff/$$/jar.list


# define the function for compatiable the OS'X and Linux
# args :
# 	$1 : the file
# return : 
#   md5 file
function _md5
{
	typeset OS=$(uname)
	if [[ $OS == "Darwin" ]]; then
		md5 $1 | awk -F "[)|(| ]" '{print $6"\t"$3}'
	else
		md5sum $1
	fi
}

# the main function
function _main
{
	# found the jar file, and unzip theme to $TMP_DIR
	mkdir -p ${TMP_DIR}
	ls ${JAR_DIR}|while read jarfile;do
    	mkdir -p ${TMP_DIR}/${jarfile}/
    	unzip -qo ${JAR_DIR}/${jarfile} -d ${TMP_DIR}/${jarfile}/
	done


	# found the class file from $TMP_DIR and analyze them to JAR_LST file
	# fix: compatiable the OS'X and Linux 's different
	# format the output, CLASSFILE <tab> MD5_CHECKSUM <tab> JARFILE
	find ${TMP_DIR} -type f -name *.class |while read classfile;do
    		_md5 ${classfile}
	done\
		|awk -F "/| " '{for(i=8;i<=NF;i++)f=f"/"$i;print f"\t"$1"\t"$7;f="";}'\
		> ${JAR_LST}


	# analyze the JAR_LST file , to found the line which jarfile equal but the md5 checksum different
	# todo : need faster
	# find the not unique classfile
	cat ${JAR_LST}\
		|cut -f1|sort|uniq -c|awk '$1>1{print $2}'\
		|while read jarfile;do
			# check all the md5 checksum in JAR_LST which line was match ${jarfile}
    			typeset f=$(grep $jarfile ${JAR_LST}|cut -f2|sort|uniq|wc -l);
    			[[ $f != "1" ]]&& grep ${jarfile} ${JAR_LST}
		done|sort|uniq

	# finish the shell ^_^
	_finish
}

# the finish function need clean something
function _finish
{
	rm -rf ${TMP_DIR}
	exit 0;
}

trap "_finish" SIGINT
_main "$@"
