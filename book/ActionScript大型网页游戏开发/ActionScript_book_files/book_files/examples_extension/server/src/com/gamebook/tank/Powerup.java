package com.gamebook.tank;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import java.awt.Point;
import java.util.Random;

public class Powerup {
    
    private int id;
    private String type;
    private int x;
    private int y;
    private boolean taken;
    private static String[] typeList = {PluginConstants.POWERUP_HEALTH};
    private static int numberOfPowerupsSpawned = 0;
    private static Random rnd = new Random();
    
    public Powerup(Point point) {
        id = ++numberOfPowerupsSpawned;
        type = getRandomPowerupType();
        x = (int) Math.round(point.getX());
        y = (int) Math.round(point.getY());
        taken = false;
    }
    
    public EsObject toEsObject() {
        EsObject obj = new EsObject();
        obj.setInteger(PluginConstants.ITEM_ID, id);
        obj.setString(PluginConstants.POWERUP_TYPE, type);
        obj.setInteger(PluginConstants.X, x);
        obj.setInteger(PluginConstants.Y, y);
        return obj;
    }
    
    public void setXY(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public int getId() {
        return id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
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

    public static String getRandomPowerupType() {
        int ptr = rnd.nextInt(typeList.length);
        return typeList[ptr];
    }

    public boolean isTaken() {
        return taken;
    }

    public synchronized boolean playerGrabsPowerup() {
        if (isTaken()) {
            return false;
        } else { 
            taken = true;
            return true;
        }
    }

}
