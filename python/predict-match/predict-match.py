#!/usr/bin/env python

import random

class Coin(object):
    def __init__(self, chanceHeads=1, chanceTails=1):
        self.chanceHeads, self.chanceTails = chanceHeads, chanceTails
        self.toss()

    def toss(self):
        self.headsUp = random.randrange(
            self.chanceHeads + self.chanceTails
        ) < self.chanceHeads

    def heads(self):
        return self.headsUp

    def tails(self):
        return not self.headsUp

    def __str__(self):
        return("heads" if self.heads() else "tails")

class Match(object):
    def __init__(self, parties):
        self.score = {p: 0 for p in parties}
        self._predictScore()

    def _predictScore(self):
        for v in xrange(self._getNumberOfHeads()):
            self.score[random.choice(self.score.keys())] += 1

    def _getNumberOfHeads(self):
        c = Coin()
        tosses = 0
        while c.heads():
            tosses += 1
            c.toss()
        return(tosses)

    def __str__(self):
        return "{0} : {1}".format(
            " - ".join(self.score.keys()),
            " - ".join(map(lambda i: str(i), self.score.values()))
        )

if __name__ == '__main__':
    matches = [
        ['ned', 'gha']
    ]
    for match in matches:
        m = Match(match)
        print(m)
