#!/usr/bin/env python3

import random
import sys
from datetime import datetime, timedelta


def get_random_birthday():
    time_start = datetime.fromtimestamp(0)
    time_end = datetime.utcnow()
    time_birth = time_start + timedelta(
        seconds=random.randint(0, int((time_end - time_start).total_seconds()))
    )
    return (time_birth.month, time_birth.day)


def get_collision_iteration(func):
    results = set()
    iteration = 0
    while True:
        iteration += 1
        result = func()
        if result in results:
            break
        results.add(result)
    return iteration


def main():
    results = []
    try:
        while True:
            results.append(get_collision_iteration(get_random_birthday))
            sys.stdout.write(
                f"iteration: {len(results)}, "
                f"avg. birthdays before collision: {sum(results)/len(results)}"
                f"\r"
            )
    except KeyboardInterrupt:
        print("\n")


if __name__ == "__main__":
    sys.exit(main())
