package nl.gridpoint.test.gameoflife;

import java.util.Iterator;
import java.util.Vector;

import nl.gridpoint.test.gameoflife.Cell;
import nl.gridpoint.test.gameoflife.Space;
import nl.gridpoint.test.gameoflife.Game;

public class Main {

    private static final String ANSI_CLS            = "\u001b[2J";
    private static final String ANSI_HOME           = "\u001b[H";

    private static void clearScreen() {
        System.out.print(ANSI_CLS + ANSI_HOME);                                 
        System.out.flush();
    }

    public static void main(String[] args) {

        Game g                   = new Game(100,50,150);

        while(
            g.hasLiveCells() &&
            !g.isLoopingSpace()
        ) {
            clearScreen();
            System.out.println("Generation: " + 
                    "'" + g.getGenerationSpace() + "', " +
                    "[" + g.getMD5Space() + "]"
            );
            g.displaySpace();
            g.nextGenerationSpace();
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
            }
        }
    }
}
