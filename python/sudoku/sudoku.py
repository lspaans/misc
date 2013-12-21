#!/usr/bin/env python

import os

DEF_GRID_BASE = 3

class Cell(object):
    def __init__(self, value=None, maxValue=DEF_GRID_BASE ** 2, options=[]):
        self.setMaxValue(maxValue)
        self.setOptions(options)
        self.setValue(value)

    def clear(self):
        self.setOptions()
        self.setValue()

    def getMaxValue(self):
        return self.maxValue

    def getOptions(self):
        return self.options

    def getValue(self):
        return self.value

    def unsetOptions(self, options=[]):
        self.options -= set(options)

    def setMaxValue(self, maxValue):
        self.maxValue = maxValue

    def setOptions(self, options=[]):
        self.options = set(options)

    def setValue(self, value=None):
        if value in self.options:
            self.value = value
            self.setOptions([])
        elif value is None:
            self.value = value
            self.setOptions(range(1, self.maxValue + 1))
        else:
            raise Exception("Invalid value")

class Tile(object):
    def __init__(self, values=[], maxCells=DEF_GRID_BASE ** 2):

        self.cells = map(lambda n: Cell(), range(1, maxCells + 1))
        self.maxCells = maxCells

        if len(values) == 0:
            pass
        elif len(set(values)) == maxCells:
            pass
        else:
            raise Exception("Invalid number of values")

    def getCell(self, n):
        if 0 < n <= len(self.cells):
            return self.cells[n-1]
        else:
            raise Exception("Invalid cell number")

    def getCells(self, l=None):
        if l is None:
            l = range(1, self.maxCells + 1)
        return map(lambda n: self.getCell(n), l)

class Board(object):
    def __init__(self, gridBase=DEF_GRID_BASE):
        pass

class Game(object):
    def __init__(self, gridBase=DEF_GRID_BASE):
        pass

if __name__ == '__main__':
    os.system('clear')
    t = Tile()
    cells = t.getCells()
    for c in cells:
        print c.getOptions()

