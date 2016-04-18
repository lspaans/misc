#!/usr/bin/env python

import os
import re
import sys

META_STATISTICS = {
    "alphanumeric characters": re.compile(r"[a-z0-9]", re.I),
    "characters": re.compile(r"."),
    "consonants": re.compile(r"[bcdfghjklmnpqrstvwxz]", re.I),
    "digits": re.compile(r"\d"),
    "functions": re.compile(r"^def "),
    "lines": re.compile(r"^.*$"),
    "lower case characters": re.compile(r"[a-z]"),
    "non-alphanumeric characters": re.compile(r"[^a-z0-9]", re.I),
    "upper case characters": re.compile(r"[A-Z]"),
    "vowels": re.compile(r"[aeiouy]", re.I)
}


def get_file_contents(file):
    with open(file, 'r') as f:
        return(f.readlines())
    return([])


def get_init_statistics(meta=META_STATISTICS):
    statistics = {}
    for key in meta:
        statistics[key] = 0
    return(statistics)


def get_statistics(contents, meta=META_STATISTICS):
    statistics = get_init_statistics(meta)
    for line in contents:
        for key, regex in meta.items():
            statistics[key] += len(re.findall(regex, line))
    return(statistics)


def get_statistics_text(statistics):
    lines = []
    for key, value in statistics.items():
        lines.append("{0} = {1}".format(key, value))
    return(lines)


def loop_statistics(file_contents):
    contents = file_contents
    try:
        while True:
            statistics_text = get_statistics_text(get_statistics(contents))
            show_statistics(statistics_text)
            contents = statistics_text
    except KeyboardInterrupt as e:
        print("\nScript interrupted")


def main():
    loop_statistics(get_file_contents(sys.argv[0]))


def show_statistics(lines):
    os.system('clear')
    for line in lines:
        print(line)
    raw_input("[Enter]")


if __name__ == '__main__':
    main()
