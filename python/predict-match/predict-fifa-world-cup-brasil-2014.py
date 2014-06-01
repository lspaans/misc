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
        # Group Matches
        ['bra', 'cro'], ['mex', 'cmr'], ['esp', 'ned'], ['chi', 'aus'],
        ['col', 'gre'], ['civ', 'jpn'], ['uru', 'crc'], ['eng', 'ita'],
        ['sui', 'ecu'], ['fra', 'hon'], ['arg', 'bih'], ['irn', 'nga'],
        ['ger', 'por'], ['gha', 'usa'], ['bel', 'alg'], ['rus', 'kor'],
        ['bra', 'mex'], ['cmr', 'cro'], ['esp', 'chi'], ['aus', 'ned'],
        ['col', 'civ'], ['jpn', 'gre'], ['uru', 'eng'], ['ita', 'crc'],
        ['sui', 'fra'], ['hon', 'ecu'], ['arg', 'irn'], ['nga', 'bih'],
        ['ger', 'gha'], ['usa', 'por'], ['bel', 'rus'], ['kor', 'alg'],
        ['cmr', 'bra'], ['cro', 'mex'], ['aus', 'esp'], ['ned', 'chi'],
        ['jpn', 'col'], ['gre', 'civ'], ['ita', 'uru'], ['crc', 'eng'],
        ['hon', 'sui'], ['ecu', 'fra'], ['nga', 'arg'], ['bih', 'irn'],
        ['usa', 'ger'], ['por', 'gha'], ['kor', 'bel'], ['alg', 'rus'],
        # Round of 16
        ['1a', '2b'],   ['1c', '2d'],   ['1b', '2a'],   ['1d', '2c'],
        ['1e', '2f'],   ['1g', '2h'],   ['1h', '2g'],   ['1f', '2e'],
        # Quarter-Finals
        ['w49', 'w50'], ['w53', 'w54'], ['w55', 'w56'], ['w51', 'w52'],
        # Semi-Finals
        ['w57', 'w58'], ['w59', 'w60'],
        # 3rd Place and Final
        ['l61', 'l62'], ['w61', 'w62']
    ]
    for match in matches:
        m = Match(match)
        print(m)
