#!/usr/bin/python
import os
import sys
import time
import datetime
import re
from optparse import OptionParser

def last(hsf_log):
    pos = 0
    t1 = 'x'
    t2 = 'x'
    f = open(hsf_log, 'rb')
    while t1 == t2:
        pos = pos - 1
        f.seek(pos, 2)
        if f.read(1) == '\02':
            lastline = f.readline().strip().split('\02')
            if len(lastline[0]) > 1:
                t2_temp = re.findall('(\d{4}-\d{2}-\d{2} \d{2}\:\d{2}\:\d{2})', lastline[0])
                if len(t2_temp) > 0:
                    t2 = t2_temp[0]
            if t1 == 'x':
                t1 = t2
            if t1 != t2:
                try:
                    del lastline[0]
                except IndexError:
                    pass
                break
            continue
    f.close()
    return lastline


def grep_info(log):
    p = re.compile('^(HSF-Consumer|HSF-ProviderDetail|HSF-Provider-Timeout|HSF-Consumer-Timeout)\01.*')
    l = {}
    k = {}

    for i in log:
        match = p.match(i)
        if match:
            i = match.group().split('\01')
            t = i[6]
            if t not in l:
                l[t] = {}
            cat = i[0]
            if not l[t].has_key(cat):
                        l[t][cat] = []
            k = {'key':i[2], 'rt_sum':i[5], 'qps_sum':i[4]}
            l[t][cat].append(k)
    return l

def init_dict():
    x = {}
    o = {}
    categorys = ['HSF-ProviderDetail', 'HSF-Consumer', 'HSF-Provider-Timeout', 'HSF-Consumer-Timeout']    
    for cat in categorys:
        x[cat] = {}
        o[cat] = {}
        x[cat]['total'] = {'qps_sum':0, 'rt_sum':0}
        o[cat]['total'] = {'qps':0, 'rt':0}
    return (x, o)


def cat_calc(info, d):
    x = d[0]
    o = d[1]
    def oo(x):return ('%.2f' % x).rstrip('0').rstrip('.')

    for i in info[1]:
        for j in info[1][i]:
            key = j['key']
            if not x[i].has_key(key):
                x[i][key] = {'qps_sum':0, 'rt_sum':0}
                o[i][key] = {'qps':0, 'rt':0}
            x[i][key]['qps_sum'] += float(j['qps_sum'])
            x[i][key]['rt_sum'] += float(j['rt_sum'])
            x[i]['total']['qps_sum'] += float(j['qps_sum'])
            x[i]['total']['rt_sum'] += float(j['rt_sum'])
        for j in x[i]:
            key_qps = float(x[i][j]['qps_sum']) / 120
            key_qps = oo(key_qps)
            key_rt = float(x[i][j]['rt_sum']) / x[i][j]['qps_sum']
            key_rt = oo(key_rt)
            o[i][j] = {'qps':key_qps, 'rt':key_rt}
    title = info[0] + '\t' + os.uname()[1] + '\t' + 'thsf' + '\t'
    P_qps = float(o['HSF-ProviderDetail']['total']['qps'])
    C_qps = float(o['HSF-Consumer']['total']['qps'])
    P_rt = float(o['HSF-ProviderDetail']['total']['rt'])
    C_rt = float(o['HSF-Consumer']['total']['rt'])
    P_Fail_Rate = 0
    C_Fail_Rate = 0
    if P_qps != 0:
        P_Fail_Rate = float(x['HSF-Provider-Timeout']['total']['qps_sum']) / float(x['HSF-ProviderDetail']['total']['qps_sum']) * 100
    if C_qps != 0:
        C_Fail_Rate = float(x['HSF-Consumer-Timeout']['total']['qps_sum']) / float(x['HSF-Consumer']['total']['qps_sum']) * 100

    detail = {'Detail':o}
    del detail['Detail']['HSF-Consumer']['total']
    del detail['Detail']['HSF-Consumer-Timeout']['total']
    del detail['Detail']['HSF-Provider-Timeout']['total']
    del detail['Detail']['HSF-ProviderDetail']['total']
    output = {'title':title, 'P_qps':P_qps, 'P_rt':P_rt, 'C_qps':C_qps, 'C_rt':C_rt, 'P_Fail_Rate':P_Fail_Rate, 'C_Fail_Rate':C_Fail_Rate, 'Detail':detail}

    return output


def printinfo(output, options):
    print '%(title)sP_qps=%(P_qps)0.2f\tP_rt=%(P_rt)0.2f\tC_qps=%(C_qps)0.2f\tC_rt=%(C_rt)0.2f\tP_Fail_Rate=%(P_Fail_Rate)0.2f\tC_Fail_Rate=%(C_Fail_Rate)0.2f' % output
    if options.detail is True:
        def _rjust(x, y):return "%s" % x.rjust(y)
        def _ljust(x, y):return "%s" % x.ljust(y)
        for i, j in output['Detail'].values()[0].items():
            for k in j.items():
                print _ljust(i + '/' + k[0], 50), 'QPS:', _rjust(k[1]['qps'], 8), 'RT:', _rjust(k[1]['rt'], 8)

def main():
    parser = OptionParser()
    # parser = OptionParser(usage="usage: %prog [options]",version="%prog 1.0")
    parser.add_option("-a", "--all", action="store_true", dest="all", default=False, help="HSF log output mode, -a output today HSF log ,default ouput lastline HSF log")
    parser.add_option("-u", "--user", action="store", dest="user", default="admin", help="HSF log USER,log path: /home/[user]/logs/monitor/monitor-app-org.eclipse.osgi.internal.baseadaptor.DefaultClassLoader.log")
    parser.add_option("-n", "--filedate", action="store", dest="filedate", default="0", help="analyse n days HSF log, use -a -n [ 1 ~ ], 1:yesterday, 2:the day before yesterday")
    parser.add_option("-d", "--detail", action="store_true", dest="detail", default=False, help="service detail info")
    parser.add_option("-g", "--g", action="store_true", dest="snmpd_g", default=False, help="only for snmpd use")

    (options, args) = parser.parse_args()

    d = ''
    if int(options.filedate) > 0:
        d = "." + str(datetime.date.today() - datetime.timedelta(days=int(options.filedate)))

    hsf_log = "/home/%s/logs/monitor/monitor-app-org.eclipse.osgi.internal.baseadaptor.DefaultClassLoader.log%s" % (options.user, d)

    if os.path.isfile(hsf_log):
        if options.all is False:
            l = grep_info(last(hsf_log))

            if not l:
                currenttime = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))
                l = {currenttime: []}

            lasttime = int(time.mktime(time.strptime(l.keys()[0], '%Y-%m-%d %H:%M:%S')))
            currenttime = int(time.time())
            if (currenttime - lasttime) > 123:
                currenttime = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))
                title = str(999) + '/' + str(currenttime) + '/' + os.uname()[1] + '\t' + 'thsf' + '\t'
                output = {'title':title, 'P_qps':0, 'P_rt':0, 'C_qps':0, 'C_rt':0, 'P_Fail_Rate':0, 'C_Fail_Rate':0}
                printinfo(output)
                sys.exit()

        else:
            f = open(hsf_log, 'rb')
            t = f.readline().strip().split('\02')
            f.close()
            l = grep_info(t)
    else:
        print "ERROR: %s file is not exist!" % hsf_log
        sys.exit()

    for a in sorted(l.items(), key=lambda l:l[0]):
        printinfo(cat_calc(a, init_dict()), options)
#
if __name__ == '__main__':
    main()
      
