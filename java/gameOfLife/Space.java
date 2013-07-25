package nl.gridpoint.test.gameoflife;

import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Vector;

import nl.gridpoint.test.gameoflife.Cell;

public class Space {

    private Integer                 _Generation = 1;

    private Integer                 _Width;
    private Integer                 _Height;

    private Cell[][]                _Cells;

    private HashMap<String,String>  _MD5Cache   = new HashMap<String,String>();

    private Boolean                 _Loop       = Boolean.FALSE;

    private static Integer          _DefWidth   = 100;
    private static Integer          _DefHeight  = 100;

    public Space() {
        this(_DefWidth,_DefHeight);
    }

    public Space(
        Integer Width,
        Integer Height 
    ) {
        this._initSpace(
            Width,
            Height 
        );
    }

    private Boolean _isValidDimension(Integer Dim) {
        if( Dim != null ) {
            return(Boolean.TRUE);
        }
        return(Boolean.FALSE);
    }

    private void _setDimension(char dim,Integer Dim) {
        if(this._isValidDimension(Dim)) {
            if ( dim == 'w' ) {
                _Width   = Dim;
            } else if ( dim == 'h' ) {
                _Height  = Dim;
            } else {
            }
        }
    }

    private void _setWidth(Integer Dim) {
        this._setDimension('w',Dim);
    }

    private void _setHeight(Integer Dim) {
        this._setDimension('h',Dim);
    }

    private void _initSpace(
        Integer Width,
        Integer Height 
    ) {
        _Cells          = new Cell[Width][Height];
        this._setWidth(Width);
        this._setHeight(Height);
        for(int y=0;y<Height;y++) {
            for(int x=0;x<Width;x++) {
                _Cells[x][y]    = new Cell(x,y);
            }
        }
    }

    private Integer _getDimension(char dim) {
        if ( dim == 'w' ) {
            return(this._Width);
        } else if ( dim == 'h' ) {
            return(this._Height);
        } else {
            return(null);
        }
    }

    public Integer getGeneration() {
        return(_Generation);
    }

    public Integer getWidth() {
        return(this._getDimension('w'));
    }

    public Integer getHeight() {
        return(this._getDimension('h'));
    }

    public Cell getCell(Integer x,Integer y) {
        x   = ( x >= 0 ) ? x % _Width  : _Width  + ( x % _Width  );
        y   = ( y >= 0 ) ? y % _Height : _Height + ( y % _Height );
        return(_Cells[x][y]);
    }

    public Vector<Cell> getCells() {
        Vector<Cell> cells      = new Vector<Cell>();
        for (int y=0;y<_Height;y++) {
            for(int x=0;x<_Width;x++) {
                cells.add(_Cells[x][y]);
            }
        }
        return(cells);
    }

    public Vector<Cell> getNeighbourCells(Integer x,Integer y) {
        Vector<Cell> cells      = new Vector<Cell>();
        int[] d                 = { -1, 0, 1 };
        for(int d_y=0;d_y<d.length;d_y++) {
            for(int d_x=0;d_x<d.length;d_x++) {
                if ( d[d_x] != 0 || d[d_y] != 0 ) {
                    cells.add(this.getCell(x+d[d_x],y+d[d_y]));
                }
            }
        }
        return(cells);
    }

    public Integer getNumberOfLivingCells() {
        Vector<Cell> cells      = this.getCells();
        Iterator<Cell> i        = cells.iterator();
        Integer  n              = new Integer(0);
        while(i.hasNext()) {
            if (i.next().isAlive()) {
                n++;
            }
        }
        return(n);
    }

    public Integer getNumberOfLivingNeighbourCells(Integer x,Integer y) {
        Vector<Cell> cells      = this.getNeighbourCells(x,y);
        Iterator<Cell> i        = cells.iterator();
        Integer  n              = new Integer(0);
        while(i.hasNext()) {
            if (i.next().isAlive()) {
                n++;
            }
        }
        return(n);
    }

    public void nextGeneration() {
        Cell[][]  NewCells  = _Cells;
        String    MD5       = this.getMD5();
        if (_MD5Cache.containsKey(MD5)) {
            _Loop    = Boolean.TRUE;
        } else {
            _MD5Cache.put(this.getMD5(),this.toString());
        }
        for(int y=0;y<_Height;y++) {
            for(int x=0;x<_Width;x++) {
                Integer n = this.getNumberOfLivingNeighbourCells(x,y);

                if ( NewCells[x][y].isAlive() ) {
                    if ( n < 2 || n > 3 ) {
                        NewCells[x][y].doKill();
                    }
                } else {
                    if ( n == 3 ) {
                        NewCells[x][y].doLive();
                    }
                }
            }
        }
        _Generation++;
        _Cells      = NewCells;
    }

    public String toString() {
        String Out      = "";
        for(int y=0;y<_Height;y++) {
            for(int x=0;x<_Width;x++) {
                if ( _Cells[x][y].isAlive() ) {
                    Out += "O";
                } else {
                    Out += ".";
                }
            }
            Out += "\n";
        }
        return(Out);
    }

    public String getMD5() {
        try {
            java.security.MessageDigest md =
                java.security.MessageDigest.getInstance("MD5");
            byte[] array = md.digest(this.toString().getBytes());
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < array.length; ++i) {
                sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
            }
            return sb.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
        }
        return(null);
    }

    public Boolean isLooping() {
        return(_Loop);
    }

    public void display() {
        System.out.println(this.toString());
    }
}
