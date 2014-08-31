#!/usr/bin/env python

def fib(n,i=0,j=1):
    if n > 0:
        return(fib(n-1,j,i+j))
    return(j)

def fibgen(n):
    i, j = 0, 1
    while n:
        yield(j)
        i, j = j, i+j
        n -= 1

if __name__ == '__main__':
    print(",".join(map(lambda n:str(n), fibgen(9))))
    print(fib(9))
