#!/bin/ksh

# write by    : oldmanpushcart@gmail.com
# date        : 2014-09-24
# version     : 0.02

find ${1} -type f -name "${2}" | while read f;do
    grep -Eo '[A-Za-z]+Exception' ${f}|while read exp;do
        printf "%s\t%s\n" ${f} ${exp}
    done
done|sort|uniq -c
