package com.gamebook.coop;

import java.util.Date;
import java.util.concurrent.atomic.AtomicInteger;

import com.electrotank.electroserver4.extensions.api.value.EsObject;

/**
 * The player is the guy that can move around the board and do stuff
 * 
 * @author Scott
 */
public class Player {

    public static enum PlayerType {
        Attacker,
        Defender
    }
    private final String name;
    private final Date created;
    
    private boolean alive = true;
    private AtomicInteger livesRemaining;
    private PlayerType playerType;
    
    private int x;
    private int y;
    
    
    public Player( String name ) {
        this.alive = true;
        this.name = name;
        this.created = new Date();
        this.livesRemaining = new AtomicInteger( 3 );
        this.playerType = PlayerType.Attacker;
    }

    /**
     * Set the position of the player in the game
     * 
     * @param x
     * @param y
     */
    public void setPosition( int x, int y ) {
        this.x = x;
        this.y = y;
    }
    
    /**
     * Get the position of the player. 
     * @return
     *          the coordinates with x at position 0 and y at position 1
     */
    public int[] getPosition( ) {
        return new int[] { x, y };
    }
    
    /**
     * Convert the player to an esobject to be sent to the client
     * @return
     *          An EsObject that represents the data
     */
    public EsObject toEsObject() {
        EsObject obj = new EsObject();
        obj.setString(CoopGameConstants.NAME, name);
        obj.setInteger( CoopGameConstants.PLAYER_TYPE, playerType.ordinal( ) );
        obj.setInteger( CoopGameConstants.LIVES_REMAINING, livesRemaining.get( ) );
        obj.setInteger( CoopGameConstants.X, this.x );
        obj.setInteger( CoopGameConstants.Y, this.y );
        return obj;
    }
    
    /**
     * Get the name of the player
     * @return
     *      The player name
     */
    public String getName() {
        return name;
    }
    
    /**
     * Is the player currently alive
     * @return
     *      True if the player is alive
     */
    public boolean isAlive() {
        return alive;
    }
    
    /**
     * Kill the player
     */
    public void kill( ) {
        livesRemaining.decrementAndGet( );
        this.alive = false;
    }
    
    /**
     * Determine if the player can be revived.  The player can be revived if there are any lives left. 
     * @return
     *          true if the player can be revived.
     */
    public boolean canBeRevived() {
        return livesRemaining.get() > 0;
    }
    
    /**
     * Revive the player
     */
    public void revive() {
        this.alive = true;
    }
    
    /**
     * Get the number of lives the player has remaining
     * @return
     *      the number of lives remaining
     */
    public int getLivesRemaining( ) {
        return livesRemaining.get();
    }
    
    /**
     * Get the type of this player
     * @return
     *          The player type
     */
    public PlayerType getPlayerType() {
        return playerType;
    }
    
    /**
     * Set the player type
     * @param playerType
     */
    public void setPlayerType( PlayerType playerType ) {
        this.playerType = playerType;
    }
    
    /**
     * Get the date that this player was created
     * @return
     */
    public Date getCreated() {
        return created;
    }
    
}
