#!/usr/bin/env python
# encoding: UTF-8

import daemon
import os
import multiprocessing
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
        self.do_exit = False
        self.do_refresh = False
        self.has_started = False
        self.fh = None

    def open_output(self):
        self.fh = sys.stderr

    def close_output(self):
        self.fh = None

    def init_exit(self, signal_no=0, stack_frame=None):
        self.fh.write(
            "{0} [{1}] child: exit initiated\n".format(
                time.ctime(), self.pid
            )
        )
        self.fd.write("{0}\n".format(self.pid))
        self.do_exit = True

    def perform_exit(self):
        self.fh.write(
            "{0} [{1}] child: performing exit\n".format(
                time.ctime(), self.pid
            )
        )
        self.cleanup()

    def init_refresh(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] child: refresh initiated\n".format(
                time.ctime(), self.pid
            )
        )

    def perform_refresh(self):
        self.do_refresh = False
        self.fh.write(
            "{0} [{1}] child: performing refresh\n".format(
                time.ctime(), self.pid
            )
        )
        self.config = {}
        pass

    def cleanup(self):
        time_secs = (self.pid % 10) + 1
        time_now = time.time()
        self.fh.write(
            "{0} [{1}] child: performing cleanup\n".format(
                time.ctime(), self.pid
            )
        )
        # Do cool stuff here ...
        #time.sleep(time_secs)
        self.fh.write(
            "{0} [{1}] child: finished cleanup [t={2}s]\n".format(
                time.ctime(), self.pid, int(time.time() - time_now)
            )
        )

    def start(self):
        self.has_started = True
        r, w = os.pipe()
        pid = os.fork()
        if pid == 0:
            signal.signal(signal.SIGTERM, self.init_exit)
            signal.signal(signal.SIGHUP, self.init_refresh)
            signal.signal(signal.SIGPIPE, signal.SIG_DFL)
            self.pid = os.getpid()
            os.close(r)
            self.fd = os.fdopen(w, "w", 0)
            self.open_output()
            try:
                self.main()
            except Exception as e:
                self.fh.write(
                    "{0} [{1}] child: exit details ('{2}')\n".format(
                        time.ctime(), self.pid, repr(e)
                    )
                )
            finally:
                os._exit(0)
        else:
            self.pid = pid
            os.close(w)
            self.fd = os.fdopen(r)

    def main(self):
        self.fh.write(
            "{0} [{1}] child: started\n".format(
                time.ctime(), self.pid
            )
        )
        while not self.do_exit:

            if not int(time.time() + self.pid) % 10:
                self.fh.write(
                    "{0} [{1}] child: process is running\n".format(
                        time.ctime(), self.pid
                    )
                )

            if self.do_refresh:
                self.perform_refresh()

            time.sleep(1)

        if self.do_exit:
            self.perform_exit()

        self.fh.write(
            "{0} [{1}] child: will exit now\n".format(
                time.ctime(), self.pid
            )
        )
        self.close_output()
        os._exit(0)

class Parent(object):
    def __init__(self,n_children=1):
        self.do_exit = False
        self.do_refresh = False
        self.child_exited = False
        signal.signal(signal.SIGTERM, self.init_exit)
        signal.signal(signal.SIGHUP, self.init_refresh)
        signal.signal(signal.SIGCHLD, self.catch_child_exit)
        self.children = []
        self.pid = os.getpid()

        for n in xrange(n_children):
            c = Child()
            self.children.append(c)

    def init_exit(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: exit initiated\n".format(
                time.ctime(), self.pid
            )
        )
        self.do_exit = True

    def perform_exit(self):
        sys.stderr.write(
            "{0} [{1}] parent: performing exit\n".format(
                time.ctime(), self.pid
            )
        )
        for c in self.children:
            if c.has_started is True:
                os.kill(c.pid, signal.SIGTERM)
        self.cleanup()

    def init_refresh(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: refresh initiated\n".format(
                time.ctime(), self.pid
            )
        )
        self.do_refresh = True

    def perform_refresh(self):
        self.do_refresh = False
        sys.stderr.write(
            "{0} [{1}] parent: performing refresh\n".format(
                time.ctime(), self.pid
            )
        )
        for c in self.children:
            if c.has_started is True:
                os.kill(c.pid, signal.SIGHUP)
        self.config = {}

    def catch_child_exit(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: child exit detected\n".format(
                time.ctime(), self.pid
            )
        )
        self.child_exited = True

    def process_child_exit(self):
        self.child_exited = False
        remaining_children = []
        pids_exit = []
        re_pid = re.compile('^\d+$')
        fds = map(lambda c: c.fd, self.children)
        sys.stderr.write(
            "{0} [{1}] parent: processing child exit(s)\n".format(
                time.ctime(), self.pid
            )
        )

        # poll() schijnt efficienter te zijn
        fds_r, fds_w, fds_x = select.select(fds, [], [])
        for fd in fds_r:
            pid_read = fd.readline()

            sys.stderr.write(
                    "{0} [{1}] PRE: parent: read from child: '{2}'\n".format(
                    time.ctime(), self.pid, pid_read
                )
            )

            if not re_pid.match(pid_read):
                continue

            sys.stderr.write(
                "{0} [{1}] parent: read from child: '{2}'\n".format(
                    time.ctime(), self.pid, pid_read
                )
            )
            (pid_wait, status) = os.waitpid(pid_read, os.WNOHANG)
            if pid_wait:
                sys.stderr.write(
                    "{0} [{1}] parent: processing child exit ({2})\n".format(
                        time.ctime(), self.pid, pid_wait
                    )
                )
                pids_exit.append(pid_wait)

        for c in self.children:
            if not c.pid in pids_exit:
                remaining_children.append(c)

        self.children = remaining_children

    def cleanup(self):
        time_secs = (self.pid % 10) + 1
        time_now = time.time()
        sys.stderr.write(
            "{0} [{1}] parent: performing cleanup\n".format(
                time.ctime(), self.pid
            )
        )
        # Do cool stuff here ...
        time.sleep(time_secs)
        sys.stderr.write(
            "{0} [{1}] parent: finished cleanup [t={2}s]\n".format(
                time.ctime(), self.pid, int(time.time() - time_now)
            )
        )

    def start(self):
        sys.stderr.write(
            "{0} [{1}] parent: started\n".format(
                time.ctime(), self.pid
            )
        )
        for c in self.children:
            if c.has_started is False:
                c.start()

        while (
            len(self.children) > 0 and
            not self.do_exit
        ):
            if not int(time.time() + self.pid) % 10:
                sys.stderr.write(
                    (
                        "{0} [{1}] parent: process is running " +
                        "(children={2})\n"
                    ).format(
                        time.ctime(), self.pid, len(self.children)
                    )
                )

            if self.child_exited:
                self.process_child_exit()

            if self.do_refresh:
                self.perform_refresh()

            time.sleep(1)

        if self.do_exit:
            self.perform_exit()

        while len(self.children) > 0:
            time.sleep(1)

        sys.stderr.write(
            "{0} [{1}] parent: all children have exited\n".format(
                time.ctime(), self.pid
            )
        )
        sys.stderr.write(
            "{0} [{1}] parent: will exit now\n".format(
                time.ctime(), self.pid
            )
        )
        sys.exit(0)

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
            signal.SIGTERM: p.init_exit,
            signal.SIGHUP: p.init_refresh
        },
        #detach_process = False,
        stdout = sys.stdout,
        stderr = sys.stderr
    )

    with context:
        p.start()
