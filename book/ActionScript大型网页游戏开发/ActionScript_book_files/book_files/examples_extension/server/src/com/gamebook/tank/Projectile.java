package com.gamebook.tank;

import com.gamebook.collision.Collision;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.gamebook.collision.IntersectionDetector;
import com.gamebook.collision.IntersectionTestResult;
import com.gamebook.collision.LineSegmentCollection;
import java.awt.Point;
import java.util.List;
import org.slf4j.Logger;

public class Projectile extends Heading {

    private int id;
    private String playerWhoFired;
    private double theta;
    private static int numberOfProjectilesSpawned = 0;
    private Collision obstacleCollision = null;
    private Logger logger = null;
    private Heading currentPosition;

    public Projectile() {
    }

    public Projectile(String playerName, EsObject obj) {
        playerWhoFired = playerName;
        setTank(false);
        id = ++numberOfProjectilesSpawned;
        timestamp = getLongFromNumber(PluginConstants.TIME_STAMP, obj);
        x = obj.getInteger(PluginConstants.X, x);
        y = obj.getInteger(PluginConstants.Y, y);
        speed = PluginConstants.BULLET_SPEED;
//        speed = getDoubleFromNumber(PluginConstants.SPEED, obj);
        angle = getDoubleFromNumber(PluginConstants.ANGLE, obj);
        theta = Math.toRadians(angle);
        vx = speed * Math.cos(theta);
        vy = speed * Math.sin(theta);

        // target is max distance that the projectile can travel
        double elapsedTime = PluginConstants.BULLET_LIFE_MS;
        targetTime = timestamp + elapsedTime;
        targetX = (int) Math.round(x + vx * elapsedTime);
        targetY = (int) Math.round(y + vy * elapsedTime);
        updatePath();
    }

    public EsObject getBulletEsObject() {
        EsObject obj = new EsObject();
        obj.setInteger(PluginConstants.ITEM_ID, getId());
        obj.setString(PluginConstants.NAME, playerWhoFired);
        obj.setEsObject(PluginConstants.HEADING, toEsObject());
        return obj;
    }

    @Override
    public double getTargetTime() {
        return targetTime;
    }

