package com.gamebook.oldworld;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.electrotank.electroserver4.extensions.EventHandlerLifeCycle;
import com.electrotank.electroserver4.extensions.api.EventApi;

public class AbstractLoginLogoutEventHandler extends AbstractExtension<EventApi> implements EventHandlerLifeCycle {
    @SuppressWarnings( { "NonConstantLogger" } )
    protected final Logger logger = LoggerFactory.getLogger( getClass() );

}
