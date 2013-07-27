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

        Game g                   = new Game();

        //g.initRandomGeneration(150);
        //g.initGliderFormation();
        //g.initGosperGliderGun();
        g.initHomeMadeGeneration1();

        //g.addBlock(10,10);
        //g.addBeehive(10,10);
        //g.addLoaf(10,10);
        //g.addBoat(10,10);
        //g.addBlinker(10,10);
        //g.addToad(10,10);
        //g.addBeacon(10,10);
        //g.addPulsar(10,10);
        //g.addGlider(10,10);
        //g.addLWSS(10,10);
        //g.addMWSS(10,10);
        //g.addHWSS(10,10);
        //g.addRpentomino(10,10);
        //g.addDiehard(10,10);
        //g.addAcorn(10,10);
        //g.addGosperGliderGun(10,10);
        //g.addBlockLayer1(10,10);
        //g.addBlockLayer2(10,10);
        //g.addBlockLayer3(10,10);
        //g.addHomeMade1(10,10);
        //g.addLoafer(10,10);
        //g.addSidecar(10,10);
        //g.addSpider(10,10);
        //g.addSchickenEngine(10,10);
        //g.addOrion(10,10);

        while(g.hasLiveCells() && g.isEvolving()) {
            clearScreen();
            System.out.println("Generation: " + 
                "'" + g.getGeneration() + "', " +
                "[" + g.getMD5Space() + "]"
            );
            g.displayGeneration();
            g.nextGeneration();
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
            }
        }
    }
}
