#!/usr/bin/env python
# encoding: UTF-8

import daemon
import os
import multiprocessing
import pidfile
import re
import signal
import sys
import time

DEF_NUMBER_OF_CHILDREN = 3
DEF_FILE_PID = "/tmp/daemon-test.pid"

class Child(object):
    def __init__(self):
        self.do_exit = False
        self.do_refresh = False
        self.has_started = False
        self.parent_exit = False
        self.fh = None

    def open_output(self):
        self.fh = sys.stderr

    def close_output(self):
        self.fh = None

    def init_signals(self):
        signal.signal(signal.SIGTERM, self.init_exit)
        signal.signal(signal.SIGHUP, self.init_refresh) 

    def init_exit(self, signal_no=0, stack_frame=None):
        self.fh.write(
            "{0} [{1}] child: exit initiated\n".format(
                time.ctime(), self.pid
        ))
        self.do_exit = True

    def perform_exit(self):
        self.fh.write(
            "{0} [{1}] child: performing exit\n".format(
                time.ctime(), self.pid
        ))
        self.cleanup()
        self.send('exit')

    def init_parent_exit(self):
        self.fh.write(
            "{0} [{1}] child: parent died (ppid={2})\n".format(
                time.ctime(), self.pid, self.pid_parent
        ))
        self.parent_exit = True

    def init_refresh(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] child: refresh initiated\n".format(
                time.ctime(), self.pid
        ))
        self.do_refresh = True

    def perform_refresh(self):
        self.do_refresh = False
        self.fh.write(
            "{0} [{1}] child: performing refresh\n".format(
                time.ctime(), self.pid
        ))
        self.send('refresh')
        self.config = {}

    def cleanup(self):
        time_secs = (self.pid % 10) + 1
        time_now = time.time()
        self.fh.write(
            "{0} [{1}] child: performing cleanup\n".format(
                time.ctime(), self.pid
        ))
        time.sleep(time_secs)
        self.fh.write(
            "{0} [{1}] child: finished cleanup (t={2}s)\n".format(
                time.ctime(), self.pid, int(time.time() - time_now)
        ))

    def parent_alive(self):
        if os.getppid() == self.pid_parent:
            return(True)
        else:
            self.init_parent_exit()
            return(False)

    def send(self, message):
        if self.parent_alive():
            self.pipe.send(message)

    def process_input(self):
        if not self.pipe.poll():
            return
        try:
            data_read = self.pipe.recv()
            if data_read == 'refresh':
                self.init_refresh()
            elif data_read == 'exit':
                self.init_exit()
            else:
                pass
        except EOFError:
            message = (
                "{0} [{1}] child: error receiving data from parent\n"
            ).format(
                time.ctime(), self.pid
            )
        return

    def start(self):
        self.has_started = True
        pipe_parent, pipe_child = multiprocessing.Pipe()
        pid = os.fork()
        if pid == 0:
            self.init_signals()
            self.pid = os.getpid()
            self.pid_parent = os.getppid()
            self.pipe = pipe_child
            self.open_output()
            try:
                self.main()
            except Exception as e:
                self.fh.write(
                    "{0} [{1}] child: exit details ({2})\n".format(
                        time.ctime(), self.pid, repr(e)
                ))
            finally:
                os._exit(0)
        else:
            self.pid = pid
            self.pipe = pipe_parent

    def main(self):
        self.fh.write(
            "{0} [{1}] child: started\n".format(
                time.ctime(), self.pid
        ))
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
        ))
        self.close_output()
        os._exit(0)

