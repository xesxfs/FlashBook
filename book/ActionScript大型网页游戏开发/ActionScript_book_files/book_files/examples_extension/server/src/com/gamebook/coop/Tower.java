package com.gamebook.coop;

import com.electrotank.electroserver4.extensions.api.value.EsObject;

/**
 * The tower is a toggleable item in the game.  It can be on or off and can be destroyed
 * 
 * @author Scott
 *
 */
public class Tower extends BaseToggleable {

    private Boolean destroyed = false;
    
    public Tower( Integer id ) {
        super( id );
        setDelayMessage( false );
    }

    @Override
    public boolean isOn( ) {
        // the opposite of a gate.  switch down means statue off
        return !destroyed && !super.isOn();
    }

    /**
     * Determine if this tower has been destroyed.
     * 
     * @return true if the tower has been destroyed
     */
    public boolean isDestroyed() {
        return destroyed;
    }
    /**
     * Set wheter this tower has been destroyed
     * @param destroyed
     *              the destroyed state of this tower
     */
    public void setDestroyed( boolean destroyed ) {
        this.destroyed = destroyed;
    }
    
    @Override
    public EsObject toEsObject( ) {
            EsObject esObject = new EsObject( CoopGameConstants.TOWER_ID, getId() );
            esObject.setInteger( CoopGameConstants.TOWER_STATE, isOn( ) ? 1 : 0 );
            return esObject;
    }
}
