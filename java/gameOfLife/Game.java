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
    private static Integer              _DefSpaceWidth      = 60;
    private static Integer              _DefSpaceHeight     = 40;

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

    private static ArrayList<Point> _Obj123                 =
        new ArrayList<Point>(){{
            add(new Point(2,0)); add(new Point(3,0));
            add(new Point(0,1)); add(new Point(3,1));
            add(new Point(0,2)); add(new Point(1,2));
            add(new Point(3,2)); add(new Point(5,2));
            add(new Point(6,2)); add(new Point(1,3));
            add(new Point(3,3)); add(new Point(6,3));
            add(new Point(1,4)); add(new Point(6,4));
            add(new Point(8,4)); add(new Point(9,4));
            add(new Point(2,5)); add(new Point(3,5));
            add(new Point(4,5)); add(new Point(6,5));
            add(new Point(8,5)); add(new Point(9,5));
            add(new Point(5,6)); add(new Point(4,7));
            add(new Point(4,8)); add(new Point(5,8));
	}};

    private static ArrayList<Point> _ObjStillater           =
        new ArrayList<Point>(){{
            add(new Point(3,0)); add(new Point(2,1));
            add(new Point(4,1)); add(new Point(6,1));
            add(new Point(7,1)); add(new Point(2,2));
            add(new Point(4,2)); add(new Point(5,2));
            add(new Point(7,2)); add(new Point(0,3));
            add(new Point(1,3)); add(new Point(1,4));
            add(new Point(3,4)); add(new Point(5,4));
            add(new Point(6,4)); add(new Point(1,5));
            add(new Point(3,5)); add(new Point(6,5));
            add(new Point(2,6)); add(new Point(5,6));
            add(new Point(3,7)); add(new Point(4,7));
	}};

    private static ArrayList<Point> _ObjCuphook             =
        new ArrayList<Point>(){{
            add(new Point(4,0)); add(new Point(5,0));
            add(new Point(0,1)); add(new Point(1,1));
            add(new Point(3,1)); add(new Point(5,1));
            add(new Point(0,2)); add(new Point(1,2));
            add(new Point(3,2)); add(new Point(3,3));
            add(new Point(3,4)); add(new Point(6,4));
            add(new Point(4,5)); add(new Point(5,5));
            add(new Point(7,5)); add(new Point(7,6));
            add(new Point(7,7)); add(new Point(8,7));
	}};

    // Spaceships

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

    private static ArrayList<Point> _ObjMWSS                =
        new ArrayList<Point>(){{
            add(new Point(3,0)); add(new Point(1,1));
            add(new Point(5,1)); add(new Point(0,2));
            add(new Point(0,3)); add(new Point(5,3));
            add(new Point(0,4)); add(new Point(1,4));
            add(new Point(2,4)); add(new Point(3,4));
            add(new Point(4,4));
        }};

    private static ArrayList<Point> _ObjHWSS                =
        new ArrayList<Point>(){{
            add(new Point(3,0)); add(new Point(4,0));
            add(new Point(1,1)); add(new Point(6,1));
            add(new Point(0,2)); add(new Point(0,3));
            add(new Point(6,3)); add(new Point(0,4));
            add(new Point(1,4)); add(new Point(2,4));
            add(new Point(3,4)); add(new Point(4,4));
            add(new Point(5,4));
        }};

    // Puffers

    private static ArrayList<Point> _ObjBackrake            =
        new ArrayList<Point>(){{
            add(new Point(5,0)); add(new Point(6,0));
            add(new Point(7,0)); add(new Point(19,0));
            add(new Point(20,0)); add(new Point(21,0));
            add(new Point(4,1)); add(new Point(8,1));
            add(new Point(18,1)); add(new Point(22,1));
            add(new Point(3,2)); add(new Point(4,2));
            add(new Point(9,2)); add(new Point(17,2));
            add(new Point(22,2)); add(new Point(23,2));
            add(new Point(2,3)); add(new Point(4,3));
            add(new Point(6,3)); add(new Point(7,3));
            add(new Point(9,3)); add(new Point(10,3));
            add(new Point(16,3)); add(new Point(17,3));
            add(new Point(19,3)); add(new Point(20,3));
            add(new Point(22,3)); add(new Point(24,3));
            add(new Point(1,4)); add(new Point(2,4));
            add(new Point(4,4)); add(new Point(9,4));
            add(new Point(11,4)); add(new Point(12,4));
            add(new Point(14,4)); add(new Point(15,4));
            add(new Point(17,4)); add(new Point(22,4));
            add(new Point(24,4)); add(new Point(25,4));
            add(new Point(0,5)); add(new Point(5,5));
            add(new Point(9,5)); add(new Point(12,5));
            add(new Point(14,5)); add(new Point(17,5));
            add(new Point(21,5)); add(new Point(26,5));
            add(new Point(12,6)); add(new Point(14,6));
            add(new Point(0,7)); add(new Point(1,7));
            add(new Point(9,7)); add(new Point(10,7));
            add(new Point(12,7)); add(new Point(14,7));
            add(new Point(16,7)); add(new Point(17,7));
            add(new Point(25,7)); add(new Point(26,7));
            add(new Point(12,8)); add(new Point(14,8));
            add(new Point(6,9)); add(new Point(7,9));
            add(new Point(8,9)); add(new Point(18,9));
            add(new Point(19,9)); add(new Point(20,9));
            add(new Point(6,10)); add(new Point(10,10));
            add(new Point(20,10)); add(new Point(6,11));
            add(new Point(8,11)); add(new Point(13,11));
            add(new Point(14,11)); add(new Point(15,11));
            add(new Point(12,12)); add(new Point(15,12));
            add(new Point(20,12)); add(new Point(21,12));
            add(new Point(15,13)); add(new Point(11,14));
            add(new Point(15,14)); add(new Point(11,15));
            add(new Point(15,15)); add(new Point(15,16));
            add(new Point(12,17)); add(new Point(14,17));
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

    private static ArrayList<Point> _ObjHomeMade1         =
        new ArrayList<Point>(){{
            add(new Point(0,0)); add(new Point(2,0));
            add(new Point(0,1)); add(new Point(1,1));
            add(new Point(2,1)); add(new Point(0,2));
            add(new Point(1,2)); add(new Point(2,2));
        }};

    private static ArrayList<Point> _ObjLoafer            =
        new ArrayList<Point>(){{
            add(new Point(1,0)); add(new Point(2,0));
            add(new Point(5,0)); add(new Point(7,0));
            add(new Point(8,0)); add(new Point(0,1));
            add(new Point(3,1)); add(new Point(6,1));
            add(new Point(7,1)); add(new Point(1,2));
            add(new Point(3,2)); add(new Point(2,3));
            add(new Point(8,4)); add(new Point(6,5));
            add(new Point(7,5)); add(new Point(8,5));
            add(new Point(5,6)); add(new Point(6,7));
            add(new Point(7,8)); add(new Point(8,8));
        }};

    private static ArrayList<Point> _ObjSidecar           =
        new ArrayList<Point>(){{
            add(new Point(1,0)); add(new Point(2,0));
            add(new Point(0,1)); add(new Point(1,1));
            add(new Point(3,1)); add(new Point(4,1));
            add(new Point(7,1)); add(new Point(8,1));
            add(new Point(1,2)); add(new Point(2,2));
            add(new Point(3,2)); add(new Point(4,2));
            add(new Point(6,2)); add(new Point(2,3));
            add(new Point(3,3)); add(new Point(2,6));
            add(new Point(3,6)); add(new Point(1,7));
            add(new Point(2,7)); add(new Point(4,7));
            add(new Point(5,7)); add(new Point(6,7));
            add(new Point(7,7)); add(new Point(2,8));
            add(new Point(3,8)); add(new Point(4,8));
            add(new Point(5,8)); add(new Point(6,8));
            add(new Point(7,8)); add(new Point(3,9));
            add(new Point(4,9)); add(new Point(5,9));
            add(new Point(6,9));

        }};

    private static ArrayList<Point> _ObjSpider            =
        new ArrayList<Point>(){{
            add(new Point(9,0)); add(new Point(17,0));
            add(new Point(3,1)); add(new Point(4,1));
            add(new Point(6,1)); add(new Point(8,1));
            add(new Point(10,1)); add(new Point(11,1));
            add(new Point(15,1)); add(new Point(16,1));
            add(new Point(18,1)); add(new Point(20,1));
            add(new Point(22,1)); add(new Point(23,1));
            add(new Point(0,2)); add(new Point(1,2));
            add(new Point(2,2)); add(new Point(4,2));
            add(new Point(6,2)); add(new Point(7,2));
            add(new Point(8,2)); add(new Point(18,2));
            add(new Point(19,2)); add(new Point(20,2));
            add(new Point(22,2)); add(new Point(24,2));
            add(new Point(25,2)); add(new Point(26,2));
            add(new Point(0,3)); add(new Point(4,3));
            add(new Point(6,3)); add(new Point(12,3));
            add(new Point(14,3)); add(new Point(20,3));
            add(new Point(22,3)); add(new Point(26,3));
            add(new Point(4,4)); add(new Point(5,4));
            add(new Point(12,4)); add(new Point(14,4));
            add(new Point(21,4)); add(new Point(22,4));
            add(new Point(1,5)); add(new Point(2,5));
            add(new Point(12,5)); add(new Point(14,5));
            add(new Point(24,5)); add(new Point(25,5));
            add(new Point(1,6)); add(new Point(2,6));
            add(new Point(4,6)); add(new Point(5,6));
            add(new Point(21,6)); add(new Point(22,6));
            add(new Point(24,6)); add(new Point(25,6));
            add(new Point(5,7)); add(new Point(21,7));
        }};

    private static ArrayList<Point> _ObjSchickenEngine   =
        new ArrayList<Point>(){{
            add(new Point(1,0)); add(new Point(4,0));
            add(new Point(0,1)); add(new Point(0,2));
            add(new Point(4,2)); add(new Point(0,3));
            add(new Point(1,3)); add(new Point(2,3));
            add(new Point(3,3)); add(new Point(13,3));
            add(new Point(14,3)); add(new Point(6,4));
            add(new Point(7,4)); add(new Point(8,4));
            add(new Point(14,4)); add(new Point(15,4));
            add(new Point(6,5)); add(new Point(7,5));
            add(new Point(9,5)); add(new Point(10,5));
            add(new Point(17,5)); add(new Point(18,5));
            add(new Point(19,5)); add(new Point(6,6));
            add(new Point(7,6)); add(new Point(8,6));
            add(new Point(14,6)); add(new Point(15,6));
            add(new Point(0,7)); add(new Point(1,7));
            add(new Point(2,7)); add(new Point(3,7));
            add(new Point(13,7)); add(new Point(14,7));
            add(new Point(0,8)); add(new Point(4,8));
            add(new Point(0,9)); add(new Point(1,10));
            add(new Point(4,10));
        }};

    private static ArrayList<Point> _ObjOrion           =
        new ArrayList<Point>(){{
            add(new Point(3,0)); add(new Point(4,0));
            add(new Point(3,1)); add(new Point(5,1));
            add(new Point(3,2)); add(new Point(0,3));
            add(new Point(1,3)); add(new Point(3,3));
            add(new Point(0,4)); add(new Point(5,4));
            add(new Point(0,5)); add(new Point(2,5));
            add(new Point(3,5)); add(new Point(10,5));
            add(new Point(11,5)); add(new Point(12,5));
            add(new Point(5,6)); add(new Point(6,6));
            add(new Point(7,6)); add(new Point(12,6));
            add(new Point(13,6)); add(new Point(6,7));
            add(new Point(7,7)); add(new Point(8,7));
            add(new Point(10,7)); add(new Point(12,7));
            add(new Point(13,8)); add(new Point(6,9));
            add(new Point(8,9)); add(new Point(5,10));
            add(new Point(6,10)); add(new Point(8,10));
            add(new Point(6,11)); add(new Point(4,12));
            add(new Point(5,12)); add(new Point(7,12));
            add(new Point(7,13)); add(new Point(5,14));
            add(new Point(6,14));
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

    public void initRandomGeneration(Integer Num) {
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
            this.initRandomGeneration(NumLiveCells);
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

    public void add123(
        Integer X,
        Integer Y
    ) {
        this.add123(X,Y,_DefRotationAngle);
    }

    public void add123(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_Obj123);
    }

    public void addStillater(
        Integer X,
        Integer Y
    ) {
        this.addStillater(X,Y,_DefRotationAngle);
    }

    public void addStillater(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjStillater);
    }

    public void addCuphook(
        Integer X,
        Integer Y
    ) {
        this.addCuphook(X,Y,_DefRotationAngle);
    }

    public void addCuphook(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjCuphook);
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

    public void addMWSS(
        Integer X,
        Integer Y
    ) {
        this.addMWSS(X,Y,_DefRotationAngle);
    }

    public void addMWSS(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjMWSS);
    }

    public void addHWSS(
        Integer X,
        Integer Y
    ) {
        this.addHWSS(X,Y,_DefRotationAngle);
    }

    public void addHWSS(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjHWSS);
    }

    public void addBackrake(
        Integer X,
        Integer Y
    ) {
        this.addBackrake(X,Y,_DefRotationAngle);
    }

    public void addBackrake(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjBackrake);
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

    public void addGosperGliderGun(
        Integer X,
        Integer Y
    ) {
        this.addGosperGliderGun(X,Y,_DefRotationAngle);
    }

    public void addGosperGliderGun(
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

    public void addHomeMade1(
        Integer X,
        Integer Y
    ) {
        this.addHomeMade1(X,Y,_DefRotationAngle);
    }

    public void addHomeMade1(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjHomeMade1);
    }

    public void addLoafer(
        Integer X,
        Integer Y
    ) {
        this.addLoafer(X,Y,_DefRotationAngle);
    }

    public void addLoafer(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjLoafer);
    }

    public void addSidecar(
        Integer X,
        Integer Y
    ) {
        this.addSidecar(X,Y,_DefRotationAngle);
    }

    public void addSidecar(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjSidecar);
    }

    public void addSpider(
        Integer X,
        Integer Y
    ) {
        this.addSpider(X,Y,_DefRotationAngle);
    }

    public void addSpider(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjSpider);
    }

    public void addSchickenEngine(
        Integer X,
        Integer Y
    ) {
        this.addSchickenEngine(X,Y,_DefRotationAngle);
    }

    public void addSchickenEngine(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjSchickenEngine);
    }

    public void addOrion(
        Integer X,
        Integer Y
    ) {
        this.addOrion(X,Y,_DefRotationAngle);
    }

    public void addOrion(
        Integer X,
        Integer Y,
        Integer RotationAngle
    ) {
        this.addObject(X,Y,RotationAngle,_ObjOrion);
    }

    public void initGliderFormation() {
        this.initGliderFormation(40,40);
    }

    public void initGliderFormation(Integer Width,Integer Height) {
        _Space      = new Space(Width,Height);
        this.addGlider(15,13,90);
        this.addGlider(22,13,0);
        this.addGlider(15,23,180);
        this.addGlider(22,23,270);
    }

    public void initGosperGliderGun() {
        this.initGosperGliderGun(120,25);
    }

    public void initGosperGliderGun(Integer Width,Integer Height) {
        _Space      = new Space(Width,Height);
        this.addGosperGliderGun(1,7);
    }

    public void initHomeMadeGeneration1() {
        this.initHomeMadeGeneration1(53,46);
    }

    public void initHomeMadeGeneration1(Integer Width,Integer Height) {
        _Space      = new Space(Width,Height);
        this.addHomeMade1(25,22);
    }
}
