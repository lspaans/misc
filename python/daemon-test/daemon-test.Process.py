#!/usr/bin/env python

from multiprocessing import Process, Pipe
import daemon
import os
import pidfile
import random
import time
import signal
import sys

DEF_NUMBER_OF_CHILDREN = 10
DEF_FILE_PID = "/tmp/daemon-test.pid"

class Child(Process):
    
    def __init__(
        self, id, pipe, *args, **kwargs
    ):
        super(Child, self).__init__(*args, **kwargs)
        self.do_exit = False
        self.id = id
        self.pipe = pipe

        self.init_signals()

    def init_signals(self):
        signal.signal(signal.SIGTERM, self.init_exit)

    def main(self):
        while not self.do_exit:
            time.sleep(1)
            self.communicate()

    def run(self):
        self.main()

    def communicate(self):
        self.process_output()
        self.process_input()

    def process_output(self):
        if random.choice(xrange(10)) == 0:
            self.send("time = {0}".format(time.time()))

    def process_input(self):
        if self.poll():
            sys.stderr.write(
                "child[{0}] received '{1}' from parent\n".format(
                    self.name, repr(self.receive())
            ))

    def poll(self):
        return(self.pipe.poll())

    def send(self, object):
        self.pipe.send(object)

    def receive(self):
        return(self.pipe.recv())

    def init_exit(self, signal_no=0, strack_frame=None):
        self.do_exit = 1

class Parent(Process):

    def __init__(
        self, number_of_children=DEF_NUMBER_OF_CHILDREN, *args, **kwargs
    ):
        super(Parent, self).__init__(*args, **kwargs)
        self.do_exit = False

        self.init_signals()
        self.init_children(number_of_children)

    def init_signals(self):
        signal.signal(signal.SIGTERM, self.init_exit)
        signal.signal(signal.SIGCHLD, self.catch_child_exit)

    def init_children(self, number_of_children=DEF_NUMBER_OF_CHILDREN):
        self.child_exited = False
        self.number_of_children = number_of_children
        self.children = {}

        for n in xrange(self.number_of_children):
            pipe_parent, pipe_child = Pipe()
            self.children[n+1] = {
                'child': Child(n+1, pipe_child),
                'pipe': pipe_parent
            }

        self.start_children()

    def run(self):
#        self.start_children()
        self.main()

    def main(self):
        while not self.do_exit:
            time.sleep(1)
            self.communicate()
        return()

    def communicate(self):
        for id in self.children:
            self.process_output(id)
            self.process_input(id)

    def process_output(self, id):
        if self.get_pipe(id).poll():
            sys.stderr.write(
                "parent received '{0}' from child '{1}'\n".format(
                    repr(self.get_child(id).receive()), id
            ))

    def process_input(self, id):
        if random.choice(xrange(10)) == 0:
            self.get_pipe(id).send("time = {0}".format(time.time()))

    def get_child(self, id):
        return(self.children[id]['child'])

    def get_pipe(self, id):
        return(self.children[id]['pipe'])

    def start_children(self):
        for id in self.children:
            self.get_child(id).start()

    def init_exit(self, signal_no=0, strack_frame=None):
        self.do_exit = 1

    def catch_child_exit(self, signal_no=0, strack_frame=None):
        self.child_exited = 1

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

    time.sleep(10)

    with get_context(parent):
        parent.start()

if __name__ == '__main__':
    main()
