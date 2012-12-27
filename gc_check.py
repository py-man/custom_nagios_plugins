#!/usr/bin/env python
import os
import sys
import re
import time
import datetime
import hashlib
import subprocess
from optparse import OptionParser


"""
FullGC Log File example
2012-10-22T11:16:30.834+0000: 197883.168: [Full GC [PSYoungGen: 3169266K->0K(23841984K)] [ParOldGen: 55051367K->31736852K(55924096K)] 58220633K->31736852K(79766080K) [PSPermGen: 104922K->104911K(262144K)], 24.0307980 secs] 
[Times: user=156.38 sys=0.00, real=24.03 secs] 
"""

class GCLogFile:
    FGCCount = 0
    matchString = re.compile(r"^(\d+-\d+-\d+T\d+:\d+:\d+).\d+\+\d+:\s\d+.\d+:\s\[Full\sGC(.*)")
    FGCTime = re.compile(r".*\[Times:\suser=\d+.\d+\ssys=\d+.\d+,\sreal=(\d+.\d+)\ssecs\].*$")
    seekValue = 0
    running = 0
    runningtime = 0
    dateformat="%Y-%m-%dT%H:%M:%S"

    def __init__(self, filename, logpath):
        self.logpath = logpath
        self.filename = ""
        self.filesize = os.path.getsize(filename)

        self.log_fd = open(filename,"r")
        self.filename = os.path.abspath(filename)
        hashname=hashlib.md5(filename).hexdigest()
        offset_filename = os.path.join('/tmp/',hashname)
        self.offset_filename = offset_filename
        if not os.path.exists(offset_filename):
            self.offset_fd = open(offset_filename, 'w')
            self.offset_fd.write(str(self.filesize))
        else:
            self.offset_fd = open(offset_filename, 'r+')
            self.seekValue = int(self.offset_fd.readline())
            if self.seekValue > self.filesize:
                self.offset_fd = open(offset_filename, 'w')
                self.offset_fd.write(str(0))
                self.seekValue = 0
      

    def getGCCount(self):
        return self.FGCCount

    def getGCSeconds(self):
        if (self.running == 1):
            return self.runningtime.seconds
        else:
            return None
  
    def searchfgc(self):
        """Search for full gc event inside logfiles and save position in seek files. If file size < last seek probably log file rotate,
        seek set to 0 and file read start from the beginning"""
        self.log_fd = open(self.filename)
        self.log_fd.seek(int(self.seekValue))
        self.lastSeek = self.seekValue
        line = self.log_fd.readline()
        while line != '\n':
            result = self.matchString.search(line)
            if result:
                fgclog=result.group(2)
                gctime= self.FGCTime.search(result.group(0))
                if gctime:
                    self.FGCCount += 1
                else:
                    datestr= result.group(1)
                    starttime= datetime.datetime(*(time.strptime(datestr, self.dateformat)[0:6]))
                    utcnow = datetime.datetime.utcnow()
                    self.runningtime = utcnow - starttime
                    self.running = 1
                    break
            if (self.running == 0):
                self.lastSeek=self.log_fd.tell()
                line = self.log_fd.readline()
            if (self.filesize <= self.lastSeek):
                break 
        self.offset_fd = open(self.offset_filename, 'w')
        self.offset_fd.seek(0)
        self.offset_fd.write(str(self.lastSeek))

def findPsLog():
    """Use jps output to determine existing java process id and gc log files"""
    a=re.compile(r'(\d+).*-Xloggc:(.*?\.log)\s')
    cmd = subprocess.Popen('ps ax | grep java', shell=True, stdout=subprocess.PIPE)
    for line in cmd.stdout:
        result=a.search(line)
        if result:
            yield  result.groups()


def main():
    usage = "usage: %prog [options] arg1 arg2"
    parser = OptionParser(usage=usage)
    parser.add_option("-w", "--warning", default="3", action="store",
                    dest="wvalue", help="Full GC count warning value [ Default: %default ]")
    parser.add_option("-c", "--critical", default="5", action="store",
                    dest="cvalue", help="Full GC count critical value [ Default: %default ]")
    parser.add_option("-t", "--criticaltime", default="60", action="store",
                    dest="tvalue", help="Full GC running time critical value in seconds [ Default: %default ]")
    (opts, args) = parser.parse_args()

    mainout = ""
    critical = 0
    warning = 0 
    for process,fileToCheck in findPsLog():
        Logfile = GCLogFile(fileToCheck,'/tmp/')
        Logfile.searchfgc()
        FGCCount = Logfile.getGCCount()
        isRunning = Logfile.getGCSeconds()
        if isRunning and isRunning > int(opts.tvalue):
            mainout += "Process: %s - LogFile: %s - FGC Count = %d - FGC Run Time: %ds\n" % (process,fileToCheck,FGCCount,isRunning)
            critical += 1
            continue
        if FGCCount > opts.cvalue:
            mainout += "Process %s, LogFile=%s, FGC from last check \n" % (process,fileToCheck,FGCCount)
            critical += 1
            continue
        elif FGCCount > opts.wvalue:
            mainout += "Process %s, LogFile=%s , FGC from last check \n" % (process,fileToCheck,FGCCount)
            warning += 1
            continue
        else:
            mainout += "Process: %s, LogFile=%s , No FGC Problem - FGC Count = %d \n" % (process,fileToCheck,FGCCount)
            continue
    
    if (critical > 0):
        print "CRITICAL: FullGC Problem | ;;;; %s " % mainout
        sys.exit(2)
    if (warning > 0):
        print "WARNING: FullGC Problem | ;;;; %s " % mainout
        sys.exit(1)
    else:
        print "OK - No FGC Problem  | ;;;; %s" % mainout 
        sys.exit(0)

if __name__ == "__main__":
    main()


