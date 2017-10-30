package com.gamebook.oldworld;

import com.electrotank.electroserver4.extensions.PluginRequest;
import com.electrotank.electroserver4.extensions.api.ExtensionBoundUserServerVariableResponse;
import com.electrotank.electroserver4.extensions.api.PluginApiResponse.Status;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;

public class WorldPlugin extends AbstractPlugin implements PluginRequest {

    @Override
    public void request( String user, EsObjectRO message ) {

        // Useful logging if there are issues with messaging
        if(getApi().getLogger().isDebugEnabled()) {
            EsObject obj = (EsObject) message;
            getApi().getLogger().debug("WorldPlugin.request from " + user + ": " + obj.toString());
        }

        // Look up the user type for this user
        UserType type = null;
        ExtensionBoundUserServerVariableResponse response = getApi().getExtensionBoundUserServerVariable(user, ExtensionBoundField.UserType.name());
        if(response.getStatus() == Status.Success) {
            type = (UserType) response.getValue();
        } else {
            throw new RuntimeException("Unable to locate UserType in session!");
        }


        getApi().getLogger().debug("controller == null? " + (getController() == null));
        // pass the message to the correct processor
        getController().handleRequest( user, type, message, getApi() );
    }

}
