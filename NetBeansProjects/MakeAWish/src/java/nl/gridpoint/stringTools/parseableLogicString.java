/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.gridpoint.stringTools;

/**
 *
 * @author leons
 */
public class parseableLogicString {
    
    private String _inputString, _outputString;
    
    public void setInputString(String inputString) { 
        
        String tempString   = inputString.trim();
        int quotNr          = 0;
        
        _inputString    = inputString;
        _outputString   = "";
        
        for(int n=0;n<tempString.length();n++) {
            char c = tempString.charAt(n);
            if ( c != '"' ) {
                if ( c != ' ' ) {
                    _outputString += c;
                } else if ( quotNr%2 != 0) {
                    _outputString += ' ';
                } else {
                    _outputString += '|';
                }
            } else {
                quotNr++;
            }
        }
    }
    public String getInputString() { return _inputString; }
    public String getOutputString() { return _outputString; }
}