    public boolean isValidStartPosition(Heading tankHeading, Logger newLogger) {
        if (logger == null) {
            logger = newLogger;
        }
        if (tankHeading == null) {
            return true;
        }
        Point tankPosition = tankHeading.getCurrentPositionAtTime(timestamp, logger);
        logger.debug("current tankPosition: " + tankPosition.getX() + ", " + tankPosition.getY());
        int muzzleX = (int) Math.round(tankPosition.getX() + PluginConstants.TURRET_LENGTH * Math.cos(theta));
        int muzzleY = (int) Math.round(tankPosition.getY() + PluginConstants.TURRET_LENGTH * Math.sin(theta));
        logger.debug("muzzle position: " + muzzleX + ", " + muzzleY);
        Point muzzlePosition = new Point(muzzleX, muzzleY);
        double distance = muzzlePosition.distance(x, y);
        logger.debug("distance: " + distance);
        return distance <= PluginConstants.POSITION_UPDATE_FUZZINESS;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getPlayerWhoFired() {
        return playerWhoFired;
    }

    public void setPlayerWhoFired(String playerWhoFired) {
        this.playerWhoFired = playerWhoFired;
    }

    public Collision getCollisionWithObstacles(Map map, Logger newLogger) {
        // Get obstacles in danger zone
        if (logger == null) {
            logger = newLogger;
        }

        Collision closest = checkCollisionWithHittableItems(map);

        if (closest == null) {
            logger.debug("no hit on obstacles");
            obstacleCollision = getOutOfBoundsCollision();
        } else {
            obstacleCollision = closest;
            logger.debug("closest hit on obstacle is at time " + String.valueOf(closest.getTimeOfCollision()));
            // update target since the bullet won't go past this obstacle
            double targetXDouble = closest.getCollisionPoint().getX();
            int newTargetX = (int) Math.round(targetXDouble);
            setTargetX(newTargetX);
            double targetYDouble = closest.getCollisionPoint().getY();
            int newTargetY = (int) Math.round(targetYDouble);
            setTargetY(newTargetY);
            targetTime = closest.getTimeOfCollision();
            updatePath();
        }

        return closest;

    }

    public Collision getCollisionWithTank(Map map, Logger newLogger, long now) {
        if (logger == null) {
            logger = newLogger;
        }
        // Get tanks and hittable obstacles in danger zone
        List<PlayerInfo> enemyTanks = map.getEnemyTanks(playerWhoFired);

        Collision closest = obstacleCollision;

        for (PlayerInfo enemyTank : enemyTanks) {
            Collision tankCollision = checkCollisionWithTank(enemyTank, logger, now);
            if (tankCollision != null) {
                if (closest == null || tankCollision.getTimeOfCollision() < closest.getTimeOfCollision()) {
                    closest = tankCollision;
                }
            }
        }

        if (closest == null || closest.getTank() == null) {
            logger.debug("no hit on tanks");
        } else if (closest.getTank() != null) {
            logger.debug("closest hit on tank is at time " + String.valueOf(closest.getTimeOfCollision()));
            logger.debug("tank hit is " + closest.getTank().getPlayerName());
        }

        return closest;
    }

    public Collision getOutOfBoundsCollision() {
        Collision returnObj = new Collision();
        returnObj.setCollide(true);
        returnObj.setBullet(this);
        returnObj.setCollisionType(PluginConstants.COLLISION_OUT_OF_BOUNDS);
        returnObj.setTimeOfCollision((long) targetTime);
        returnObj.setTank(null);
        Point point = new Point(targetX, targetY);
        returnObj.setCollisionPoint(point);
        return returnObj;
    }

    public Collision checkCollisionWithHittableItems( Map map) {
        Collision returnObj = getOutOfBoundsCollision();
        LineSegmentCollection list = map.getHittableItemLineSegments();
        if (list == null || list.isEmpty()) {
            return returnObj;
        }
        IntersectionTestResult itr = IntersectionDetector.segmentCollectionTest(getPath(),list, startingPoint);

        if (itr == null || !itr.isIntersecting()) {
            return returnObj;
        } else {
            Point pointOfCollision = itr.getPoint();
            double time = getTimeToPosition(pointOfCollision);
            long timeOfCollision = Math.round(time + timestamp);

            returnObj.setCollide(true);
            returnObj.setBullet(this);
            returnObj.setCollisionType(PluginConstants.COLLISION_STRUCTURE);
            returnObj.setTimeOfCollision(timeOfCollision);
            returnObj.setCollisionPoint(pointOfCollision);
        }
        return returnObj;
    }

    public Collision checkCollisionWithTank(PlayerInfo tank, Logger newLogger, long now) {
        if (logger == null) {
            logger = newLogger;
        }
        Heading tankHeading = tank.getHeading();
        Point currentTankPosition = tankHeading.getCurrentPositionAtTime(now, logger);
        Collision returnObj = new Collision();

        double distance = getPath().ptSegDist(currentTankPosition);

        int r = PluginConstants.TANK_RADIUS + PluginConstants.BULLET_RADIUS;

        if (distance > r) {
            return null;
        }

        // Build the square for the tank

        LineSegmentCollection lsc = new LineSegmentCollection();
        lsc.addTank(currentTankPosition, r);

        IntersectionTestResult itr = IntersectionDetector.segmentCollectionTest(getPath(),lsc, startingPoint);

        if (itr == null || !itr.isIntersecting()) {
            logger.debug("WEIRD: ptSegDist says it's a hit but IntersectionTest says it's a miss");
            return null;
        } else {
            Point pointOfCollision = itr.getPoint();
            double time = getTimeToPosition(pointOfCollision);
            long timeOfCollision = Math.round(time + timestamp);
            logger.debug("timeOf projected collision: " + String.valueOf(timeOfCollision));

            returnObj.setCollide(true);
            returnObj.setBullet(this);
            returnObj.setTank(tank);
            returnObj.setCollisionType(PluginConstants.COLLISION_TANK);
            returnObj.setTimeOfCollision(timeOfCollision);
            returnObj.setCollisionPoint(pointOfCollision);
        }
        return returnObj;

    }

    public Heading getCurrentPosition() {
        return currentPosition;
    }

    public void setCurrentPosition(Heading currentPosition) {
        this.currentPosition = currentPosition;
    }
}
