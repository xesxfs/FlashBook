package com.gamebook.coop;

import com.electrotank.electroserver4.extensions.api.value.EsObject;

/**
 * A gate is an object in the game that is toggleable and can be open or closed.
 * @author Scott
 */
public class Gate extends BaseToggleable{

    
    public Gate( Integer id ) {
        super( id );
        setDelayMessage( true );
    }
    
    /**
     * Determine if the gate is currently open
     * @return
     *          true if the gate is open
     */
    public boolean isOpen( ) {
        return super.isOn();
    }
    
    @Override
    public EsObject toEsObject( ) {
        EsObject esObject = new EsObject( CoopGameConstants.GATE_ID, getId() );
        esObject.setInteger( CoopGameConstants.GATE_STATE, isOn( ) ? 0 : 1 );
        return esObject;
    }
}