class Parent(object):

    def __init__(self, number_of_children=DEF_NUMBER_OF_CHILDREN):
        self.init_signals()
        self.do_exit = False
        self.do_refresh = False
        self.child_exited = False
        self.children = []

        self.init_children(number_of_children)

    def init_signals(self):
        signal.signal(signal.SIGTERM, self.init_exit)
        signal.signal(signal.SIGHUP, self.init_refresh)
        signal.signal(signal.SIGCHLD, self.catch_child_exit)

    def init_exit(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: exit initiated\n".format(
                time.ctime(), self.get_pid()
        ))
        self.do_exit = True

    def init_children(self, number_of_children=DEF_NUMBER_OF_CHILDREN):
        for n in xrange(number_of_children):
            self.children.append(Child())

    def get_pid(self):\
        return(os.getpid())

    def start_children(self):
        for child in self.children:
            if child.has_started is False:
                child.start()

    def perform_exit(self):
        sys.stderr.write(
            "{0} [{1}] parent: performing exit\n".format(
                time.ctime(), self.get_pid()
        ))
        for child in self.children:
            if not child.has_started:
                continue
            os.kill(child.pid, signal.SIGTERM)
        self.cleanup()

    def init_refresh(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: refresh initiated\n".format(
                time.ctime(), self.get_pid()
        ))
        self.do_refresh = True

    def perform_refresh(self):
        self.do_refresh = False
        sys.stderr.write(
            "{0} [{1}] parent: performing refresh\n".format(
                time.ctime(), self.get_pid()
        ))
        for child in self.children:
            if not child.has_started:
                continue
            os.kill(child.pid, signal.SIGHUP)
        self.config = {}

    def catch_child_exit(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: child exit detected\n".format(
                time.ctime(), self.get_pid()
        ))
        self.child_exited = True

    def process_child_refresh(self, child):
        sys.stderr.write(
            "{0} [{1}] parent: child refresh detected (cpid={2})\n".format(
                time.ctime(), self.get_pid(), child.pid
        ))

    def remove_child(self, child):
        sys.stderr.write(
            "{0} [{1}] parent: processing child exit (cpid={2})\n".format(
                time.ctime(), self.get_pid(), child.pid
        ))
        self.children = filter(lambda c: child.pid != c.pid, self.children)
        sys.stderr.write(
            "{0} [{1}] parent: removed exited child (cpid={2})\n".format(
                time.ctime(), self.get_pid(), child.pid
        ))

    def process_children_exit(self):
        sys.stderr.write(
            "{0} [{1}] parent: processing child exits\n".format(
                time.ctime(), self.get_pid()
        ))
        for child in self.children:
            self.process_child_exit(child)

    def process_child_exit(self, child):
        self.child_exited = False

        sys.stderr.write(
            "{0} [{1}] parent: determining child status (cpid={2})\n".format(
                time.ctime(), self.get_pid(), child.pid
        ))

        if child.pipe.closed:
            self.remove_child(child)
        else:
            (pid_wait, status) = os.waitpid(child.pid, os.WNOHANG)
            if pid_wait:
                self.remove_child(child)

    def cleanup(self):
        time_secs = (self.get_pid() % 10) + 1
        time_now = time.time()
        sys.stderr.write(
            "{0} [{1}] parent: performing cleanup\n".format(
                time.ctime(), self.get_pid()
        ))
        # Do cool stuff here ...
        time.sleep(time_secs)
        sys.stderr.write(
            "{0} [{1}] parent: finished cleanup (t={2}s)\n".format(
                time.ctime(), self.get_pid(), int(time.time() - time_now)
        ))

    def process_input(self):
        for child in self.children:
            self.process_child_input(child)

    def process_child_input(self, child):
        if child.pipe.closed:
            self.process_child_exit(child)
        if not child.pipe.poll():
            return
        try:
            data_read = child.pipe.recv()
            if data_read == 'refresh':
                self.process_child_refresh(child)
            elif data_read == 'exit':
                self.process_child_exit(child)
        except EOFError:
            message = (
                "{0} [{1}] parent: error receiving data from child " + 
                "(cpid={2})\n"
            ).format(
                time.ctime(), self.get_pid(), child.pid
            )
        return

    def start(self):
        sys.stderr.write(
            "{0} [{1}] parent: started\n".format(
                time.ctime(), self.get_pid()
        ))
        self.start_children()
        self.main()

    def main(self):

        while (
            len(self.children) > 0 and
            not self.do_exit
        ):
            if not int(time.time() + self.get_pid()) % 10:
                sys.stderr.write((
                    "{0} [{1}] parent: process is running " +
                    "(children={2})\n"
                ).format(
                    time.ctime(), self.get_pid(), len(self.children)
                ))

            self.process_input()

            if self.child_exited:
                self.process_children_exit()

            if self.do_refresh:
                self.perform_refresh()

            time.sleep(1)

        if self.do_exit:
            self.perform_exit()

        while len(self.children) > 0:
            sys.stderr.write(
                "{0} [{1}] parent: waiting for children to exit\n".format(
                    time.ctime(), self.get_pid()
            ))
            self.process_children_exit()
            time.sleep(1)

        sys.stderr.write(
            "{0} [{1}] parent: all children have exited\n".format(
                time.ctime(), self.get_pid()
        ))
        sys.stderr.write(
            "{0} [{1}] parent: will exit now\n".format(
                time.ctime(), self.get_pid()
        ))
        sys.exit(0)


def get_context(parent, file_pid=DEF_FILE_PID):
    return(daemon.DaemonContext(
        pidfile = pidfile.PidFile(file_pid),
        umask = 0o077,
        signal_map = {
            signal.SIGTERM: parent.init_exit
        },
        stdout = sys.stdout,
        stderr = sys.stderr
    ))

def main():
    parent = Parent()

    with get_context(parent):
        parent.start()

if __name__ == '__main__':
    main()
