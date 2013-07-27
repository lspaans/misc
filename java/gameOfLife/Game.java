package nl.gridpoint.test.gameoflife;

import java.security.MessageDigest;
import java.awt.Point;
import java.lang.Math;
import java.util.ArrayList;
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
    private Boolean                     _Evolving           = Boolean.TRUE;

    private static Integer              _DefRotationAngle   = 0;
    private static Integer              _DefSpaceWidth      = 50;
    private static Integer              _DefSpaceHeight     = 50;

    // Still lifes

    private static ArrayList<Point> _ObjBlock               =
        new ArrayList<Point>(){{
            add(new Point(0,0)); add(new Point(1,0));
            add(new Point(0,1)); add(new Point(1,1));
        }};

    private static ArrayList<Point> _ObjBeehive             =
        new ArrayList<Point>(){{
            add(new Point(1,0)); add(new Point(2,0));
            add(new Point(0,1)); add(new Point(3,1));
            add(new Point(1,2)); add(new Point(2,2));
        }};

    private static ArrayList<Point> _ObjLoaf                =
        new ArrayList<Point>(){{
            add(new Point(1,0)); add(new Point(2,0));
            add(new Point(0,1)); add(new Point(3,1));
            add(new Point(1,2)); add(new Point(3,2));
            add(new Point(2,3));
        }};

    private static ArrayList<Point> _ObjBoat                =
        new ArrayList<Point>(){{
            add(new Point(0,0)); add(new Point(1,0));
            add(new Point(0,1)); add(new Point(2,1));
            add(new Point(1,2));
        }};

    // Oscillators

    private static ArrayList<Point> _ObjBlinker             =
        new ArrayList<Point>(){{
            add(new Point(0,0)); add(new Point(0,1));
            add(new Point(0,2));
        }};

    private static ArrayList<Point> _ObjToad                =
        new ArrayList<Point>(){{
            add(new Point(1,0)); add(new Point(2,0));
            add(new Point(3,0)); add(new Point(0,1));
            add(new Point(1,1)); add(new Point(2,1));
        }};

    private static ArrayList<Point> _ObjBeacon              =
        new ArrayList<Point>(){{
            add(new Point(0,0)); add(new Point(1,0));
            add(new Point(0,1)); add(new Point(1,1));
            add(new Point(2,2)); add(new Point(3,2));
            add(new Point(2,3)); add(new Point(3,3));
        }};

    private static ArrayList<Point> _ObjPulsar              =
        new ArrayList<Point>(){{
            add(new Point(2,0)); add(new Point(3,0));
            add(new Point(4,0)); add(new Point(8,0));
            add(new Point(9,0)); add(new Point(10,0));
            add(new Point(0,2)); add(new Point(5,2));
            add(new Point(7,2)); add(new Point(12,2));
            add(new Point(0,3)); add(new Point(5,3));
            add(new Point(7,3)); add(new Point(12,3));
            add(new Point(0,4)); add(new Point(5,4));
            add(new Point(7,4)); add(new Point(12,4));
            add(new Point(2,5)); add(new Point(3,5));
            add(new Point(4,5)); add(new Point(8,5));
            add(new Point(9,5)); add(new Point(10,5));
            add(new Point(2,7)); add(new Point(3,7));
            add(new Point(4,7)); add(new Point(8,7));
            add(new Point(9,7)); add(new Point(10,7));
            add(new Point(0,8)); add(new Point(5,8));
            add(new Point(7,8)); add(new Point(12,8));
            add(new Point(0,9)); add(new Point(5,9));
            add(new Point(7,9)); add(new Point(12,9));
            add(new Point(0,10)); add(new Point(5,10));
            add(new Point(7,10)); add(new Point(12,10));
            add(new Point(2,12)); add(new Point(3,12));
            add(new Point(4,12)); add(new Point(8,12));
            add(new Point(9,12)); add(new Point(10,12));
        }};

    // SPaceships

    private static ArrayList<Point> _ObjGlider              =
        new ArrayList<Point>(){{
            add(new Point(0,0)); add(new Point(1,0));
            add(new Point(2,0)); add(new Point(2,1));
            add(new Point(1,2));
        }};

    private static ArrayList<Point> _ObjLWSS                =
        new ArrayList<Point>(){{
            add(new Point(1,0)); add(new Point(2,0));
            add(new Point(0,1)); add(new Point(1,1));
            add(new Point(2,1)); add(new Point(3,1));
            add(new Point(0,2)); add(new Point(1,2));
            add(new Point(3,2)); add(new Point(4,2));
            add(new Point(2,3)); add(new Point(3,3));
        }};

    // Methuselahs

    private static ArrayList<Point> _ObjRpentomino          =
        new ArrayList<Point>(){{
            add(new Point(1,0)); add(new Point(2,0));
            add(new Point(0,1)); add(new Point(1,1));
            add(new Point(1,2));
        }};

    private static ArrayList<Point> _ObjDiehard             =
        new ArrayList<Point>(){{
            add(new Point(6,0)); add(new Point(0,1));
            add(new Point(1,1)); add(new Point(1,2));
            add(new Point(5,2)); add(new Point(6,2));
            add(new Point(7,2));
        }};

    private static ArrayList<Point> _ObjAcorn              =
        new ArrayList<Point>(){{
            add(new Point(1,0)); add(new Point(3,1));
            add(new Point(0,2)); add(new Point(1,2));
            add(new Point(4,2)); add(new Point(5,2));
            add(new Point(6,2));
        }};

    // Indefinite growth

    private static ArrayList<Point> _ObjGosperGliderGun    =
        new ArrayList<Point>(){{
            add(new Point(24,0)); add(new Point(22,1));
            add(new Point(24,1)); add(new Point(12,2));
            add(new Point(13,2)); add(new Point(20,2));
            add(new Point(21,2)); add(new Point(34,2));
            add(new Point(35,2)); add(new Point(11,3));
            add(new Point(15,3)); add(new Point(20,3));
            add(new Point(21,3)); add(new Point(34,3));
            add(new Point(35,3)); add(new Point(0,4));
            add(new Point(1,4)); add(new Point(10,4));
            add(new Point(16,4)); add(new Point(20,4));
            add(new Point(21,4)); add(new Point(0,5));
            add(new Point(1,5)); add(new Point(10,5));
            add(new Point(14,5)); add(new Point(16,5));
            add(new Point(17,5)); add(new Point(22,5));
            add(new Point(24,5)); add(new Point(10,6));
            add(new Point(16,6)); add(new Point(24,6));
            add(new Point(11,7)); add(new Point(15,7));
            add(new Point(12,8)); add(new Point(13,8));
        }};

    private static ArrayList<Point> _ObjBlockLayer1        =
        new ArrayList<Point>(){{
            add(new Point(6,0)); add(new Point(4,1));
            add(new Point(6,1)); add(new Point(7,1));
            add(new Point(4,2)); add(new Point(6,2));
            add(new Point(4,3)); add(new Point(2,4));
            add(new Point(0,5)); add(new Point(2,5));
        }};

    private static ArrayList<Point> _ObjBlockLayer2        =
        new ArrayList<Point>(){{
            add(new Point(0,0)); add(new Point(1,0));
            add(new Point(2,0)); add(new Point(4,0));
            add(new Point(0,1)); add(new Point(3,2));
            add(new Point(4,2)); add(new Point(1,3));
            add(new Point(2,3)); add(new Point(4,3));
            add(new Point(0,4)); add(new Point(2,4));
            add(new Point(4,4));
        }};

    private static ArrayList<Point> _ObjBlockLayer3        =
        new ArrayList<Point>(){{
            add(new Point(0,0)); add(new Point(1,0));
            add(new Point(2,0)); add(new Point(3,0));
            add(new Point(4,0)); add(new Point(5,0));
            add(new Point(6,0)); add(new Point(7,0));
            add(new Point(9,0)); add(new Point(10,0));
            add(new Point(11,0)); add(new Point(12,0));
            add(new Point(13,0)); add(new Point(17,0));
            add(new Point(18,0)); add(new Point(19,0));
            add(new Point(25,0)); add(new Point(26,0));
            add(new Point(27,0)); add(new Point(28,0));
            add(new Point(29,0)); add(new Point(30,0));
            add(new Point(31,0)); add(new Point(33,0));
            add(new Point(34,0)); add(new Point(35,0));
            add(new Point(36,0)); add(new Point(37,0));
        }};

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
    }

    public void displayGeneration() {
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
            _Evolving   = Boolean.FALSE;
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

    public Boolean isEvolving() {
        return(_Evolving);
    }

    public Boolean hasLiveCells() {
        if (_Space.getNumberOfLivingCells()>0) {
            return(Boolean.TRUE);
        }
        return(Boolean.FALSE);
    }

    private void addObject(
        Integer X,
        Integer Y,
        Integer RotationAngle,
        ArrayList<Point> ObjData
    ) {
        Integer MaxX            = new Integer(0);
        Integer MaxY            = new Integer(0);
        Integer RotIdx  = ((int) Math.floor(RotationAngle/90)) % 4;
        for ( Point Delta : ObjData ) {
            if ( Delta.getX() > MaxX ) {
                MaxX    = (int) Delta.getX();
            }
            if ( Delta.getY() > MaxY ) {
                MaxY    = (int) Delta.getY();
            }
        }
        for ( Point Delta : ObjData ) {
            int DeltaX      = (int) Delta.getX();
            int DeltaY      = (int) Delta.getY();
            int OldDeltaX   = DeltaX;
            int OldDeltaY   = DeltaY;
            if ( RotIdx == 1 ) {
                DeltaX  *= -1;
                DeltaX  += MaxX;
            } else if ( RotIdx == 2 ) {
                DeltaX  *= -1;
                DeltaX  += MaxX;
                DeltaY  *= -1;
                DeltaY  += MaxY;
            } else if ( RotIdx == 3 ) {
                DeltaY  *= -1;
                DeltaY  += MaxY;
            }
            _Space.getCell(
                X + DeltaX,
                Y + DeltaY
            ).doLive();
        }
    }

    public void addBlock(
        Integer X,
        Integer Y
    ) {
        this.addBlock(X,Y,_DefRotationAngle);
    }

    public void addBlock(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjBlock);
    }

    public void addBeehive(
        Integer X,
        Integer Y
    ) {
        this.addBeehive(X,Y,_DefRotationAngle);
    }

    public void addBeehive(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjBeehive);
    }

    public void addLoaf(
        Integer X,
        Integer Y
    ) {
        this.addLoaf(X,Y,_DefRotationAngle);
    }

    public void addLoaf(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjLoaf);
    }

    public void addBoat(
        Integer X,
        Integer Y
    ) {
        this.addBoat(X,Y,_DefRotationAngle);
    }

    public void addBoat(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjBoat);
    }

    public void addBlinker(
        Integer X,
        Integer Y
    ) {
        this.addBlinker(X,Y,_DefRotationAngle);
    }

    public void addBlinker(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjBlinker);
    }

    public void addToad(
        Integer X,
        Integer Y
    ) {
        this.addToad(X,Y,_DefRotationAngle);
    }

    public void addToad(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjToad);
    }

    public void addBeacon(
        Integer X,
        Integer Y
    ) {
        this.addBeacon(X,Y,_DefRotationAngle);
    }

    public void addBeacon(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjBeacon);
    }

    public void addPulsar(
        Integer X,
        Integer Y
    ) {
        this.addPulsar(X,Y,_DefRotationAngle);
    }

    public void addPulsar(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjPulsar);
    }

    public void addGlider(
        Integer X,
        Integer Y
    ) {
        this.addGlider(X,Y,_DefRotationAngle);
    }

    public void addGlider(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjGlider);
    }

    public void addLWSS(
        Integer X,
        Integer Y
    ) {
        this.addLWSS(X,Y,_DefRotationAngle);
    }

    public void addLWSS(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjLWSS);
    }

    public void addRpentomino(
        Integer X,
        Integer Y
    ) {
        this.addRpentomino(X,Y,_DefRotationAngle);
    }

    public void addRpentomino(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjRpentomino);
    }

    public void addDiehard(
        Integer X,
        Integer Y
    ) {
        this.addDiehard(X,Y,_DefRotationAngle);
    }

    public void addDiehard(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjDiehard);
    }

    public void addAcorn(
        Integer X,
        Integer Y
    ) {
        this.addAcorn(X,Y,_DefRotationAngle);
    }

    public void addAcorn(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjAcorn);
    }

    public void addGosperGlidingGun(
        Integer X,
        Integer Y
    ) {
        this.addGosperGlidingGun(X,Y,_DefRotationAngle);
    }

    public void addGosperGlidingGun(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjGosperGliderGun);
    }

    public void addBlockLayer1(
        Integer X,
        Integer Y
    ) {
        this.addBlockLayer1(X,Y,_DefRotationAngle);
    }

    public void addBlockLayer1(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjBlockLayer1);
    }

    public void addBlockLayer2(
        Integer X,
        Integer Y
    ) {
        this.addBlockLayer2(X,Y,_DefRotationAngle);
    }

    public void addBlockLayer2(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjBlockLayer2);
    }

    public void addBlockLayer3(
        Integer X,
        Integer Y
    ) {
        this.addBlockLayer3(X,Y,_DefRotationAngle);
    }

    public void addBlockLayer3(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjBlockLayer3);
    }
}
