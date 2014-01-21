#!/usr/bin/env python
# encoding: UTF-8

import daemon
import os
import signal
import sys
import time

NUMBER_OF_CHILDREN=3

class Child(object):
    def __init__(self):
        self.exit_child = False
        self.has_started = False
        self.fh = None

    def openOutput(self):
        self.fh = sys.stderr

    def closeOutput(self):
        self.fh = None

    def cleanup(self):
        time_secs = (os.getpid() % 10) + 1
        time_now = time.time()
        self.fh.write(
            "{0} [{1}] child: now cleaning up\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        # Do cool stuff here ...
        time.sleep(time_secs)
        self.fh.write(
            "{0} [{1}] child: finished cleaning up [t={2}s]\n".format(
                time.ctime(), os.getpid(), int(time.time() - time_now)
            )
        ) 

    def start(self):
        self.has_started = True
        pid = os.fork()
        if pid == 0:
            signal.signal(signal.SIGTERM, self.stop)
            self.main()
            os._exit(0)
        else:
            self.pid = pid

    def stop(self, signal_no, strack_frame):
        self.fh.write(
            "{0} [{1}] child: stop initiated\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        self.exit_child = True

    def main(self):
        self.openOutput()
        self.fh.write(
            "{0} [{1}] child: started\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        while self.exit_child is False:
            self.fh.write(
                "{0} [{1}] child: process is running\n".format(
                    time.ctime(), os.getpid()
                )
            ) 
            time.sleep(60)
        self.cleanup()
        self.fh.write(
            "{0} [{1}] child: will exit now\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        self.closeOutput()
        os._exit(0)

class Parent(object):
    def __init__(self,n_children=1):
        signal.signal(signal.SIGTERM, self.stop)
        self.children = []
        for n in xrange(n_children):
            c = Child()
            self.children.append(c)

    def waitChildren(self):
        for n, c in enumerate(self.children):
            ret = os.waitpid(c.pid, os.WNOHANG)
            if ret[0] != 0:
                self.children.pop(n)
                sys.stderr.write(
                    "{0} [{1}] parent: child exited [pid={2}]\n".format(
                        time.ctime(), os.getpid(), c.pid
                    )
                ) 

    def cleanup(self):
        time_secs = (os.getpid() % 10) + 1
        time_now = time.time()
        sys.stderr.write(
            "{0} [{1}] parent: now cleaning up\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        # Do cool stuff here ...
        time.sleep(time_secs)
        sys.stderr.write(
            "{0} [{1}] parent: finished cleaning up [t={2}s]\n".format(
                time.ctime(), os.getpid(), int(time.time() - time_now)
            )
        ) 

    def start(self):
        sys.stderr.write(
            "{0} [{1}] parent: started\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        for c in self.children:
            if c.has_started is False:
                c.start()
        while len(self.children) > 0:
            self.waitChildren()
            time.sleep(10)
        sys.stderr.write(
            "{0} [{1}] parent: All children have exited\n".format(
                time.ctime(), os.getpid()
            )
        )
        self.cleanup()
        sys.stderr.write(
            "{0} [{1}] parent: will exit now\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        sys.exit(0)

    def stop(self, signal_no, strack_frame):
        sys.stderr.write(
            "{0} [{1}] parent: stop initiated\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        for c in self.children:
            if c.has_started is True:
                os.kill(c.pid, signal.SIGTERM)
        while len(self.children) > 0:
            self.waitChildren()

if __name__ == '__main__':
    p = Parent(NUMBER_OF_CHILDREN)

    context = daemon.DaemonContext(
        pidfile = "/tmp/daemon-test.pid",
        signal_map = {
            signal.SIGTERM: p.stop
        }
    )

    p.start()
