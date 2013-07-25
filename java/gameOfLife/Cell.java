package nl.gridpoint.test.gameoflife;

public class Cell {

    private Integer             _PosX;
    private Integer             _PosY;
    private Boolean             _Alive      = Boolean.FALSE;

    private static Integer      _DefPosX    = 0;
    private static Integer      _DefPosY    = 0;

    public Cell() {
        this(_DefPosX,_DefPosY);
    }

    public Cell(
        Integer PosX,
        Integer PosY 
    ) {
        this._initCell(
            PosX,
            PosY 
        );
    }

    private Boolean _isValidPos(Integer Pos) {
        if( Pos != null ) {
            return(Boolean.TRUE);
        }
        return(Boolean.FALSE);
    }

    private void _setPos(char dim,Integer Pos) {
        if(this._isValidPos(Pos)) {
            if ( dim == 'x' ) {
                _PosX   = Pos;
            } else if ( dim == 'y' ) {
                _PosY   = Pos;
            } else {
            }
        }
    }

    private void _setPosX(Integer Pos) {
        this._setPos('x',Pos);
    }

    private void _setPosY(Integer Pos) {
        this._setPos('y',Pos);
    }

    private void _initCell(
        Integer PosX,
        Integer PosY 
    ) {
        this._setPosX(PosX);
        this._setPosY(PosY);
    }

    private Integer _getPos(char dim) {
        if ( dim == 'x' ) {
            return(this._PosX);
        } else if ( dim == 'y' ) {
            return(this._PosY);
        } else {
            return(null);
        }
    }

    public Integer getPosX() {
        return(this._getPos('x'));
    }

    public Integer getPosY() {
        return(this._getPos('y'));
    }

    public Boolean isAlive() {
        return(_Alive);
    }

    public Boolean isDead() {
        return(!_Alive);
    }

    public void doLive() {
        _Alive  = Boolean.TRUE;
    }

    public void doKill() {
        _Alive  = Boolean.FALSE;
    }

}
