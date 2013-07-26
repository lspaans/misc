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

        Game g                   = new Game(75,40);
//        g.initGeneration(100);

        while(
            g.hasLiveCells() &&
            !g.isLooping()
        ) {
            clearScreen();
            System.out.println("Generation: " + 
                    "'" + g.getGeneration() + "', " +
                    "[" + g.getMD5Space() + "]"
            );
            g.displaySpace();
            g.nextGeneration();
            try {
                Thread.sleep(5000);
            } catch (InterruptedException e) {
            }
        }
    }
}
