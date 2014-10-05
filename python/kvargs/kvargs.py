#!/usr/bin/env python

def zut(x, y, *vargs, **kvargs):
    print(repr(vargs))
    print(repr(kvargs))

def main():
    a, b = 2, 3
    zut(a, b, 4, c=1)

if __name__ == '__main__':
    main()
