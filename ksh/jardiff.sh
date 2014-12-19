#!/bin/ksh

# write by : oldmanpushcart@gmail.com
# date     : 2014-01-16
# version  : 0.0.7

typeset FIND_DIR=${1}
typeset JARDIFF_TMP_FILE=/tmp/jardiff.$$

# the main function
function _main
{

	find ${FIND_DIR} -type f -iname *.jar\
		|while read f;do\
			unzip -v ${f}\
				|awk '$7>0&&$8~/class$/{print f"\t"$7"\t"$8}' f=${f};\
		done > ${JARDIFF_TMP_FILE}

	cat ${JARDIFF_TMP_FILE}\
		|cut -f3|sort|uniq -c|awk '$1>1{print $2}'|while read f;do
			typeset local CRC_32_C=$(awk -v "f=${f}" '$3!=f{print $2}' ${JARDIFF_TMP_FILE}|sort|uniq|wc -l)
			[[ $CRC_32_C -gt 1 ]] && fgrep ${f} ${JARDIFF_TMP_FILE}
		done

	_finish
}

# the finish function need clean something
function _finish
{
	rm -rf ${JARDIFF_TMP_FILE}
	exit 0;
}

trap "_finish" SIGINT
_main "$@"
