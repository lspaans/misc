#!/usr/bin/env python

import time
import random

def do(n=0.5):
    if random.choice([True, False]):
        time.sleep(1)
        do(n/2)
    else:
        print("n={0}".format(n))

if __name__ == '__main__':
    do()
