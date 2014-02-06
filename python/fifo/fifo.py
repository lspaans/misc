#!/usr/bin/env python

import atexit
import os
import sys
import select
import time

PIPE_READ_TIMEOUT = 10

file_fifo = "./fifo.stdin"

@atexit.register
def cleanup():
    try:
        os.unlink(file_fifo)
    except:
        pass

if os.path.exists(file_fifo):
    sys.stderr.write("ERROR: <...>")
    exit(1)


def main():
    fh_fifo = os.mkfifo(file_fifo, 0644)

    with open(file_fifo) as fifo:
        while True:
            ready = select.select([fifo], [], [], PIPE_READ_TIMEOUT)
            if ready[0]:
                line = fifo.read()
                sys.stdout.write("{0} {1}\n".format(time.ctime(), repr(line)))

if __name__ == '__main__':
    main()
