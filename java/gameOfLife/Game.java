package nl.gridpoint.test.gameoflife;

import java.util.Random;
import java.util.Vector;

import nl.gridpoint.test.gameoflife.Space;

public class Game {

    private Space               _Space;

    private Integer             _NumLiveCells;

    private static Integer      _DefSpaceWidth      = 50;
    private static Integer      _DefSpaceHeight     = 50;

    public Game() {
        this(
            _DefSpaceWidth,
            _DefSpaceHeight
        );
    }

    public Game(
        Integer Width,
        Integer Height
    ) {
        this._initGame(
            Width,
            Height,
            0
        );
    }

    public Game(
        Integer Width,
        Integer Height,
        Integer NumLiveCells
    ) {
        this._initGame(
            Width,
            Height,
            NumLiveCells
        );
    }

    public void doLiveCells(Integer Num) {
        Integer Width           = _Space.getWidth();
        Integer Height          = _Space.getHeight();
        _NumLiveCells           = Num;
        Random randomGenerator  = new Random();
        int[][] posCache        = new int[Width][Height];

        for(int n=0;n<Num;n++) {
            int x = randomGenerator.nextInt(Width);
            int y = randomGenerator.nextInt(Height);
            while(posCache[x][y]>0) {
                x = randomGenerator.nextInt(Width);
                y = randomGenerator.nextInt(Height);
            }
            _Space.getCell(x,y).doLive();
            posCache[x][y]++;
        }
    }

    private void _initGame(
        Integer Width,
        Integer Height,
        Integer NumLiveCells
    ) {
        _Space          = new Space(Width,Height);
        if ( NumLiveCells > 0 ) {
            this.doLiveCells(NumLiveCells);
        }
    }

    public Integer getGenerationSpace() {
        return(_Space.getGeneration());
    }

    public String getMD5Space() {
        return(_Space.getMD5());
    }

    public Boolean isLoopingSpace() {
        return(_Space.isLooping());
    }

    public void displaySpace() {
        _Space.display();
    }

    public void nextGenerationSpace() {
        _Space.nextGeneration();
    }

    public Boolean hasLiveCells() {
        if (_Space.getNumberOfLivingCells()>0) {
            return(Boolean.TRUE);
        }
        return(Boolean.FALSE);
    }
}
