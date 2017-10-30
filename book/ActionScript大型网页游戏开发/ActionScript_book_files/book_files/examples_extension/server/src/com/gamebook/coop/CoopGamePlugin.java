package com.gamebook.coop;

import java.util.AbstractMap;
import java.util.AbstractSet;
import java.util.HashSet;
import java.util.concurrent.ConcurrentHashMap;

import com.electrotank.electroserver4.extensions.BasePlugin;
import com.electrotank.electroserver4.extensions.ChainAction;
import com.electrotank.electroserver4.extensions.api.ScheduledCallback;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.electrotank.electroserver4.extensions.api.value.UserEnterContext;
import com.gamebook.coop.Player.PlayerType;
import com.gamebook.coop.Switch.SwitchState;

/**
 * This plugin is the main plugin for the game. All communication from the client will come through this plugin.
 */
public class CoopGamePlugin extends BasePlugin {

    private AbstractMap<String, Player> playerInfoMap;
    private AbstractMap<Integer, Switch> switchesMap;
    private AbstractMap<Integer, Rock> rocksMap;
    private AbstractMap<Integer, Tower> towerMap;
    // store the player names that are on the level complete switch
    private AbstractSet<String> levelComplete;
    
    private boolean levelInitialized = false;
    private int levelNumber;
    private int spawnX;
    private int spawnY;
    
    @Override
    public void init( EsObjectRO ignored ) {
        playerInfoMap = new ConcurrentHashMap<String, Player>( );
        switchesMap = new ConcurrentHashMap<Integer, Switch>();
        rocksMap = new ConcurrentHashMap<Integer, Rock>();
        towerMap = new ConcurrentHashMap<Integer, Tower>();
        levelComplete = new HashSet<String>();
    }

    @Override
    public ChainAction userEnter( UserEnterContext context ) {
        String playerName = context.getUserName( );
        getApi( ).getLogger( ).debug( "userEnter: " + playerName );
        return ChainAction.OkAndContinue;
    }

    @Override
    public void userExit( String playerName ) {
        if ( playerInfoMap.containsKey( playerName ) ) {
            playerInfoMap.remove( playerName );
        }
        EsObject message = new EsObject( );
        message.setString( CoopGameConstants.ACTION, CoopGameConstants.REMOVE_PLAYER );
        message.setString( CoopGameConstants.NAME, playerName );
        sendAndLog( "userExit", message );
    }

    @Override
    public void request( String playerName, EsObjectRO requestParameters ) {
        EsObject messageIn = new EsObject( );
        messageIn.addAll( requestParameters );
        getApi( ).getLogger( ).debug( "{} requests: {}", playerName, messageIn.toString( ) );

        String action = messageIn.getString( CoopGameConstants.ACTION, null );

        if ( null == action ) {
            sendErrorMessage( playerName, CoopGameConstants.INVALID_ACTION, "The action you sent is empty" );
            return;
        }

        if ( CoopGameConstants.POSITION_UPDATE.equals( action ) ) { // frequent
            handlePositionUpdate( playerName, messageIn );
        }
        else if ( CoopGameConstants.PLAYER_DIED.equals( action ) ) {
            handleAutopsy( playerName, messageIn );
        }
        else if ( CoopGameConstants.FLIP_SWITCH.equals( action ) ) {
            handleFlipSwitch( playerName, messageIn );
        }
        else if ( CoopGameConstants.PUSH_ROCK.equals( action ) ) {
            handlePushRock( playerName, messageIn );
        }
        else if ( CoopGameConstants.PLAYER_LIST.equals( action ) ) {
            sendPlayerList( playerName );
        }
        else if ( CoopGameConstants.DESTROY_TOWER.equals( action ) ) {
            handleDestroyTower( playerName, messageIn );
        }
        else if ( CoopGameConstants.UPDATE_SPAWN_LOCATION.equals( action ) ) {
            handleUpdateSpawnLocation( messageIn );
        }
        else if ( CoopGameConstants.INIT_ME.equals( action ) ) { // infrequent
            handlePlayerInitRequest( playerName );
        } 
        else if ( CoopGameConstants.INIT_LEVEL.equals( action ) ) {
            initializeLevel( playerName, messageIn );
        }
        else if ( CoopGameConstants.LEVEL_COMPLETE.equals( action ) ) {
            handleLevelComplete( playerName, messageIn );
        }
        else {
            sendErrorMessage( playerName, CoopGameConstants.INVALID_ACTION, "The action you sent ("+action+") me is unknown or not implemented"  );
        }
    }

