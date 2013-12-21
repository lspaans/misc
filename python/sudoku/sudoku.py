#!/usr/bin/env python

import os

DEF_GRID_BASE = 3

class Cell(object):
    def __init__(self, value=None, maxValue=DEF_GRID_BASE ** 2, options=[]):
        self.setMaxValue(gridBase)
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

    def unsetOption(self, option): 
        if option in self.options:
            self.options.remove(option)
        elif not option in self.options:
            raise Exception("Non-existing option")
        else:
            raise Exception("Invalid option")

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
    def __init__(self, gridBase=DEF_GRID_BASE):
        pass

class Board(object):
    def __init__(self, gridBase=DEF_GRID_BASE):
        pass

class Game(object):
    def __init__(self, gridBase=DEF_GRID_BASE):
        pass

if __name__ == '__main__':
    os.system('clear')

