package com.gamebook.coop;

import java.util.ArrayList;
import java.util.List;

/**
 * This base toggleable does most of what we want with a toggleable.
 * 
 * @author Scott
 */
public abstract class BaseToggleable implements Toggleable {

    private final Integer id;
    private boolean delayMessage = true;
    
    private List<Switch> switches = new ArrayList<Switch>();;
    
    public BaseToggleable( Integer id ) {
        this.id = id;
    }

    @Override
    public void setDelayMessage( boolean delay ) {
        this.delayMessage = delay;
    }
    
    @Override
    public Integer getId( ) {
        return id;
    }
    
    @Override
    public boolean delayMessage( ) {
        return delayMessage;
    }
    
    @Override
    public synchronized void addSwitch( Switch gateSwitch ) {
        switches.add( gateSwitch );
    }
    
    @Override
    public List<Switch> getSwitches( ) {
        return switches;
    }
    
    @Override
    public synchronized Switch getSwitch( Integer switchId ) {
        for ( Switch gateSwitch : switches ) {
            if ( gateSwitch.getId( ).equals( switchId ) ) {
                return gateSwitch;
            }
        }
        return null;
    }
    
    /**
     * Determine if the toggleable is currently on
     * @return
     *      true if any one of the switches is on
     */
    public synchronized boolean isOn( ) {
        for ( Switch toggleableSwitch : getSwitches() ) {
            if ( toggleableSwitch.isOn() ) {
                return true;
            }
        }
        return false;
    }
    
}
