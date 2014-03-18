#!/usr/bin/env python
# encoding: UTF-8

import daemon
import os
import pidfile
import re
import select
import signal
import sys
import time

# HIERMEE VERDER!!!!
# http://docs.python.org/2/library/multiprocessing.html

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
        #time.sleep(time_secs)
        self.fh.write(
            "{0} [{1}] child: finished cleaning up [t={2}s]\n".format(
                time.ctime(), os.getpid(), int(time.time() - time_now)
            )
        )

    def start(self):
        self.has_started = True
        pid = os.fork()
        r, w = os.pipe()
        if pid == 0:
            signal.signal(signal.SIGTERM, self.stop)
            signal.signal(signal.SIGHUP, self.refresh)
            signal.signal(signal.SIGPIPE, signal.SIG_DFL)
            self.pid = os.getpid()
            os.close(r)
            self.fd = os.fdopen(w, "w", 0)
            self.main()
            os._exit(0)
        else:
            self.pid = pid
            os.close(w)
            self.fd = os.fdopen(r)

    def stop(self, signal_no=0, stack_frame=None):
        self.fh.write(
            "{0} [{1}] child: stop initiated\n".format(
                time.ctime(), os.getpid()
            )
        )
        self.fd.write("{0}\n".format(self.pid))
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
#            self.fd.write(
#                "{0} pipe data (pid='{1}')\n".format(
#                    time.ctime(), os.getpid()
#                )
#            )
            time.sleep(10)
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
        self.exit_parent = False
        self.exit_child = False
        signal.signal(signal.SIGTERM, self.stop)
        signal.signal(signal.SIGHUP, self.refresh)
        signal.signal(signal.SIGCHLD, self.set_child_exit_flag)
        self.children = []

        for n in xrange(n_children):
            c = Child()
            self.children.append(c)

    def set_child_exit_flag(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: child exit detected\n".format(
                time.ctime(), os.getpid()
            )
        )
        self.exit_child = True

    def process_child_exit(self):
        self.exit_child = False
        remaining_children = []
        pids_exit = []
        re_pid = re.compile('^\d+$')
        fds = map(lambda c: c.fd, self.children)
        sys.stderr.write(
            "{0} [{1}] parent: processing child exit(s)\n".format(
                time.ctime(), os.getpid()
            )
        )

        # poll() schijnt efficienter te zijn
        fds_r, fds_w, fds_x = select.select(fds, [], [])
        for fd in fds_r:
            pid_read = fd.readline()

            sys.stderr.write(
                    "{0} [{1}] PRE: parent: read from child: '{2}'\n".format(
                    time.ctime(), os.getpid(), pid_read
                )
            )

            if not re_pid.match(pid_read):
                continue

            sys.stderr.write(
                "{0} [{1}] parent: read from child: '{2}'\n".format(
                    time.ctime(), os.getpid(), pid_read
                )
            )
            (pid_wait, status) = os.waitpid(pid_read, os.WNOHANG)
            if pid_wait:
                sys.stderr.write(
                    "{0} [{1}] parent: processing child exit ({2})\n".format(
                        time.ctime(), os.getpid(), pid_wait
                    )
                )
                pids_exit.append(pid_wait)
        for c in self.children:
            if not c.pid in pids_exit:
                remaining_children.append(c)
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

        while (
            len(self.children) > 0 and
            not self.exit_parent
        ):
            sys.stderr.write(
                (
                    "{0} [{1}] parent: process is running " +
                    "(children={2})\n"
                ).format(
                    time.ctime(), os.getpid(), len(self.children)
                )
            )
            if self.exit_child:
                self.process_child_exit()
            time.sleep(10)

        if self.exit_parent:
            for c in self.children:
                if c.has_started is True:
                    os.kill(c.pid, signal.SIGTERM)

        while len(self.children) > 0:
            time.sleep(1)

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
        self.exit_parent = True

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
        detach_process = False,
        stdout = sys.stdout,
        stderr = sys.stderr
    )

    with context:
        p.start()
