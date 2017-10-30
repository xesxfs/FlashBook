package com.gamebook.tank;

import com.electrotank.electroserver4.extensions.api.value.EsObject;

public class Item {

    private int x = 0;
    private int y = 0;
    private boolean obstacle = true;
    private boolean hittable = true;
    private int width = 1;
    private int height = 1;
    private String decal = "";

    public Item() {
    }
    
    public Item(String decal, int x, int y, int width, int height, boolean obstacle, boolean hittable) {
        this.decal = decal;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.obstacle = obstacle;
        this.hittable = hittable;
    }

    public Item(EsObject obj) {
        x = obj.getInteger(PluginConstants.X);
        y = obj.getInteger(PluginConstants.Y);
        obstacle = obj.getBoolean(PluginConstants.OBSTACLE, true);
        hittable = obj.getBoolean(PluginConstants.HITTABLE, true);
        width = obj.getInteger(PluginConstants.WIDTH, 1);
        height = obj.getInteger(PluginConstants.HEIGHT, 1);
        decal = obj.getString(PluginConstants.DECAL, "");
    }

    public void setXY(int x, int y) {
        this.x = x;
        this.y = y;
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

    public EsObject toEsObject() {
        EsObject obj = new EsObject();
        obj.setInteger(PluginConstants.X, x);
        obj.setInteger(PluginConstants.Y, y);
        obj.setString(PluginConstants.DECAL, decal);
        obj.setBoolean(PluginConstants.OBSTACLE, obstacle);
        obj.setBoolean(PluginConstants.HITTABLE, hittable);
        obj.setInteger(PluginConstants.WIDTH, width);
        obj.setInteger(PluginConstants.HEIGHT, height);
        return obj;
    }

    public boolean isObstacle() {
        return obstacle;
    }

    public void setObstacle(boolean obstacle) {
        this.obstacle = obstacle;
    }

    public boolean isHittable() {
        return hittable;
    }

    public void setHittable(boolean hittable) {
        this.hittable = hittable;
    }

    public int getWidth() {
        return width;
    }

    public void setWidth(int width) {
        this.width = width;
    }

    public int getHeight() {
        return height;
    }

    public void setHeight(int height) {
        this.height = height;
    }

    public String getDecal() {
        return decal;
    }

    public void setDecal(String decal) {
        this.decal = decal;
    }
}
