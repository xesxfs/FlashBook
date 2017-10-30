package com.gamebook.tank;

import com.gamebook.collision.Collision;
import com.electrotank.electroserver4.extensions.BasePlugin;
import com.electrotank.electroserver4.extensions.ChainAction;
import com.electrotank.electroserver4.extensions.api.ScheduledCallback;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.electrotank.electroserver4.extensions.api.value.UserEnterContext;
import com.electrotank.electroserver4.extensions.api.value.Number;
import com.gamebook.collision.LineSegment;
import com.gamebook.util.GameState;
import com.gamebook.util.Utility;
import java.awt.Point;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class TankGame extends BasePlugin {
    // variables
    private AbstractMap<String, PlayerInfo> playerInfoMap;
    private AbstractMap<Integer, Projectile> bulletMap;
    private AbstractMap<Point, Integer> callbacks;
    private GameState gameState;
    private int callbackId = -1;
    private long startTime = 0;
    private Map map;
    private final Lock collisionHandlerLock = new ReentrantLock(true);

    // change to false to have server check for obstacles in a tank's path
    private boolean skipIsTankPathValidation = true;
    
    @Override
    public void init(EsObjectRO ignored) {
        playerInfoMap = new ConcurrentHashMap<String, PlayerInfo>();
        bulletMap = new ConcurrentHashMap<Integer, Projectile>();
        callbacks = new ConcurrentHashMap<Point, Integer>();
        gameState = GameState.WaitingForPlayers;
        EsObject gameDetails = getApi().getGameDetails();
        getApi().getLogger().debug("gameDetails: " + gameDetails.toString());
        EsObject mapObj = gameDetails.getEsObject(PluginConstants.MAP, null);
        if (mapObj == null) {
            map = new Map(playerInfoMap);
        } else {
            map = new Map(mapObj, playerInfoMap);
        }
        map.setBulletMap(bulletMap);
    }

    @Override
    public ChainAction userEnter(UserEnterContext context) {
        String playerName = context.getUserName();
        boolean ok = okForPlayerToEnter();
        if (ok) {
            getApi().getLogger().debug("userEnter: " + playerName);
            return ChainAction.OkAndContinue;
        } else {
            getApi().getLogger().debug("Game refused to let " + playerName + " join.");
            return ChainAction.Fail;
        }
    }

    private int getCountdownLeft() {
        long now = System.currentTimeMillis();
        long elapsedMillis = now - startTime;
        long millisLeft = PluginConstants.COUNTDOWN_SECONDS * 1000 - elapsedMillis;
        return (int) (millisLeft / 1000);
    }

    private void handleCollectPowerup(String playerName, EsObject messageIn) {
        int id = messageIn.getInteger(PluginConstants.ITEM_ID, -1);
        long time = Utility.getLongFromNumber(PluginConstants.TIME_STAMP, messageIn);
        PlayerInfo pInfo = playerInfoMap.get(playerName);
        if (pInfo == null) {
            return;     // ignore request from non-player
        }
        Powerup powerup = map.playerGrabsPowerup(id, pInfo, time);
        if (powerup == null) {
            sendErrorMessage(playerName, "PowerupNotAvailable");
        } else {
            // success!
            messageIn.setString(PluginConstants.POWERUP_TYPE, powerup.getType());
            messageIn.setString(PluginConstants.NAME, playerName);
            sendAndLog("handleCollectPowerup", messageIn, false);

            if (powerup.getType().equals(PluginConstants.POWERUP_HEALTH)) {
                updateHealth(pInfo);
            }
            queueNewPowerup(powerup);
        }
    }

    private void handleCollision(Collision collision) {
        collision.executeHit(getApi().getLogger());
        EsObject message = collision.toEsObject();
        sendAndLog("handleCollision", message, false);

        if (collision.isTankKilled()) {
            handleTankKilled(collision);
        }
    }

    private void handleMiss(Projectile bullet) {
        EsObject message = Collision.getMissMessage(bullet);
        sendAndLog("handleMiss", message, false);
    }

    private void handleHeadingUpdate(String playerName, EsObject messageIn) {
        EsObject newHeading = messageIn.getEsObject(PluginConstants.HEADING);
        PlayerInfo pInfo = null;
        pInfo = playerInfoMap.get(playerName);
        Heading newHeadingObject = new Heading(newHeading);
        getApi().getLogger().debug(newHeadingObject.toEsObject().toString());
        try {
            Heading oldHeading = pInfo.getHeading();
            if (oldHeading == null || oldHeading.isValidPositionAtTime(newHeading)) {
                newHeadingObject.updatePath();
                LineSegment path = newHeadingObject.getPath();
                if (skipIsTankPathValidation || map.isTankPathValid(path)) {
                    getApi().getLogger().debug("valid heading! ");
                    pInfo.setHeading(newHeadingObject);
                } else {
                    sendErrorMessage(playerName, "CollisionDetected");
                    return;
                }
            } else {
                EsObject message = new EsObject();
                message.setString(PluginConstants.ACTION, PluginConstants.ERROR);
                message.setString(PluginConstants.ERROR, "InvalidHeadingUpdate");
                message.setEsObject(PluginConstants.HEADING, oldHeading.toEsObject());
                getApi().sendPluginMessageToUser(playerName, message);
                getApi().getLogger().debug("Message sent to " + playerName + ": " + message.toString());
                return;
            }
        } catch (Exception e) {
            getApi().getLogger().error("handleHeadingUpdate: Error reading Heading");
            return;
        }
        messageIn.setString(PluginConstants.NAME, playerName);
        messageIn.setNumber(PluginConstants.TIME_STAMP, new Number(System.currentTimeMillis()));
        messageIn.setEsObject(PluginConstants.HEADING, pInfo.getHeading().toEsObject());
        sendAndLog("handleHeadingUpdate", messageIn, false);

        checkForCollisions();
    }

    private void handleShootRequest(String playerName, EsObject messageIn) {
        EsObject bulletHeading = messageIn.getEsObject(PluginConstants.HEADING);
        PlayerInfo pInfo = null;
        Projectile bullet = new Projectile(playerName, bulletHeading);
        getApi().getLogger().debug("bullet: " + bullet.toEsObject().toString());
        pInfo = playerInfoMap.get(playerName);
        try {
            Heading tankHeading = pInfo.getHeading();
            if (tankHeading == null || bullet.isValidStartPosition(tankHeading, getApi().getLogger())) {
                getApi().getLogger().debug("approved!");
                // Approved!
                bullet.getCollisionWithObstacles(map, getApi().getLogger());
                bulletMap.put(bullet.getId(), bullet);
//                logAllTankPositions(bullet.getTimestamp());
            } else {
                EsObject message = new EsObject();
                message.setString(PluginConstants.ACTION, PluginConstants.ERROR);
                message.setString(PluginConstants.ERROR, "InvalidShootRequest");
                message.setEsObject(PluginConstants.HEADING, tankHeading.toEsObject());
                getApi().sendPluginMessageToUser(playerName, message);
                getApi().getLogger().debug("Message sent to " + playerName + ": " + message.toString());
                return;
            }
        } catch (Exception e) {
            getApi().getLogger().error("handleShootRequest: Error reading Projectile");
            return;
        }

        messageIn.setString(PluginConstants.NAME, playerName);
        messageIn.setInteger(PluginConstants.ITEM_ID, bullet.getId());
        messageIn.setNumber(PluginConstants.TIME_STAMP, new Number(System.currentTimeMillis()));
        messageIn.setEsObject(PluginConstants.HEADING, bullet.toEsObject());
        sendAndLog("handleShootRequest", messageIn, false);

    }

    private void handleTankKilled(Collision collision) {
        PlayerInfo vInfo = collision.getTank();
        handleTankKilled(vInfo);
        String killedBy = collision.getBullet().getPlayerWhoFired();
        PlayerInfo pInfo = playerInfoMap.get(killedBy);
        if (pInfo != null) {
            pInfo.incrementNumKills();
        }

    // We decided not to broadcast the update about number of kills
    }

    private void logAllTankPositions(long timestamp) {
        EsObject obj =  new EsObject();
        obj.setEsObjectArray("ul", getFullPlayerList());
        getApi().getLogger().debug("logAllTankPositions: " + obj.toString());
        for (PlayerInfo pInfo : playerInfoMap.values()) {
            getApi().getLogger().debug("processing " + pInfo.getPlayerName());
            Heading heading = pInfo.getHeading();
            Point point = heading.getCurrentPositionAtTime(timestamp, getApi().getLogger());
            getApi().getLogger().debug("player, current x, y: " + pInfo.getPlayerName()
                    + ", " + point.getX() + ", " + point.getY());
        }
    }

    private void queueNewPowerup(Powerup powerup) {
        final Point point = new Point(powerup.getX(), powerup.getY());
        int id = getApi().scheduleExecution(PluginConstants.POWERUP_RESPAWN_MS,
                1,
                new ScheduledCallback() {

                    public void scheduledCallback() {
                        respawnPowerup(point);
                    }
                });
        callbacks.put(point, id);
    }

    private void respawnPowerup(Point point) {
        Powerup powerup = map.respawnPowerup(point);
        if (powerup != null) {
            EsObject obj = new EsObject();
            obj.setString(PluginConstants.ACTION, PluginConstants.SPAWN_POWERUP);
            obj.setEsObject(PluginConstants.SPAWN_POWERUP, powerup.toEsObject());
            obj.setNumber(PluginConstants.TIME_STAMP, new Number(System.currentTimeMillis()));
            sendAndLog("respawnPowerup", obj, false);
        }
        callbacks.remove(point);
    }

    private void respawnVictim(PlayerInfo pInfo) {
        spawnNewTank(pInfo);
        EsObject obj = new EsObject();
        obj.setString(PluginConstants.ACTION, PluginConstants.SPAWN_TANK);
        obj.setEsObject(PluginConstants.NAME, pInfo.toEsObject());
        obj.setNumber(PluginConstants.TIME_STAMP, new Number(System.currentTimeMillis()));
        sendAndLog("respawnVictim", obj, false);
    }

    private void handleTankKilled(PlayerInfo pInfo) {
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.TANK_KILLED);
        message.setString(PluginConstants.NAME, pInfo.getPlayerName());
        int deaths = pInfo.incrementNumDeaths();
        message.setInteger(PluginConstants.NUM_DEATHS, deaths);
        sendAndLog("handleTankKilled", message, false);

        respawnVictim(pInfo);
    }

    private void handleTurretRotationUpdate(String playerName, EsObject messageIn) {
        // Turrent rotations don't need to be processed, we just relay them (queued)
        messageIn.setString(PluginConstants.NAME, playerName);
        messageIn.setNumber(PluginConstants.TIME_STAMP, new Number(System.currentTimeMillis()));
        sendAndLog("handleTurretRotationUpdate", messageIn, true);
    }

    private synchronized boolean okForPlayerToEnter() {
        int numPlayers = getApi().getUsers().size();
        if (numPlayers > PluginConstants.MAXIMUM_PLAYERS) {
            getApi().setGameLockState(true);
            // numPlayers includes the player who is trying to enter
            return false;
        } else if (numPlayers == PluginConstants.MAXIMUM_PLAYERS) {
            getApi().setGameLockState(true);
            return true;
        } else {
            return true;
        }
    }

    @Override
    public void request(String playerName, EsObjectRO requestParameters) {
        EsObject messageIn = new EsObject();
        messageIn.addAll(requestParameters);
        getApi().getLogger().debug(playerName + " requests: " + messageIn.toString());

        String action = messageIn.getString(PluginConstants.ACTION);

        if (action.equals(PluginConstants.INIT_ME)) {
            handlePlayerInitRequest(playerName);
        } else if (action.equals(PluginConstants.HEADING_UPDATE)) {
            handleHeadingUpdate(playerName, messageIn);
        } else if (action.equals(PluginConstants.UPDATE_TURRET_ROTATION)) {
            handleTurretRotationUpdate(playerName, messageIn);
        } else if (action.equals(PluginConstants.SHOOT)) {
            handleShootRequest(playerName, messageIn);
        } else if (action.equals(PluginConstants.COLLECT_POWERUP)) {
            handleCollectPowerup(playerName, messageIn);
        }
    }

    @Override
    public void userExit(String playerName) {
        if (playerInfoMap.containsKey(playerName)) {
            playerInfoMap.remove(playerName);
        }
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.REMOVE_PLAYER);
        message.setString(PluginConstants.NAME, playerName);
        sendAndLog("userExit", message, false);

        int numUsersInRoom = getApi().getUsers().size();
        getApi().getLogger().debug("numUsersInRoom: " + numUsersInRoom);
        if (numUsersInRoom <= PluginConstants.MINIMUM_PLAYERS) {
            if (gameState == GameState.CountingDown) {
                getApi().getLogger().debug("resetCountdown called");
                resetCountdown();
            }
        }
    }

    @Override
    public void destroy() {
        getApi().cancelScheduledExecution(callbackId);
        for (Integer id : callbacks.values()) {
            getApi().cancelScheduledExecution(id);
        }
        getApi().getLogger().debug("room destroyed");
    }

    private synchronized EsObject[] getFullPlayerList() {
        EsObject[] list = new EsObject[playerInfoMap.size()];
        int ptr = 0;
        for (PlayerInfo pInfo : playerInfoMap.values()) {
            list[ptr] = pInfo.toEsObject();
            ptr++;
        }
        return list;
    }

    private synchronized void handlePlayerInitRequest(String playerName) {
        PlayerInfo pInfo = new PlayerInfo(playerName);
        spawnNewTank(pInfo);

        EsObject message2 = new EsObject();
        message2.setString(PluginConstants.ACTION, PluginConstants.ADD_PLAYER);
        message2.setString(PluginConstants.NAME, playerName);
//        message2.setEsObject(PluginConstants.HEADING, pInfo.getHeading().toEsObject());
        message2.setEsObject(PluginConstants.ADD_PLAYER, pInfo.toEsObject());
        sendAndLog("addUser", message2, false);

        // add the new user to the user list
        playerInfoMap.put(playerName, pInfo);


        // send the user the full user list
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.PLAYER_LIST);
        EsObject[] list = getFullPlayerList();
        message.setEsObjectArray(PluginConstants.PLAYER_LIST, list);
        message.setString(PluginConstants.GAME_STATE, gameState.getState());
        if (gameState == GameState.CountingDown) {
            message.setInteger(PluginConstants.COUNTDOWN_LEFT, getCountdownLeft());
        }
        message.setEsObject(PluginConstants.MAP, map.getInitialMapObject());
        EsObject[] bulletList = map.getBulletEsObjects();
        if (bulletList != null) {
            message.setEsObjectArray(PluginConstants.BULLET, bulletList);
        }
        EsObject[] powerupList = map.getPowerupEsObjects();
        if (powerupList != null) {
            message.setEsObjectArray(PluginConstants.POWERUP_LIST, powerupList);
        }

        getApi().sendPluginMessageToUser(playerName, message);
        getApi().getLogger().debug("Message sent to " + playerName + ": " + message.toString());

        switch (gameState) {
            case WaitingForPlayers:
                if (playerInfoMap.size() >= PluginConstants.MINIMUM_PLAYERS) {
                    startCountdown();
                }
                break;
            case CountingDown:
                startLateJoinerCountdown(playerName);
                if (playerInfoMap.size() >= PluginConstants.MAXIMUM_PLAYERS) {
                    stopCountdown();    // this will start the game
                }
                break;
        }

    }

    private void sendErrorMessage(String playerName, String error) {
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.ERROR);
        message.setString(PluginConstants.ERROR, error);
        getApi().sendPluginMessageToUser(playerName, message);
        getApi().getLogger().debug("Message sent to " + playerName + ": " + message.toString());
    }

    private void relayMessage(String playerName, EsObject messageIn) {
        messageIn.setString(PluginConstants.NAME, playerName);
        messageIn.setNumber(PluginConstants.TIME_STAMP, new Number(System.currentTimeMillis()));
        sendAndLog("relayMessage", messageIn, false);
    }

    private void sendToOneAndLog(String fromMethod, String playerName, EsObject message) {
        getApi().sendPluginMessageToUser(playerName, message);
        getApi().getLogger().debug(fromMethod + " to " + playerName + ": " + message.toString());
    }

    private void sendAndLog(String fromMethod, EsObject message, boolean isQueued) {
        List<String> initializedPlayers = new ArrayList<String>();
        for (PlayerInfo pInfo : playerInfoMap.values()) {
            initializedPlayers.add(pInfo.getPlayerName());
        }

        if (initializedPlayers.size() < 1) {
            return;     // nobody to send the message to
        }

        if (isQueued) {
            getApi().sendQueuedPluginMessageToUsers(initializedPlayers, message);
        } else {
            getApi().sendPluginMessageToUsers(initializedPlayers, message);
        }

        getApi().getLogger().debug(fromMethod + ": " + message.toString());
    }

    private void spawnNewTank(PlayerInfo pInfo) {
        pInfo.setHealth(PluginConstants.FULL_HEALTH);
        Point point = map.getRandomTankSpawnPoint();
        Heading heading = new Heading(point);
        pInfo.setHeading(heading);
        pInfo.setX(heading.getX());
        pInfo.setY(heading.getY());
    }

    private void startLateJoinerCountdown(String playerName) {
        if (gameState != GameState.CountingDown) {
            return;
        }
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.START_COUNTDOWN);
        message.setInteger(PluginConstants.COUNTDOWN_LEFT, getCountdownLeft());
        sendToOneAndLog("TankGame.startLateJoinerCountdown", playerName, message);
    }

    private void startCountdown() {
        if (gameState == GameState.CountingDown) {
            return;
        }
        gameState = GameState.CountingDown;
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.START_COUNTDOWN);
        message.setInteger(PluginConstants.COUNTDOWN_LEFT, PluginConstants.COUNTDOWN_SECONDS);
        sendAndLog("TankGame.startCountdown", message, false);
        setCountdownCallback(PluginConstants.COUNTDOWN_SECONDS);
    }

    private void resetCountdown() {
        getApi().cancelScheduledExecution(callbackId);
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.STOP_COUNTDOWN);
        message.setString(PluginConstants.GAME_STATE, GameState.WaitingForPlayers.getState());
        sendAndLog("TankGame.resetCountdown", message, false);
        gameState = GameState.WaitingForPlayers;
        getApi().setGameLockState(false);
    }

    private void stopCountdown() {
        getApi().cancelScheduledExecution(callbackId);
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.STOP_COUNTDOWN);
        sendAndLog("TankGame.stopCountdown", message, false);

        if (playerInfoMap.size() >= PluginConstants.MINIMUM_PLAYERS) {
            startGame();
        } else {
            gameState = GameState.WaitingForPlayers;
            getApi().setGameLockState(false);
        }
    }

    private void startGame() {
        gameState = GameState.InPlay;
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.START_GAME);
        sendAndLog("TankGame.startGame", message, false);
        getApi().startQueue(PluginConstants.TURRET_ROTATION_UPDATE_PERIOD);
        setCollisionCheckCallback();
    }

    private void setCollisionCheckCallback() {
        getApi().cancelScheduledExecution(callbackId);
        callbackId = getApi().scheduleExecution(PluginConstants.COLLISION_CHECK_PERIOD_MS,
                -1,
                new ScheduledCallback() {

                    public void scheduledCallback() {
                        checkForCollisions();
                    }
                });
    }

    private void setCountdownCallback(int seconds) {
        getApi().cancelScheduledExecution(callbackId);
        startTime = System.currentTimeMillis();
        callbackId = getApi().scheduleExecution(seconds * 1000,
                1,
                new ScheduledCallback() {

                    public void scheduledCallback() {
                        stopCountdown();
                    }
                });
    }

    private List<Collision> getCollisionsToProcess(List<Projectile> bulletList, long now) {
        List<Collision> hitList = new ArrayList<Collision>();
        for (Projectile bullet : bulletList) {
            Collision closestCollision = bullet.getCollisionWithTank(map, getApi().getLogger(),now);
            if (closestCollision == null) {
                if (bullet.getTargetTime() <= now) {
                    getApi().getLogger().debug("bullet's target time is <= now, collision is null, dropping");
                    bulletMap.remove(bullet.getId());
                }
            } else {
                if (closestCollision.getTimeOfCollision() <= now) {
                    if (closestCollision.getTank() != null) {
                        hitList.add(closestCollision);
                    } else {
                        getApi().getLogger().debug("bullet's target time is <= now, collision is " + closestCollision.getCollisionType());
                        bulletMap.remove(bullet.getId());
                    }
                }
            }
        }
        return hitList;
    }

    private void checkForCollisions() {
        if (bulletMap.isEmpty()) {
            return;
        }
        // If somebody else is already processing collisions, there's no point
        // in doing it a second time
        if (collisionHandlerLock.tryLock()) {
            try {
                long now = System.currentTimeMillis();
                getApi().getLogger().debug("checkForCollisions starting for now = " + now);
                List<Collision> hitList;
                List<Projectile> bulletList = new ArrayList<Projectile>();
                for (Projectile bullet : bulletMap.values()) {
                    bullet.setCurrentPosition(new Heading(bullet, now));
                    bulletList.add(bullet);
                }

                hitList = getCollisionsToProcess(bulletList, now);
                while (!hitList.isEmpty() && !bulletList.isEmpty()) {
                    Projectile bulletFinished = processOneOfTheCollision(hitList, now);
                    if (bulletFinished == null) {
                        hitList.clear();
                        bulletList.clear();
                    } else {
                        bulletList.remove(bulletFinished);
                        if (!bulletList.isEmpty()) {
                            hitList = getCollisionsToProcess(bulletList, now);
                        } else {
                            hitList.clear();
                        }
                    }
                }
            } finally {
                collisionHandlerLock.unlock();
            }
        }
    }

    private Projectile processOneOfTheCollision(List<Collision> hitList, long now) {
        Collision earliest = null;
        for (Collision collision : hitList) {
            if (earliest == null || earliest.getTimeOfCollision() < collision.getTimeOfCollision()) {
                if (collision.getTank() != null) {
                    getApi().getLogger().debug("processEarliestCollision in loop found: " + collision.getTank().getPlayerName());
                } else {
                    getApi().getLogger().debug("processEarliestCollision in loop found collision with obstacle" );
                }
                earliest = collision;
                getApi().getLogger().debug("time of collision = " + String.valueOf(collision.getTimeOfCollision()));
            }
        }
        if (earliest == null || earliest.getTimeOfCollision() > now) {
            return null;
        } else {
            Projectile bullet = earliest.getBullet();
            bulletMap.remove(bullet.getId());
            handleCollision(earliest);
            return bullet;
        }
    }

    private void updateHealth(PlayerInfo pInfo) {
        pInfo.setHealth(PluginConstants.FULL_HEALTH);
        EsObject obj = new EsObject();
        obj.setString(PluginConstants.ACTION, PluginConstants.HEALTH_UPDATE);
        obj.setString(PluginConstants.NAME, pInfo.getPlayerName());
        obj.setInteger(PluginConstants.HEALTH, pInfo.getHealth());
        sendAndLog("updateHealth", obj, false);
    }
}
