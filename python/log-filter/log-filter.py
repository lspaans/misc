#!/usr/bin/env python
# encoding: UTF-8

"""
A Python script that filters log files by means of a named pipe (FIFO)
and which takes action if applicable.
"""

__author__ = "Léon Spans"

import ConfigParser

import argparse
import atexit
import contextlib
import daemon
import datetime
import os
import pidfile
import select
import signal
import sys
import time

MODULE_NAME     = os.path.splitext(os.path.basename(sys.argv[0]))[0]

DEF_PATH_ROOT   = "/"
DEF_PATH_CFG    = os.path.join(DEF_PATH_ROOT, "etc")
DEF_PATH_VAR    = os.path.join(DEF_PATH_ROOT, "var")
DEF_PATH_LOG    = os.path.join(DEF_PATH_VAR, "log")
DEF_PATH_RUN    = os.path.join(DEF_PATH_VAR, "run")

FILE_CFG        = os.path.join(
    DEF_PATH_CFG, "{0}.{1}".format(MODULE_NAME, "conf")
)
FILE_STDERR     = os.path.join(
    DEF_PATH_LOG, "{0}-stderr.log".format(MODULE_NAME)
)
FILE_STDOUT     = os.path.join(
    DEF_PATH_LOG, "{0}-stdout.log".format(MODULE_NAME)
)
FILE_PID        = os.path.join(
    DEF_PATH_RUN, "{0}.pid".format(MODULE_NAME)
)

PATH_INCLUDE    = os.path.join(
    DEF_PATH_CFG, "{0}.d".format(MODULE_NAME)
)
PATH_PIPE       = os.path.join(
    DEF_PATH_RUN, MODULE_NAME
)
PATH_ROOT       = DEF_PATH_ROOT

CHECK_CONTROLLER_INTERVAL = 60
PIPE_TIMEOUT_INTERVAL = 1

DEF_VALUES      = {
    "main": {
        "include_path": PATH_INCLUDE,
        "pipe_path": PATH_PIPE,
        "root_path": PATH_ROOT,
        "pid_file": FILE_PID,
        "stderr_file": FILE_STDERR,
        "stdout_file": FILE_STDOUT,
        "check_controller_interval": CHECK_CONTROLLER_INTERVAL,
        "pipe_timeout_interval": PIPE_TIMEOUT_INTERVAL
    }
}

def get_arguments():
    parser = argparse.ArgumentParser(
        description="A Python script that filters log files " +
            "by means of a named pipe (FIFO) and which takes action if " +
            "applicable."
    )
    parser.add_argument( "-f", "--config-file",
        metavar="FILE", nargs="?", default=FILE_CFG,
        dest="file_cfg", help="a non-default " +
            "(i.e. {0}) config file".format(FILE_CFG)
    )
    args = parser.parse_args()
    return args

def read_config(args, def_values={}):
    config = ConfigParser.RawConfigParser()
    for section in def_values:
        config.add_section(section)
        for option in def_values[section]:
            config.set(section, option, def_values[section][option])
    files_parsed = config.read(os.path.expandvars(args.file_cfg))
    if len(files_parsed) < 1:
        msg = (
            "{0} ERROR: Cannot parse config file (file='{1}')"
        ).format(time.ctime(), args.file_cfg)
        raise Exception(msg)
    return config

def read_log_filter_configs(include_path, names=[]):
    log_filter_configs = {}
    for (dirpath, dirs, filenames) in os.walk(include_path):
        for filename in filenames:
            if len(names) != 0 and not filename in names:
                continue
            with open(os.path.join(dirpath, filename), "r") as f:
                log_filter_config = ConfigParser.RawConfigParser()
                log_filter_config.add_section(filename)
                for config_entry in f:
                    if not "=" in config_entry:
                        continue
                    option, value = config_entry.split("=", 1)
                    log_filter_config.set(filename, option, value)
                log_filter_configs.update({filename: log_filter_config})
    return log_filter_configs

