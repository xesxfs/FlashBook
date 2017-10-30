package com.gamebook.coop;

import java.util.AbstractMap;
import java.util.concurrent.ConcurrentHashMap;

/**
 * A class to contain information about a switch and what it controls.
 * 
 * @author Scott
 */
public class Switch {

    // a switch can only be off and on
    public static enum SwitchState {
        OFF,
        ON
    }
    
    private final Integer id;
    
    // keep track of what each user is doing with the switch
    private AbstractMap<String, SwitchState> currentStateMap;
    // a switch can control one toggleable
    private Toggleable controlledToggleable;
    // if there is an outstanding call waiting to be made, this is the id
    private Integer scheduledExecutionId = null;
    
    public Switch( Integer id, Toggleable controlledToggleable) {
        this.id = id;
        this.controlledToggleable = controlledToggleable;
        currentStateMap = new ConcurrentHashMap<String, SwitchState>();
    }
    
    /**
     * Determine if there is an outstanding call about this switch waiting to be made.
     * @return true if there is a call waiting to be sent.
     */
    public boolean hasOutstandingExecution( ) {
        return scheduledExecutionId != null;
    }
    /**
     * Get the id of the scheduled execution
     * @return the id of the scheduled execution
     */
    public int getScheduledExecutionId( ) {
        return this.scheduledExecutionId;
    }
    /**
     * Set the scheduled execution id
     * @param scheduledExecutionId
     *          The id of the scheduled execution waiting
     */
    public void setScheduledExecutionId( Integer scheduledExecutionId ) {
        this.scheduledExecutionId = scheduledExecutionId;
    }
    
    /**
     * Get the id of this switch
     * @return
     *          The id
     */
    public Integer getId( ) {
        return id;
    }
    /**
     * Set the state of this switch.  Each player can have an affect on the switch at the same time
     * @param playerName
     *          The player that has done something with the switch
     * @param newState
     *          The new state of the switch
     */
    public void setState( String playerName, SwitchState newState ) {
        currentStateMap.put( playerName, newState );
    }
    
    /**
     * Determine if this switch is on.  If any player is currently on the switch
     * then the switch is On
     * @return
     *          True if this switch is on
     */
    public boolean isOn( ) {
        for ( SwitchState state : currentStateMap.values( ) ) {
            if ( state.equals( SwitchState.ON ) ) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Get the state of the switch.
     * @return
     *          The SwitchState representing the state of the switch
     */
    public SwitchState getSwitchState( ) {
        return isOn() ? SwitchState.ON : SwitchState.OFF;
    }
    
    /**
     * Get the toggleable that this switch controls.
     * @return
     *          The Toggleable 
     */
    public Toggleable getToggleable( ) {
        return controlledToggleable;
    }
}
