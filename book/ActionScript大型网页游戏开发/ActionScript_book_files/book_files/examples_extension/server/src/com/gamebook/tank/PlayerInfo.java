package com.gamebook.tank;

import com.electrotank.electroserver4.extensions.api.value.EsObject;

public class PlayerInfo  {

    private String playerName;
    private int x = -1;
    private int y = -1;
    private int health = 100;
    private int numKills = 0;
    private int numDeaths = 0;
    private Heading heading = null;

    public PlayerInfo(String playerName) {
        this.playerName = playerName;
    }
    
    public EsObject toEsObject() {
        EsObject obj = new EsObject();
        obj.setString(PluginConstants.NAME, playerName);
        obj.setInteger(PluginConstants.HEALTH, health);
        obj.setInteger(PluginConstants.NUM_DEATHS, numDeaths);
        obj.setInteger(PluginConstants.NUM_KILLS, numKills);
        if (heading != null) {
            obj.setEsObject(PluginConstants.HEADING, heading.toEsObject());
        }
        return obj;
    }
    
    public String getPlayerName() {
        return playerName;
    }

    public int getX() {
        return x;
    }

    public void setX(int x) {
        this.x = x;
    }

    public int getY() {
        return y;
    }

    public void setY(int y) {
        this.y = y;
    }

    public int getHealth() {
        return health;
    }

    public void setHealth(int health) {
        this.health = health;
    }
    
    public int decrementHealth() {
        health -= PluginConstants.BULLET_HIT_POINTS;
        return health;
    }

    public int getNumKills() {
        return numKills;
    }

    public void setNumKills(int numKills) {
        this.numKills = numKills;
    }

    public int getNumDeaths() {
        return numDeaths;
    }

    public void setNumDeaths(int numDeaths) {
        this.numDeaths = numDeaths;
    }
    
    public int incrementNumDeaths() {
        numDeaths++;
        return numDeaths;
    }
    
    public int incrementNumKills() {
        numKills++;
        return numKills;
    }

    public Heading getHeading() {
        return heading;
    }

    public void setHeading(Heading heading) {
        this.heading = heading;
    }

}