class LogFilter(object):
    def __init__(self, name, args, config, log_filter_config):
        self.do_refresh_config = True
        self.do_exit = False

        self.name = name
        self.args = args
        self.config = config
        self.log_filter_config = log_filter_config

    def start(self):
        pid = os.fork()

        if pid == 0:
            signal.signal(signal.SIGTERM, self.init_exit)
            signal.signal(signal.SIGHUP, self.init_refresh_config)
            self.pid = os.getpid()
            try:
                self.main()
            except Exception as e:
                sys.stderr.write(
                    (
                        "{0} ERROR: LogFilter unexpectedly exited " + 
                        "(name='{1}';error='{2}')\n"
                    ).format(time.ctime(), self.name, repr(e))
                )
            finally:
                os._exit(0)
        else:
            self.pid = pid

    def main(self):

        self.ppid = os.getppid()
        self.pipe_file = None
        self.pipe_fh = None

        time_check_controller_existence = time.time()

        while not self.do_exit:
            sys.stderr.write(
                (
                    "{0} DEBUG: loop (name='{1}')\n"
                ).format(time.ctime(), self.name)
            )
            if self.do_refresh_config:
                sys.stderr.write(
                    (
                        "{0} DEBUG: do_refresh_config (name='{1}')\n"
                    ).format(time.ctime(), self.name)
                )
                self.perform_refresh_config()

            if time.time() > time_check_controller_existence:
                self.check_controller_existence()
                time_check_controller_existence += self.config.get(
                    "main", "check_controller_interval"
                )

            ready = select.select(
                [self.pipe_fh], [], [],
                self.config.get("main", "pipe_timeout_interval")
            )

            if ready[0]:
                line_in = os.read(self.pipe_fh, select.PIPE_BUF)
                if len(line_in) > 0:
                    sys.stderr.write(
                        (
                            "{0} DEBUG: data received " +
                            "(name='{1}';data='{2}')\n"
                        ).format(time.ctime(), self.name, repr(line_in))
                    )
                else:
                    self.open_pipe(self.pipe_file)

        self.perform_exit()

    def check_controller_existence(self):
        if self.ppid != os.getppid():
            self.do_exit = True

    def perform_cleanup(self):
        self.close_pipe(self.pipe_file)

    def init_refresh_config(self, signal_number=0, stack_frame=None):
        self.do_refresh_config = True

    def perform_refresh_config(self):
        sys.stderr.write(
            (
                "{0} DEBUG: perform_refresh_config " + 
                "(name='{0}';pipe_file='{1}')\n"
            ).format(
                time.ctime(), self.name, repr(self.pipe_file)
            )
        )
        self.config = read_config(self.args, DEF_VALUES)
        self.log_filter_configs = read_log_filter_configs(
            self.config.get("main", "include_path"), [self.name]
        )
        pipe_file = os.path.join(
            self.config.get("main", "pipe_path"), self.name
        )
        if self.pipe_file != pipe_file:
            try:
                self.open_pipe(pipe_file)
            except:
                self.do_exit = True

        self.do_refresh_config = False

    def init_exit(self, signal_number=0, stack_frame=None):
        self.do_exit = True

    def perform_exit(self):
        self.perform_cleanup()

    def open_pipe(self, pipe_file):

        sys.stderr.write(
            "{0} DEBUG: open_pipe (pipe_file='{1}')\n".format(
                time.ctime(), pipe_file
            )
        )

        if pipe_file != self.pipe_file:
            try:
                os.mkfifo(pipe_file, 0644)
            except:
                sys.stderr.write(
                    (
                        "{0} ERROR: Cannot create pipe (pipe='{1}')\n"
                    ).format(
                        time.ctime(), pipe_file
                    )
                )
                raise


        try:
            pipe_fh = os.open(pipe_file, os.O_RDONLY|os.O_NONBLOCK)
        except Exception as e:
            sys.stderr.write(
                (
                    "{0} ERROR: Cannot open pipe for reading " +
                    "(pipe='{1}')\n"
                ).format(
                    time.ctime(), pipe_file
                )
            )
            raise

        if not self.pipe_file is None:
            self.close_pipe(self.pipe_file)

        self.pipe_file = pipe_file
        self.pipe_fh = pipe_fh

    def close_pipe(self, pipe_file):
        os.unlink(pipe_file)

