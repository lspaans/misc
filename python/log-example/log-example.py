#!/usr/bin/env python

import logging
import os
import sys
import time

from logging.handlers import SysLogHandler

MODULE_NAME = os.path.splitext(os.path.basename(sys.argv[0]))[0]

class Ding(object):

    def log(self, level, message):
        self.logger.log(level, message, extra=self.logger_extra)

    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.logger_extra = {
            'custModule': 'Foo',
            'fooName': 'Bar'
        }

    def start(self):
        for n in xrange(10):
            self.log(
                logging.INFO,
                "[{0}] This is pretty {1}".format(n,"cool"),
            )
            time.sleep(1)


def init_logger():
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)
    syslog = SysLogHandler(
        address='/dev/log',
        facility=SysLogHandler.LOG_DAEMON
    )
    log_format = (                                                              
        "%(custModule)s[%(process)d] (%(fooName)s): " +
        "%(levelname)s: %(message)s"                                            
    )                                                                           
    formatter = logging.Formatter(log_format)
    syslog.setFormatter(formatter)
    logger.addHandler(syslog)

if __name__ == '__main__':
    init_logger()
    d = Ding()
    d.start()
