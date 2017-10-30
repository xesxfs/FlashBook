package com.gamebook.collision;

import com.gamebook.tank.*;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.Number;
import java.awt.Point;
import org.slf4j.Logger;

public class Collision {

    private boolean collide;
    private Point collisionPoint;
    private long timeOfCollision;
    private PlayerInfo tank = null;
    private Projectile bullet;
    private boolean tankKilled = false;
    private String collisionType;
    
    public EsObject toEsObject() {
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.SHOT_HIT);
        message.setNumber(PluginConstants.TIME_STAMP, new Number( timeOfCollision ));
        message.setInteger(PluginConstants.ITEM_ID, bullet.getId());
        message.setString(PluginConstants.SHOT_HIT, collisionType);
        if (tank != null) {
            message.setString(PluginConstants.NAME, tank.getPlayerName());
            message.setInteger(PluginConstants.HEALTH, tank.getHealth());
        }
        return message;
    }
    
    public static EsObject getMissMessage(Projectile bullet) {
        EsObject message = new EsObject();
        message.setString(PluginConstants.ACTION, PluginConstants.SHOT_HIT);
        message.setNumber(PluginConstants.TIME_STAMP, new Number( bullet.getTargetTime() ));
        message.setInteger(PluginConstants.ITEM_ID, bullet.getId());
        message.setString(PluginConstants.SHOT_HIT, PluginConstants.COLLISION_OUT_OF_BOUNDS);
        return message;
    }
    
    public void executeHit(Logger logger) {
        if (tank != null) {
            int health = tank.decrementHealth();
            if (health <= 0) {
                setTankKilled(true);
                logger.debug("tank killed!");
            }
        }
    }

    public boolean canCollide() {
        return collide;
    }

    public void setCollide(boolean collide) {
        this.collide = collide;
    }

    public Point getCollisionPoint() {
        return collisionPoint;
    }

    public void setCollisionPoint(Point collisionPoint) {
        this.collisionPoint = collisionPoint;
    }

    public long getTimeOfCollision() {
        return timeOfCollision;
    }

    public void setTimeOfCollision(long timeOfCollision) {
        this.timeOfCollision = timeOfCollision;
    }

    public PlayerInfo getTank() {
        return tank;
    }

    public void setTank(PlayerInfo tank) {
        this.tank = tank;
    }

    public Projectile getBullet() {
        return bullet;
    }

    public void setBullet(Projectile bullet) {
        this.bullet = bullet;
    }

    public boolean isTankKilled() {
        return tankKilled;
    }

    public void setTankKilled(boolean tankKilled) {
        this.tankKilled = tankKilled;
    }

    public String getCollisionType() {
        return collisionType;
    }

    public void setCollisionType(String collisionType) {
        this.collisionType = collisionType;
    }
}
