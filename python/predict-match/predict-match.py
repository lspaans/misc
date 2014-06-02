#!/usr/bin/env python

import random

class Coin(object):
    def __init__(self, chanceHeads=0.5):
        self.setChanceHeads(chanceHeads)
        self.toss()

    def toss(self):
        self.headsUp = random.random() < self.chanceHeads

    def heads(self):
        return self.headsUp

    def tails(self):
        return not self.headsUp

    def setChanceHeads(self, chanceHeads):
        self.chanceHeads = chanceHeads

    def __str__(self):
        return("heads" if self.heads() else "tails")

class Match(object):
    def __init__(self, parties, chanceHeads=0.5):
        self.score = {p: 0 for p in parties}
        self.chanceHeads = chanceHeads
        self._predictScore()

    def _predictScore(self):
        for p in self.score:
            self.score[p] = self._getNumberOfHeads()

    def _getNumberOfHeads(self):
        c = Coin(self.chanceHeads)
        tosses = 0
        while c.heads():
            tosses += 1
            c.setChanceHeads(1.0/(tosses+2))
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
