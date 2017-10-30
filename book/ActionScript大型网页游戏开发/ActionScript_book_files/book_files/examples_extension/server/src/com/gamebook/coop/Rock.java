package com.gamebook.coop;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * A rock is an item in the game that can be pushed by the players.
 * To move a rock, both players must be pushing in the same direction
 * 
 * @author Scott
 */
public class Rock {

    private final Integer id;
    private int location_x;
    private int location_y;

    private Map<String, String> playersPushing; // <PlayerName, Direction>
    
    public Rock( Integer id ) {
        this.id = id;
        playersPushing = new ConcurrentHashMap<String, String>();
    }
    
    public Integer getId( ) {
        return id;
    }

    /**
     * Set the location of the rock.
     * 
     * @param x
     * @param y
     */
    public synchronized void setLocation( int x, int y ) {
        this.location_x = x;
        this.location_y = y;
    }
    
    /**
     * Update the players push status.  Keep track of the player and the direction they are pushing.
     * If the direction is null then they are no longer pushing the rock.
     * 
     * @param playerName
     *          The player pushing (or stopping push)
     * @param direction
     *          The direction they are pushing
     */
    public synchronized void pushRock( String playerName, String direction ) {
        if ( direction == null ) {
            playersPushing.remove( playerName );
        } else {
            playersPushing.put( playerName, direction );
        }
    }
    
    /**
     * If both players are pushing the rock in the same direction then the rock can be moved.
     * @return
     *          true if both players are pushing in the same direction.
     */
    public synchronized boolean canBeMoved( ) {
        Set<String> directions = new HashSet<String>();
        for ( String direction : playersPushing.values( ) ) {
            if ( directions.contains( direction ) ) {
                // there are two people pushing in the same direction
                return true;
            }
            directions.add( direction );
        }
        // two people are not pushing this rock in the same direction
        return false;
    }
    
    /**
     * Get the position of the rock
     * @return
     *          an int[] of the rock with x in 0 and y in 1 ( [x,y] )
     */
    public int[] getPosition( ) {
        return new int[] { location_x, location_y };
    }
}
