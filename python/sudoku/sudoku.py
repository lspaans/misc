#!/usr/bin/env python

import os

DEF_GRID_BASE = 3

class Cell(object):
    def __init__(self, value=None, maxValue=DEF_GRID_BASE ** 2, options=[]):
        self.maxValue = maxValue
        self.allOptions = range(1, maxValue + 1)
        self.options = self.allOptions
        self.value = value

    @property
    def maxValue(self):
        return self.__maxValue

    @property
    def options(self):
        return tuple(self.__options)

    @property
    def value(self):
        return self.__value

    @maxValue.setter
    def maxValue(self, maxValue):
        self.__maxValue = maxValue

    @options.setter
    def options(self, options=[]):
        self.__options = set(options)

    def delOptions(self, options=[]):
       self.options = tuple(set(self.options) - set(options))

    @value.setter
    def value(self, value=None):
        if value in self.options:
            self.__value, self.options = value, [value]
        elif value is None:
            self.__value = None 
            self.options = self.allOptions
        else:
            raise ValueError("Invalid value")

class Tile(object):
    def __init__(self, values=[], maxCells=DEF_GRID_BASE ** 2):
        self.__maxCells = maxCells
        self.cells = values

    @property
    def cells(self):
        return self.__cells

    @cells.setter
    def cells(self, values=None):
        if values is None or len(values) == 0:
            values = range(1, self.__maxCells + 1)

        if len(set(values)) != self.__maxCells and set(values) != set([None]):
            raise ValueError("Non-unique or invalid number of values")

        self.__cells = map(lambda v: Cell(v), values)

class Board(object):
    def __init__(self, gridBase=DEF_GRID_BASE):
        pass

class Game(object):
    def __init__(self, gridBase=DEF_GRID_BASE):
        pass

if __name__ == '__main__':
    os.system('clear')
    t = Tile()
    for n, c in enumerate(t.cells,1):
        print "Cell={0}, value={1}, options={2}".format(n, c.value, c.options)