    /**
     * Handle a player moving around the game.  Primarily just pass the data through and send to all clients but also
     * keep track of where the player is.
     * 
     * @param playerName
     *          The player who sent the message to the server
     * @param messageIn
     *          The message that was sent from the client
     */
    private void handlePositionUpdate( String playerName, EsObject messageIn ) {
        if ( !levelInitialized ) {
            getApi().getLogger().debug( "{} tried to move when the level is not initialized" );
            sendErrorMessage( playerName, CoopGameConstants.LEVEL_NOT_INITIALIZED, "You are trying to move and the level is not initialized"  );
            return;
        }
        
        // get the player and set the new position
        Player player = playerInfoMap.get( playerName );
        player.setPosition( messageIn.getInteger( CoopGameConstants.X ), messageIn.getInteger( CoopGameConstants.Y) );
        
        relayMessage( playerName, messageIn );
    }
    
    /**
     * Handle a player's death.  If the player can be revived then delay a revival message by 2 seconds. 
     * If the player can't be revived then send a game over message
     * 
     * @param playerName
     *          The player who died
     * @param messageIn
     *          The message that was sent to the server
     */
    private void handleAutopsy( String playerName, EsObject messageIn ) {
        getApi( ).getLogger( ).debug( "{} has gone to a better place.", playerName );
        
        Player player = playerInfoMap.get( playerName );
        player.kill( );
        
        // relay the message that this player died
        relayMessage( playerName, messageIn );
        
        // if the player can be revived then send the revival in 2 seconds
        if ( player.canBeRevived( ) ) {
            // revive the player in 2 seconds
            final Player playerToRevive = player; 
            getApi().scheduleExecution(
                    2000,
                    1,
                    new ScheduledCallback() {
                        
                        public void scheduledCallback() {
                            healPlayer( playerToRevive );
                        }
                    });
        } else {
            // game over if they can't be revived
            EsObject esObject = new EsObject( );
            esObject.setString( CoopGameConstants.ACTION, CoopGameConstants.GAME_OVER );
            relayMessage( playerName, esObject );
        }
        
    }

    /**
     * Handle the flipping of a switch in the game.  The switch controls a Toggleable.  The new state is returned
     * to the clients
     * 
     * @param playerName
     *          The player who flipped the switch
     * @param messageIn
     *          The message that was sent to the server
     */
    private void handleFlipSwitch( final String playerName, final EsObject messageIn ) {
        getApi( ).getLogger( ).debug( "{} has flipped a switch.", playerName );
        
        // update the switch with the information about who switched it and what the new state is
        Switch affectedSwitch = switchesMap.get( messageIn.getInteger( CoopGameConstants.SWITCH_ID ) );
        affectedSwitch.setState( playerName, SwitchState.values( )[messageIn.getInteger( CoopGameConstants.SWITCH_STATE ) ] );
        messageIn.setInteger( CoopGameConstants.SWITCH_STATE, affectedSwitch.getSwitchState(  ).ordinal( ) );
        
        // send information about the affected gate along with the switch information
        messageIn.setEsObject( CoopGameConstants.SWITCH_RESULTS, affectedSwitch.getToggleable().toEsObject( ) );

        // delay the message only if the gate says to and the switch is being turned on
        boolean delayMessage = affectedSwitch.getToggleable( ).delayMessage( ) && affectedSwitch.isOn( ) ;
        
        // send to all players
        if ( !delayMessage ) {
            // cancel any outstanding executions that may be lingering
            if ( affectedSwitch.hasOutstandingExecution( ) ) {
                getApi().cancelScheduledExecution( affectedSwitch.getScheduledExecutionId( ) );
                affectedSwitch.setScheduledExecutionId( null );
            }
            
            relayMessage( playerName, messageIn );
        } else {
            // delay one second if the switch is turned on
            int scheduledExecutionId = getApi().scheduleExecution(
                    1000,
                    1,
                    new ScheduledCallback() {
                        
                        public void scheduledCallback() {
                            relayMessage( playerName, messageIn );
                        }
                    });
            affectedSwitch.setScheduledExecutionId( scheduledExecutionId );
        }
    }

