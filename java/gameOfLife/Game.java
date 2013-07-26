package nl.gridpoint.test.gameoflife;

import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Random;
import java.util.Vector;

import nl.gridpoint.test.gameoflife.Space;

public class Game {

    private Space                       _Space;
    private Integer                     _Generation         = new Integer(1);
    private Integer                     _NumLiveCells;
    private HashMap<String,String>      _SpaceMem           =
        new HashMap<String,String>();
    private Boolean                     _Loop               = Boolean.FALSE;

    private static Integer              _DefRotationAngle   = 0;
    private static Integer              _DefSpaceWidth      = 50;
    private static Integer              _DefSpaceHeight     = 50;

    /*      .......   .......   .......
     *      ...0...   .......   .......
     *      ....0..   ....0..   .......
     *      ..000..   ...00..   ...00..
     *      .......   ...0...   ...00..
     */           

//    private static HashMap<Integer,Integer> _ObjGlider          =
//        new HashMap<Integer,Integer>(){{
//            put(1,1); put(2,1); put(3,1);
//            put(3,2);
//            put(2,3);
//        }};

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

    public void initGeneration(Integer Num) {
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
            this.initGeneration(NumLiveCells);
        }
else {
    _Space.getCell(5,5).doLive();
    _Space.getCell(6,5).doLive();
    _Space.getCell(7,5).doLive();
    _Space.getCell(7,4).doLive();
    _Space.getCell(6,3).doLive();
}
    }

    public void displaySpace() {
        _Space.display();
    }

    public void nextGeneration() {
        Space NewSpace      = _Space.getClone();
        String MD5          = new String();
        for(int y=0;y<_Space.getHeight();y++) {
            for(int x=0;x<_Space.getWidth();x++) {
                Integer n = _Space.getNumberOfLivingNeighbourCells(x,y);

                if ( _Space.getCell(x,y).isAlive() ) {
                    if ( n < 2 || n > 3 ) {
                        NewSpace.getCell(x,y).doKill();
                    }
                } else if ( _Space.getCell(x,y).isDead() ) {
                    if ( n == 3 ) {
                        NewSpace.getCell(x,y).doLive();
                    }
                }
            }
        }
        _Space       = NewSpace.getClone();
        MD5          = _Space.getMD5();
        if (_SpaceMem.containsKey(MD5)) {
            _Loop    = Boolean.TRUE;
        } else {
            _SpaceMem.put(MD5,_Space.toString());
        }
        _Generation++;
    }

    public Integer getGeneration() {
        return(_Generation);
    }

    public String getMD5Space() {
        return(_Space.getMD5());
    }

    public Boolean isLooping() {
        return(_Loop);
    }

    public Boolean hasLiveCells() {
        if (_Space.getNumberOfLivingCells()>0) {
            return(Boolean.TRUE);
        }
        return(Boolean.FALSE);
    }

//    private void addObject(
//        Integer X,
//        Integer Y,
//        Integer RotationAngle,
//        HashMap<Integer,Integer> ObjData
//    ) {
//        System.out.println("HOPS!");
//    }
//
//    public void addGlider(
//        Integer X,
//        Integer Y
//    ) {
//        this.addGlider(X,Y,_DefRotationAngle);
//    }
//
//    public void addGlider(
//        Integer X,
//        Integer Y,
//        Integer RotationAngle
//    ) {
//        this.addObject(X,Y,RotationAngle,_ObjGlider);
//    }
}