class LogFilterController(object):
    def __init__(self, args, config, log_filter_configs):
        self.do_refresh_config = True
        self.log_filter_exited = False
        self.do_exit = False

        self.args = args
        self.config = config
        self.log_filter_configs = log_filter_configs

        self.log_filters = {}

    def start(self):

        while not self.do_exit:

            if self.do_refresh_config:
                self.perform_refresh_config()

            time.sleep(1)

        self.perform_exit()

        while len(self.log_filters) > 0:
            self.process_log_filter_exit()
            time.sleep(1)

    def perform_cleanup(self):
        pass

    def init_log_filters(self):
        # Determine which LogFilter-children should be created
        for name in (
                set(self.log_filter_configs.keys()) - set(
                    self.log_filters.keys()
                )
            ):
            log_filter = LogFilter(
                name, self.args, self.config, self.log_filter_configs[name]
            )
            log_filter.start()
            self.log_filters[name] = log_filter
        # Determine which LogFilter-children should  became obsolete
        for name in (
            set(self.log_filters.keys()) - set(self.log_filter_configs.keys())
        ):
            os.kill(self.log_filters[name].pid, signal.SIGTERM)

    def init_refresh_config(self, signal_number=0, stack_frame=None):
        self.do_refresh_config = True

    def perform_refresh_config(self):
        self.config = read_config(self.args, DEF_VALUES)
        self.log_filter_configs = read_log_filter_configs(
            config.get("main", "include_path")
        )
        self.init_log_filters()
        for name in self.log_filters:
            os.kill(self.log_filters[name].pid, signal.SIGHUP)
        self.do_refresh_config = False

    def catch_log_filter_exit(self, signal_number=0, stack_frame=None):
        self.log_filter_exited = True

    def process_log_filter_exit(self):
        for name in self.log_filters.keys():
            ret = os.waitpid(self.log_filters[name].pid, os.WNOHANG)
            if ret[0] != 0:
                sys.stderr.write(
                    (
                        "{0} WARNING: LogFilter exited " +
                        "(name='{1}';pid='{2}')\n"
                    ).format(
                        time.ctime(), name, self.log_filters[name].pid
                    )
                )
                self.log_filters.pop(name)
        self.log_filter_exited = False
        if not self.do_exit:
            self.init_log_filters()

    def init_exit(self, signal_number=0, stack_frame=None):
        self.do_exit = True

    def perform_exit(self):
        for name in self.log_filters:
            os.kill(self.log_filters[name].pid, signal.SIGTERM)
        self.perform_cleanup()


if __name__ == "__main__":
    args = get_arguments()

    config = read_config(args, DEF_VALUES)
    log_filter_configs = read_log_filter_configs(
        config.get("main", "include_path")
    )

    if os.path.exists(config.get("main", "pid_file")):
        raise Exception(
            "PID file still exists: '{0}'".format(
                config.get("main", "pid_file")
            )
        )

    lfc = LogFilterController(args, config, log_filter_configs)

    try:
        fh_pid = pidfile.PidFile(config.get("main", "pid_file"))
    except Exception as e:
        raise

    with contextlib.nested(
        open(config.get("main", "stdout_file"), "a"),
        open(config.get("main", "stderr_file"), "a")
    ) as (fh_stdout, fh_stderr):

        context = daemon.DaemonContext(
            pidfile = fh_pid,
            signal_map = {
                signal.SIGCHLD: lfc.catch_log_filter_exit,
                signal.SIGHUP: lfc.init_refresh_config,
                signal.SIGTERM: lfc.init_exit
            },
            stderr = fh_stderr,
            stdout = fh_stdout,
            umask = 0x077,
            working_directory = config.get("main", "root_path")
#            ,detach_process = False
        )

        with context:
            lfc.start()