    /**
     * Handle the pushing of a rock in the game.  Both players must push the rock before it can be moved.
     * 
     * @param playerName
     *          The player who has started or stopped pushing the rock
     * @param messageIn
     *          The original message sent to the server
     */
    private synchronized void handlePushRock( String playerName, EsObject messageIn ) {
        getApi( ).getLogger( ).debug( "{} is pushing a rock.", playerName );
        
        Integer rockId = messageIn.getInteger( CoopGameConstants.ROCK_ID );
        String direction = messageIn.getString( CoopGameConstants.DIRECTION, null );
        
        Rock rock = rocksMap.get( rockId );
        rock.pushRock( playerName, direction );
        
        // if we were provided new x and y coords then set them
        if ( messageIn.variableExists( CoopGameConstants.X  ) && messageIn.variableExists( CoopGameConstants.Y ) ) {
            int x = messageIn.getInteger( CoopGameConstants.X );
            int y = messageIn.getInteger( CoopGameConstants.Y  );
            rock.setLocation( x, y );
        }
        
        // send to all players if both players are pushing the rock in the same direction
        if ( rock.canBeMoved( ) ) {
            relayMessage( playerName, messageIn );
        }
    }

    /**
     * Handle the utter destruction of a game tower.  
     * 
     * @param playerName
     *          The player to destroyed the tower
     * @param messageIn
     *          The original message sent to the server
     */
    private void handleDestroyTower( final String playerName, final EsObject messageIn ) {
        getApi().getLogger().debug( " {} destroyed the tower", playerName );
        
        Integer towerId = messageIn.getInteger( CoopGameConstants.TOWER_ID );
        Tower tower = towerMap.get( towerId );
        
        // do not do anything if the tower is already destroyed
        if ( !tower.isDestroyed( ) ) {
            tower.setDestroyed( true );
            
            // delay one second if the switch is turned on
            getApi().scheduleExecution(
                    1000,
                    1,
                    new ScheduledCallback() {
                        
                        public void scheduledCallback() {
                            relayMessage( playerName, messageIn );
                        }
                    });
        }
    }
    
    /** 
     * Heal a player who has died and can be revived
     * 
     * @param player
     *          The player to heal
     */
    void healPlayer( Player player ) {
        getApi( ).getLogger( ).debug( "{} has been healed and respawned.", player.getName() );
        
        // set the new spawn position
        player.setPosition( spawnX, spawnY );
        
        // send a revival message to the clients with the player being revived, the spawn location and the lives remaining
        EsObject message = new EsObject( CoopGameConstants.ACTION, CoopGameConstants.REVIVE_ME );
        message.setInteger( CoopGameConstants.X, spawnX );
        message.setInteger( CoopGameConstants.Y, spawnY );
        message.setInteger( CoopGameConstants.LIVES_REMAINING, player.getLivesRemaining( ) );

        relayMessage( player.getName( ), message );
    }
    
    /**
     * Send the player list to the players specified
     * @param playerNames
     *      The players we are going to send the message to
     */
    private void sendPlayerList( String... playerNames ) {
        getApi( ).getLogger( ).debug( "{} requested a player list.", playerNames );

        // send the user the full user list
        EsObject message = new EsObject( CoopGameConstants.ACTION, CoopGameConstants.PLAYER_LIST );
        message.setEsObjectArray( CoopGameConstants.PLAYER_LIST, getFullPlayerList() );
        getApi( ).sendPluginMessageToUsers( playerNames, message );
        getApi( ).getLogger( ).debug( "Message sent to " + playerNames + ": " + message.toString( ) );
    }

