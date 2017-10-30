package com.gamebook.coop;

import java.util.List;

import com.electrotank.electroserver4.extensions.api.value.EsObject;

/**
 * This interface is used for coop game object that can be turned off/on, open/closed, etc
 * 
 * @author Scott
 *
 */
public interface Toggleable {

    /**
     * Get the id of the Toggleable
     * @return an integer id
     */
    public abstract Integer getId();
    
    /**
     * Do we delay sending the message that this toggleable is on/open?
     * 
     * @return true if we need to delay sending
     */
    public abstract boolean delayMessage();
    
    /**
     * Set whether or not we need to delay sending the message that this toggleable is on/open.
     * 
     * @param delayMessage
     *          boolean representing whether or not we should delay sending
     */
    public abstract void setDelayMessage( boolean delayMessage );
    
    /**
     * Add a switch that controls this toggleable.
     * 
     * @param toggleableSwitch
     *          A Switch object
     */
    public abstract void addSwitch( Switch toggleableSwitch );
    
    /**
     * Get the switches that control this toggleable
     *  
     * @return a list of Switch objects
     */
    public abstract List<Switch> getSwitches();
    
    /**
     * Get a specific switch for this toggleable by id
     * 
     * @param switchId
     *          the id of the switch we are looking for
     * @return the switch if found, otherwise null
     */
    public abstract Switch getSwitch( Integer switchId );
    
    /**
     * Convert this toggleable to an EsObject to send to the client
     * 
     * @return an EsObject representing this toggleable data
     */
    public abstract EsObject toEsObject();
}
