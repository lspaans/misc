package nl.gridpoint.test.gameoflife;

public class Cell {

    private Boolean             _Alive      = Boolean.FALSE;

    public Cell() {
        this._initCell();
    }

    private void _initCell() {
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