    /**
     * Initialize a player.  This must be called after initializing the level but before gameplay
     * @param playerName
     *          The player name to use for the new player
     */
    private synchronized void handlePlayerInitRequest( String playerName ) {
        // fail if the level isn't initialized first
        if ( !levelInitialized ) {
            sendErrorMessage( playerName, CoopGameConstants.LEVEL_NOT_INITIALIZED, "The level must be initialized before players" );
            return;
        }
        // only allow two players
        if ( playerInfoMap.size( ) >= 2 ) {
            sendErrorMessage( playerName, CoopGameConstants.GAME_FULL, "The game is already full." );
            return;
        }

        // create the player and add them to the list
        Player player = new Player( playerName );
        player.setPlayerType( PlayerType.values( )[playerInfoMap.size( )] );
        player.setPosition( spawnX, spawnY );
        
        // send the notfication to the other player
        EsObject message = new EsObject( CoopGameConstants.ACTION, CoopGameConstants.ADD_PLAYER );
        message.setEsObject( CoopGameConstants.PLAYER, player.toEsObject( ) );
        sendAndLog( "addUser", message );

        playerInfoMap.put( playerName, player );

        sendPlayerList( playerName );
    }
    
    /**
     * If the users pass a save point then update the revival spawn point.
     * 
     * @param messageIn
     *          The original message to the server
     */
    private synchronized void handleUpdateSpawnLocation( EsObject messageIn ) {
        getApi().getLogger().debug( "Update spawn location" );
        spawnX = messageIn.getInteger( CoopGameConstants.X );
        spawnY = messageIn.getInteger( CoopGameConstants.Y );
    }
    
    /**
     * Initialize the level.  The client must send all the details about the level before we can 
     * begin gameplay.
     * 
     * @param playerName
     *          the player initializing the level
     * @param messageIn
     *          the EsObject that contains all the level details
     */
    private synchronized void initializeLevel( String playerName, EsObject messageIn ) {

        if ( !levelInitialized ) {
            levelNumber = messageIn.getInteger( CoopGameConstants.LEVEL_NUMBER, 1 );
            spawnX = messageIn.getInteger( CoopGameConstants.X, 10 );
            spawnY = messageIn.getInteger( CoopGameConstants.Y, 10 );
            
            // initialize the gates in this level.  Each gate will be controlled by one or more switches
            if ( messageIn.variableExists( CoopGameConstants.LEVEL_GATES ) ) {
                EsObject[] gates = messageIn.getEsObjectArray( CoopGameConstants.LEVEL_GATES );
                for ( EsObject esGate : gates ) {
                    Gate gate = new Gate( esGate.getInteger( CoopGameConstants.GATE_ID ) );
                    int[] switches = esGate.getIntegerArray( CoopGameConstants.LEVEL_GATE_SWITCHES );
                    for ( int esSwitchId : switches ) {
                        Switch gateSwitch = new Switch( esSwitchId, gate );
                        gate.addSwitch( gateSwitch );
                        switchesMap.put( esSwitchId, gateSwitch );
                    }
                }
            }
            
            // initialize the towers in this level.  Each tower will be controlled by one or more switches
            if ( messageIn.variableExists( CoopGameConstants.LEVEL_TOWERS ) ) {
                EsObject[] towers = messageIn.getEsObjectArray( CoopGameConstants.LEVEL_TOWERS );
                for ( EsObject esTower : towers ) {
                    Tower tower = new Tower( esTower.getInteger( CoopGameConstants.TOWER_ID ) );
                    int[] switches = esTower.getIntegerArray( CoopGameConstants.LEVEL_TOWER_SWITCHES );
                    for ( int switchId : switches ) {
                        Switch towerSwitch = new Switch( switchId, tower );
                        tower.addSwitch( towerSwitch );
                        switchesMap.put( switchId, towerSwitch );
                    }
                    towerMap.put( tower.getId(), tower );
                }
            }

            // initialize the rocks in this level.  
            if ( messageIn.variableExists( CoopGameConstants.LEVEL_ROCKS ) ) {
                int[] rockIds = messageIn.getIntegerArray( CoopGameConstants.LEVEL_ROCKS );
                for ( int rockId : rockIds ) {
                    Rock rock = new Rock( rockId );
                    rock.setLocation( messageIn.getInteger( CoopGameConstants.X ), messageIn.getInteger( CoopGameConstants.Y ) );
                    rocksMap.put( rockId, rock );
                }
            }
            
            levelInitialized = true;
            getApi().getLogger().debug( "Initialized level {}", levelNumber );
        }

        // return a message to the client so we know that the leve is intiialized
        EsObject message = new EsObject( CoopGameConstants.ACTION, CoopGameConstants.INIT_LEVEL );
        message.setBoolean( CoopGameConstants.SUCCESS, true );
        getApi().sendPluginMessageToUser( playerName, message );
    }

