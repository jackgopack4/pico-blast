#!/usr/bin/python

import time
import datetime
import subprocess
import getopt
import sys
import os

blast_args = '-task blastn -outfmt 7'
blast_exec = '/home/johnston/ncbi-blast-2.2.29+-src/c++/ReleaseMT/build/app/blast/blastn'
gprof_exec = '/usr/bin/gprof'


def usage():
    print 'Usage: benchmark.py [OPTION]'
    print 'Required:'
    print '    -d, --database=LIST     LIST is a listing of the names of wanted databases'
    print '                              e.g.  -d "database1, database2"'
    print '    -q, --query=LIST        LIST is a listing of the query files to be used'
    print '                              e.g.  -d "queryfile1, queryfile2"'
    print 'Optional:'
    print '    -h, --help              display this message'
    print '    -l, --logfile=FILE      specify log file name, default "blastn_profiling.log"'
    print ''

def query_files_exist(files):
    for f in files:
        if not os.path.isfile(f):
            print 'query file "' + f + '" does not exist'
            sys.exit(2)
    return True

def profile(db, query, log):
    q = query.split('/').pop()
    filename = 'profile_' + db + '_with_' + q
    fd = open( filename, 'w+' )
    try:
        subprocess.check_call([gprof_exec, blast_exec, 'gmon.out'], stdout=fd, stderr=log)
    except Exception as err:
        print err
    fd.close()

def tolog(message, fd):
    print >> fd, datetime.datetime.now().isoformat(), message
    fd.flush()

def main():
    global blast_args
    global blast_exec

    short_opts = 'hd:q:l:'
    long_opts = ['help', 'database=', 'query=', 'logfile=']
    try:
        opts, args = getopt.getopt(sys.argv[1:], short_opts, long_opts)
    except getopt.GetoptError as err:
        print err
        usage()
        sys.exit(1)

    databases = None
    queries = None
    logfile = 'blastn_profiling.log'
    for o,a in opts:
        if o in ('-h', '--help'):
            usage()
            sys.exit()
        elif o in ('-d', '--database'):
            databases = a.split(', ')
        elif o in ('-q', '--query'):
            queries = a.split(', ')
            query_files_exist(queries)
        elif o in ('-l', '--logfile'):
            logfile = a
        else:
            print 'unknown option: ' + o

    if databases == None or queries == None:
        usage()
        sys.exit()

    log = open(logfile, 'w+')
    tolog('START', log)

    times = {}
    for db in databases:
        times[db] = {}
        for query in queries:
            q = query.split('/').pop()
            filename = 'result_' + db + '_with_' + q
            fd = open(filename, 'w+')
            tolog('Running BLASTn: ' + db + ' with ' + q , log)
            start = time.time()
            try:
                subprocess.check_call( [blast_exec, '-query', query, '-db', db] + blast_args.split() , stdout=fd, stderr=log) 
            except Exception as err:
                # print err
                tolog('Error running BLASTn, continuing with next pair', log)
                times[db][query] = 'err'
                continue
            finally:
                fd.close()

            stop = time.time()
            tolog('BLASTn complete', log)
            times[db][query] = stop - start
            tolog('Running gprof: ' + db + ' with ' +q , log)
            profile(db, query, log)
            tolog('gprof complete', log)

    # print times
    tolog('FIN', log)
    log.close()

if __name__ == '__main__':
    main()
