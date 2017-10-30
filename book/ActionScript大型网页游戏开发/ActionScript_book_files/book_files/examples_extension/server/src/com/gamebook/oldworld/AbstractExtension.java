package com.gamebook.oldworld;

import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.electrotank.electroserver4.extensions.api.ElectroServerApi;
import com.electrotank.electroserver4.extensions.ExtensionLifeCycle;
import com.electrotank.electroserver4.extensions.api.value.EsObject;

public abstract class AbstractExtension<T extends ElectroServerApi> implements ExtensionLifeCycle {
    private T api;
    private Controller controller;

    @Override
    public void init( EsObjectRO esObjectRO ) {
        controller = (Controller) api.acquireManagedObject( ExtensionBoundField.ControllerFactory.name(),
                new EsObject(ExtensionBoundField.ObjectName.toString(), ExtensionBoundField.Controller.name()));
    }

    @Override
    public void destroy() {
        // Handle destruction
    }
    
    protected final Controller getController() {
        return controller;
    }

    public final T getApi() {
        return api;
    }

    public final void setApi( T api ) {
        this.api = api;
    }
}
