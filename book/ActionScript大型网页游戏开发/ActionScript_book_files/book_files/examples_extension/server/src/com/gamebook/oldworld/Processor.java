package com.gamebook.oldworld;

import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;

/**
 * Interface for a component that is responsible for processing an incoming message
 *
 */
public interface Processor {

    /**
     * Get the command used to invoke this processor
     *
     * @return Command used to invoke this processor. Never null.
     */
    String getCommand();

    /**
     * Get the user type allowed to invoke this processor
     *
     * @return UserType that can nvoke this processor. Never null.
     */
    UserType getAllowedUserType();
    
    /**
     * Process a message
     *
     * @param user    The current user
     * @param message Message details
     * @param api     Plugin API for this call
     */
    void process( String user, EsObjectRO message, PluginApi api );
}
