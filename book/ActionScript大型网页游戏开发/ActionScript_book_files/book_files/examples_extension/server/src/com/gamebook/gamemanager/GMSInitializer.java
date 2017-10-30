package com.gamebook.gamemanager;

import com.electrotank.electroserver4.extensions.Plugin;
import com.electrotank.electroserver4.extensions.PluginLifeCycle;
import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.electrotank.electroserver4.extensions.api.value.ExtensionComponentConfiguration;
import com.electrotank.electroserver4.extensions.api.value.GameConfiguration;
import com.electrotank.electroserver4.extensions.api.value.RoomConfiguration;

public class GMSInitializer implements Plugin, PluginLifeCycle {

    private PluginApi api;

    /**
     * Initializes each minigame's plugin, initial game details, and registers it with
     * the GameManager.
     * 
     * @param ignored could contain the XML parameters from the web admin interface, 
     * but in this case is just ignored
     */
    public void init(EsObjectRO ignored) {
        // use the name of the extension that will contain all the game plugins
        String extensionName = "GameBook";

        // invoke the initialization method for each of your games
        initOneGame(extensionName, "DiggingPlugin2", 4);
        initOneGame(extensionName, "TankGame", 10);
    }

    private void initOneGame(String extensionName, String pluginName, int maxPlayers) {
        ExtensionComponentConfiguration gamePlugin = new ExtensionComponentConfiguration();
        gamePlugin.setExtensionName(extensionName);

        // the handle is the name by which the plugin can be addressed
        // when instantiated in the room
        gamePlugin.setHandle(pluginName);//Name by which the plugin can be addressed when instantiated in the room

        // This needs to be the name of the plugin in the Extension.xml file
        // Usually it is less confusing to just use the same name as the handle
        gamePlugin.setName(pluginName);//Name of the plugin in the Extension.xml file

        // Create the room configuration
        RoomConfiguration roomConfig = new RoomConfiguration();
        roomConfig.setCapacity(maxPlayers);
        roomConfig.setDescription(pluginName + " Multiplayer game");

        //add the game plugin(s)
        roomConfig.addPlugin(gamePlugin);

        // Create the game configuration

        // When a user joins a room there are many events that user can potentially receive. 
        // The default subscriptions for a user joining the game are defined here.
        GameConfiguration gameRoomConfig = new GameConfiguration();
        gameRoomConfig.setReceivingRoomListUpdates(false);
        gameRoomConfig.setReceivingRoomVariableUpdates(false);
        gameRoomConfig.setReceivingUserListUpdates(true);
        gameRoomConfig.setReceivingUserVariableUpdates(true);
        gameRoomConfig.setReceivingVideoEvents(false);
        gameRoomConfig.setRoomConfiguration(roomConfig);

        //Create the default GameDetails object

        // When a game is created it has a game details EsObject associated with it. 
        // This object is publicly seen in the game list, and can be accessed and modified 
        // by the game itself.

        EsObject esob = new EsObject();
        gameRoomConfig.setInitialGameDetails(esob);

        // Register the game
        // Once the game has been registered, users can create a new instance of this game 
        // using the integrated game manager.
        // Plugins can also create a new game and put users into it.

        getApi().registerGameConfiguration(pluginName, gameRoomConfig);

        getApi().getLogger().warn(pluginName + " game registered with GameManager.");
    }


    /**
     * Use this to shut down any threads you created manually, and tell 
     * other plugins that need to know you are shutting down.  In this case, 
     * the method does nothing.
     */
    public void destroy() {
    // do nothing
    }

    public void setApi(PluginApi api) {
        this.api = api;
    }

    public PluginApi getApi() {
        return api;
    }
}
