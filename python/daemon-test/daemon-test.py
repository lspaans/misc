#!/usr/bin/env python
# encoding: UTF-8

import daemon
import os
import pidfile
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
            signal.signal(signal.SIGHUP, self.refresh)
            self.main()
            os._exit(0)
        else:
            self.pid = pid

    def stop(self, signal_no=0, stack_frame=None):
        self.fh.write(
            "{0} [{1}] child: stop initiated\n".format(
                time.ctime(), os.getpid()
            )
        )
        self.exit_child = True

    def refresh(self, signal_no=0, stack_frame=None):
        self.config = {}
        sys.stderr.write(
            "{0} [{1}] child: config refresh\n".format(
                time.ctime(), os.getpid()
            )
        )

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
        signal.signal(signal.SIGHUP, self.refresh)
        signal.signal(signal.SIGCHLD, self.waitChildren)
        self.children = []
        for n in xrange(n_children):
            c = Child()
            self.children.append(c)

    def waitChildren(self, signal_no=0, stack_frame=None):
        remaining_children = []
        if len(self.children) > 0:
            (pid, status) = os.waitpid(0, os.WNOHANG)
            for c in self.children:
                if c.pid != pid:
                    remaining_children.append(c)
                else:
                    sys.stderr.write(
                        "{0} [{1}] parent: child exited [pid={2}]\n".format(
                            time.ctime(), os.getpid(), pid
                        )
                    )
        self.children = remaining_children

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
            time.sleep(10)

        sys.stderr.write(
            "{0} [{1}] parent: all children have exited\n".format(
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

    def stop(self, signal_no=0, stack_frame=None):
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
            time.sleep(1)

    def refresh(self, signal_no=0, stack_frame=None):
        self.config = {}
        sys.stderr.write(
            "{0} [{1}] parent: config refresh\n".format(
                time.ctime(), os.getpid()
            )
        )
        for c in self.children:
            if c.has_started is True:
                os.kill(c.pid, signal.SIGHUP)

if __name__ == '__main__':
    p = Parent(NUMBER_OF_CHILDREN)
    file_pid = "/tmp/daemon-test.pid"

    if os.path.exists(file_pid):
        sys.stderr.write(
            "{0} [{1}] parent: pidfile already exists\n".format(
                time.ctime(), os.getpid(), file_pid
            )
        )
        exit(1)

    context = daemon.DaemonContext(
        pidfile = pidfile.PidFile(file_pid),
        umask=0o077,
        signal_map = {
            signal.SIGTERM: p.stop
        },
        stdout = sys.stdout,
        stderr = sys.stderr
    )

    with context:
        p.start()
