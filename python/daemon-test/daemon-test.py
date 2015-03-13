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

DEF_NUMBER_OF_CHILDREN = 3
DEF_FILE_PID = "/tmp/daemon-test.pid"

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
        ))
        self.do_exit = True

    def init_signals(self):
        signal.signal(signal.SIGTERM, self.init_exit)                       
        signal.signal(signal.SIGHUP, self.init_refresh) 

    def perform_exit(self):
        self.fh.write(
            "{0} [{1}] child: performing exit\n".format(
                time.ctime(), self.pid
        ))
        self.pipe.send('exit')
        self.cleanup()

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
        self.pipe.send('refresh')
        self.config = {}

    def cleanup(self):
        time_secs = (self.pid % 10) + 1
        time_now = time.time()
        self.fh.write(
            "{0} [{1}] child: performing cleanup\n".format(
                time.ctime(), self.pid
        ))
        # Do cool stuff here ...
        #time.sleep(time_secs)
        self.fh.write(
            "{0} [{1}] child: finished cleanup [t={2}s]\n".format(
                time.ctime(), self.pid, int(time.time() - time_now)
        ))

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
            self.pipe = pipe_child
            self.open_output()
            try:
                self.main()
            except Exception as e:
                self.fh.write(
                    "{0} [{1}] child: exit details ('{2}')\n".format(
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
        self.pid = os.getpid()

        self.init_children(number_of_children)

    def init_signals(self):
        signal.signal(signal.SIGTERM, self.init_exit)
        signal.signal(signal.SIGHUP, self.init_refresh)
        signal.signal(signal.SIGCHLD, self.catch_child_exit)

    def init_exit(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: exit initiated\n".format(
                time.ctime(), self.pid
        ))
        self.do_exit = True

    def init_children(self, number_of_children=DEF_NUMBER_OF_CHILDREN):
        for n in xrange(number_of_children):
            self.children.append(Child())

    def start_children(self):
        for child in self.children:
            if child.has_started is False:
                child.start()

    def perform_exit(self):
        sys.stderr.write(
            "{0} [{1}] parent: performing exit\n".format(
                time.ctime(), self.pid
        ))
        for child in self.children:
            if not child.has_started:
                continue
            os.kill(child.pid, signal.SIGTERM)
        self.cleanup()

    def init_refresh(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: refresh initiated\n".format(
                time.ctime(), self.pid
        ))
        self.do_refresh = True

    def perform_refresh(self):
        self.do_refresh = False
        sys.stderr.write(
            "{0} [{1}] parent: performing refresh\n".format(
                time.ctime(), self.pid
        ))
        for child in self.children:
            if not child.has_started:
                continue
            os.kill(child.pid, signal.SIGHUP)
        self.config = {}

    def catch_child_exit(self, signal_no=0, stack_frame=None):
        sys.stderr.write(
            "{0} [{1}] parent: child exit detected\n".format(
                time.ctime(), self.pid
        ))
        self.child_exited = True

    def process_child_refresh(self, child):
        sys.stderr.write(
            "{0} [{1}] parent: child refresh detected ({2})\n".format(
                time.ctime(), self.pid, child.pid
        ))

    def process_child_exit(self, child_in=None):
        self.child_exited = False
        remaining_children = []
        children = []
        pids_exit = []
        sys.stderr.write(
            "{0} [{1}] parent: processing child exit(s)\n".format(
                time.ctime(), self.pid
        ))

        if child_in is None:
            sys.stderr.write("HOPLA!\n")
            children = self.children
        else:
            sys.stderr.write("WOEI!\n")
            children = [child_in,]

        for child in children:
            sys.stderr.write(
                "{0} [{1}] parent: determining child status ({2})\n".format(
                    time.ctime(), self.pid, child.pid
            ))

            if child.pipe.closed:
                pid_exit.append(child.pid)
                continue
                
            if not child.pipe.poll():
                continue

            try:
                message = (
                    "{0} [{1}] PRE: parent: child did not exit properly: " + 
                    "'{2}'\n"
                ).format(
                    time.ctime(), self.pid, child.pid
                )
                data_read = child.pipe.recv().rstrip()
                sys.stderr.write(
                    "{0} [{1}] PRE: parent: read from child: '{2}'\n".format(
                        time.ctime(), self.pid, repr(data_read)
                ))
            except EOFError:
                sys.stderr.write(message)
                pids_exit.append(child.pid)
                continue

            if not instanceof(data_read, int):
                continue

# HIER MOET DE BEVESTIGING WORDEN TERUGGESTUURD NAAR DE CHILD

            (pid_wait, status) = os.waitpid(data_read, os.WNOHANG)
            if pid_wait:
                sys.stderr.write(
                    "{0} [{1}] parent: processing child exit ({2})\n".format(
                        time.ctime(), self.pid, pid_wait
                ))
                pids_exit.append(pid_wait)

        for child in self.children:
            if not child.pid in pids_exit:
                remaining_children.append(child)

        self.children = remaining_children

    def cleanup(self):
        time_secs = (self.pid % 10) + 1
        time_now = time.time()
        sys.stderr.write(
            "{0} [{1}] parent: performing cleanup\n".format(
                time.ctime(), self.pid
        ))
        # Do cool stuff here ...
        time.sleep(time_secs)
        sys.stderr.write(
            "{0} [{1}] parent: finished cleanup [t={2}s]\n".format(
                time.ctime(), self.pid, int(time.time() - time_now)
        ))

    def process_input(self):
        for child in self.children:
            self.process_child_input(child)

    def process_child_input(self, child):
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
                "{0} [{1}] parent: error receiving data from child '{2}\n"
            ).format(
                time.ctime(), self.pid, child.pid
            )
        return

    def start(self):
        sys.stderr.write(
            "{0} [{1}] parent: started\n".format(
                time.ctime(), self.pid
        ))
        self.start_children()
        self.main()

    def main(self):

        while (
            len(self.children) > 0 and
            not self.do_exit
        ):
            if not int(time.time() + self.pid) % 10:
                sys.stderr.write((
                    "{0} [{1}] parent: process is running " +
                    "(children={2})\n"
                ).format(
                    time.ctime(), self.pid, len(self.children)
                ))

            self.process_input()

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
        ))
        sys.stderr.write(
            "{0} [{1}] parent: will exit now\n".format(
                time.ctime(), self.pid
        ))
        sys.exit(0)

def get_validated_file(file_name):
    if not os.path.exists(file_name):
        return(file_name)
    raise ValueError(
        "{0} [{1}] parent: file '{2}' already exists\n".format(
            time.ctime(), os.getpid(), file_name
        ))

def get_context(parent, file_pid=DEF_FILE_PID):
    return(daemon.DaemonContext(
        pidfile = pidfile.PidFile(get_validated_file(file_pid)),
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