    /**
     * Handle an event where a player is completing the level.  Both players must be on the switch
     * to complete the level so we must keep track of when they step on and off.  If both players are
     * on the switch then we will clear the level and send a message to the client
     * 
     * @param playerName
     *          the player who stepped on or off the level complete switch
     * @param messageIn
     *          the EsObject that contains the details for the call
     */
    private synchronized void handleLevelComplete( String playerName, EsObject messageIn ) {

        // keep track of who is on  the switch
        int switchState = messageIn.getInteger( CoopGameConstants.SWITCH_STATE );
        if ( Switch.SwitchState.ON.ordinal( ) == switchState ) {
            levelComplete.add( playerName );
        } else {
            levelComplete.remove( playerName );
        }
        
        getApi().getLogger().debug( "{} completed the level making it {} total players completing", playerName, levelComplete.size() );
        
        // if both players are on the switch then clear the level and send a message to the clients
        if ( levelComplete.size() == 2 ) {
            sendAndLog( "levelComplete", messageIn );

            playerInfoMap = new ConcurrentHashMap<String, Player>( );
            switchesMap = new ConcurrentHashMap<Integer, Switch>();
            rocksMap = new ConcurrentHashMap<Integer, Rock>();
            levelComplete = new HashSet<String>();
            spawnX = 0;
            spawnY = 0;
            
            levelInitialized = false;
        }
        
    }
    
    /**
     * Get the player list for players currently in the game.
     * 
     * @return an EsObject array containing details for all players currently in the game
     */
    private synchronized EsObject[] getFullPlayerList() {
        EsObject[] list = new EsObject[playerInfoMap.size( )];
        int ptr = 0;
        for ( Player pInfo : playerInfoMap.values( ) ) {
            list[ptr++] = new EsObject( CoopGameConstants.PLAYER, pInfo.toEsObject( ) );
        }
        return list;
    }

    /**
     * Relay a message to the clients.  Add in the player who originally sent the message and the timestamp of the relay.
     * 
     * @param playerName
     *          The player who sent the message to the server
     * @param messageIn
     *          The original (possibly modified) message sent to the server
     */
    void relayMessage( String playerName, EsObject messageIn ) {
        messageIn.setString( CoopGameConstants.NAME, playerName );
        messageIn.setString( CoopGameConstants.TIME_STAMP, String.valueOf( System.currentTimeMillis( ) ) );
        sendAndLog( "relayMessage", messageIn );
    }

    /**
     * Send a message to all users in the game and log the message.
     * 
     * @param fromMethod
     *          The method that called the send
     * @param message
     *          The message to send
     */
    private void sendAndLog( String fromMethod, EsObject message ) {
        getApi().getLogger().debug( "Sending to {} players", playerInfoMap.size( )  );
        
        getApi( ).sendPluginMessageToUsers( playerInfoMap.keySet( ), message );
        getApi( ).getLogger( ).debug( fromMethod + ": " + message.toString( ) );
    }

    /**
     * Send an error message to the client user that sent the message that failed.
     * @param playerName
     *          The player that caused the error
     * @param error
     *          The error code 
     * @param description
     *          A quick description of the error for debugging 
     */
    private void sendErrorMessage( String playerName, String error, String description ) {
        EsObject message = new EsObject( );
        message.setString( CoopGameConstants.ACTION, CoopGameConstants.ERROR );
        message.setString( CoopGameConstants.ERROR_CODE, error );
        message.setString( CoopGameConstants.ERROR_DESCRIPTION, description );
        getApi( ).sendPluginMessageToUser( playerName, message );
        getApi( ).getLogger( ).debug( "Message sent to " + playerName + ": " + message.toString( ) );
    }

}
