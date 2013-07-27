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

    public String getState() {
        if (_Alive) {
            return("alive");
        } else {
            return("dead");
        }
    }

    public void setState(String State) {
        if (State.equalsIgnoreCase("alive")) {
            _Alive  = Boolean.TRUE;
        } else {
            _Alive  = Boolean.FALSE;
        }
    }
}
