#!/usr/bin/python

import sys
import benchmark
import getopt
import re

def usage():
    print 'Usage: aggregate.py [OPTION]'
    print 'Required:'
    print '    -d, --database=LIST     LIST is a listing of the names of wanted databases'
    print '                              e.g.  -d "database1, database2"'
    print '    -q, --query=LIST        LIST is a listing of the query files to be used'
    print '                              e.g.  -d "queryfile1, queryfile2"'
    print 'Optional:'
    print '    -h, --help              display this message'
    print ''

def main():
    short_opts = 'hd:q:'
    long_opts = ['help', 'database=', 'query=']
    try:
        opts, args = getopt.getopt(sys.argv[1:], short_opts, long_opts)
    except getopt.GetoptError as err:
        print err
        usage()
        sys.exit(1)

    databases = None
    queries = None
    for o,a in opts:
        if o in ('-h', '--help'):
            usage()
            sys.exit()
        elif o in ('-d', '--database'):
            databases = a.split(', ')
        elif o in ('-q', '--query'):
            queries = a.split(', ')
            benchmark.query_files_exist(queries)
        else:
            print 'unknown option: ' + o

    if databases == None or queries == None:
        usage()
        sys.exit()

    functions = {}
    for db in databases:
        for query in queries:
            q = query.split('/').pop()
            filename = 'profile_' + db + '_with_' + q
            with open(filename) as fd:
                for l in fd.readlines()[5:]: # leave out header
                    l = l.split()
                    if len(l) < 7:  # some lines w/o info
                        continue
                    func = l[6]
                    if float(l[2]) < 0.05:
                        break # don't do minor functions

                    if func in functions:
                        functions[func]['time'] += [float(l[2])]
                        functions[func]['percent'] += [float(l[0])]
                        functions[func]['calls'] += [int(l[3])]
                    else:
                        functions[func] = {}
                        functions[func]['time'] = [float(l[2])]
                        functions[func]['percent'] = [float(l[0])]
                        functions[func]['calls'] = [int(l[3])]
    
    # average values
    combined = []
    for func, metrics in functions.iteritems():
        time = sum(metrics['time']) / len(metrics['time'])
        percent = sum(metrics['percent']) / len(metrics['percent'])
        calls = sum(metrics['calls']) / len(metrics['calls'])
        combined += [(percent, time, calls, func)]

    combined.sort(reverse=True)

    print '  Percent     Time        Calls   Function'
    for values in combined:
        print(' %8.2f %8.2f %12d   %s' % values)



if __name__ == '__main__':
    main()
