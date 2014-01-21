#!/usr/bin/env python
# encoding: UTF-8

import os
import signal
import sys
import time

NUMBER_OF_CHILDREN=3

class Child(object):
    def __init__(self):
        self.exit_child = False
        self.has_started = False
        self.fh = sys.stderr
        self.file_out = "/tmp/hopla-{0}.out".format(os.getpid())

    def openOutput(self):
        self.fh = open(self.file_out, "a")

    def closeOutput(self):
        self.fh.close()

    def cleanup(self):
        time_secs = os.getpid() % 10
        sys.stderr.write(
            "{0} [{1}] child: now cleaning up ({2}s)\n".format(
                time.ctime(), os.getpid(), time_secs
            )
        ) 
        time.sleep(time_secs)

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
            "{0} [{1}] child: stop initiated!\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        self.exit_child = True

    def main(self):
#        self.openOutput()
        sys.stderr.write(
            "{0} [{1}] child: started\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        while self.exit_child is False:
            sys.stderr.write(
                "{0} [{1}] child: Hopla!\n".format(
                    time.ctime(), os.getpid()
                )
            ) 
            time.sleep(60)
#        self.closeOutput()
        self.cleanup()
        sys.stderr.write(
            "{0} [{1}] child: will exit now!\n".format(
                time.ctime(), os.getpid()
            )
        ) 
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
                    "{0} [{1}] parent: child with pid='{2}' exited!\n".format(
                        time.ctime(), os.getpid(), c.pid
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

    def stop(self, signal_no, strack_frame):
        sys.stderr.write(
            "{0} [{1}] parent: stop initiated!\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        for c in self.children:
            if c.has_started is True:
                os.kill(c.pid, signal.SIGTERM)
        while len(self.children) > 0:
            self.waitChildren()
        sys.stderr.write(
            "{0} [{1}] parent: All children have exited!\n".format(
                time.ctime(), os.getpid()
            )
        )
        sys.stderr.write(
            "{0} [{1}] parent: will exit now!\n".format(
                time.ctime(), os.getpid()
            )
        ) 
        sys.exit(0)


if __name__ == '__main__':
    p = Parent(NUMBER_OF_CHILDREN)
    p.start()
