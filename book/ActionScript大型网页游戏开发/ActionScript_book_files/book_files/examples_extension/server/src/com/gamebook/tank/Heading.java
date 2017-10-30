package com.gamebook.tank;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.Number;
import com.gamebook.collision.LineSegment;
import com.gamebook.util.Utility;
import java.awt.Point;
import org.slf4j.Logger;

public class Heading {
    
    protected long timestamp;
    protected double targetTime;
    protected int x;
    protected int y;
    protected double speed;
    protected double angle;
    protected double vx, vy;
    protected int targetX;
    protected int targetY;
    protected boolean tank = true;
    private LineSegment path;
    protected Point startingPoint;
    
    public Heading() {}
    
    public Heading(Point point) {
        timestamp = System.currentTimeMillis();
        x = (int) Math.round(point.getX());
        y = (int) Math.round(point.getY());
        speed = 0;
        tank = true;
        targetX = x;
        targetY = y;
        vx = 0;
        vy = 0;
        targetTime = timestamp - 1;
    }
    
    public Heading(EsObject obj) {
        timestamp = getLongFromNumber(PluginConstants.TIME_STAMP, obj);
        x = obj.getInteger(PluginConstants.X, x);
        y = obj.getInteger(PluginConstants.Y, y);
        speed = PluginConstants.TANK_SPEED;
        tank = true;
//        speed = getDoubleFromNumber(PluginConstants.SPEED, obj);
        targetX = obj.getInteger(PluginConstants.TARGET_X, targetX);
        targetY = obj.getInteger(PluginConstants.TARGET_Y, targetY);
        targetTime = getTargetTime();
        double theta = Math.atan2(targetY - y, targetX - x);
        angle = Math.toDegrees(theta);
        vx = speed * Math.cos(theta);
        vy = speed * Math.sin(theta);
    }
    
    public Heading (Heading oldHeading, long now) {
        timestamp = now;
        Point point = oldHeading.getCurrentPositionAtTime(now, null);
        x = ((int) Math.round(point.getX()));
        y = ((int) Math.round(point.getY()));
        targetX = oldHeading.getTargetX();
        targetY = oldHeading.getTargetY();
        targetTime = oldHeading.getTargetTime();
        angle = oldHeading.angle;
        tank = oldHeading.tank;
        if (now < targetTime || !tank) {
            speed = oldHeading.speed;
            vx = oldHeading.vx;
            vy = oldHeading.vy;
        } else {
            speed = 0;
            vx = 0;
            vy = 0;
        }
        updatePath();
    }
    
    public void updatePath() {
        startingPoint = new Point(x, y);
        path = new LineSegment(startingPoint, new Point(targetX, targetY));
    }

    public void setTargetTime(double time) {
        targetTime = time;
    }
    
    public double getDistanceToTravel() {
        //Dis = math.sqrt(math.pow(targety-y, 2)+math.pow(targetx-x, 2))
        double distance = Math.sqrt(Math.pow(targetY - y, 2) 
                + Math.pow(targetX - x, 2));
        return distance;
    }
    
    public double getTimeItWillTake() {
        //Time_it_will_take = dis/speed
        return getDistanceToTravel() / speed;
    }
    
    public double getTargetTime() {
        //Absolute time = start time + time_it_will_take
        return timestamp + getTimeItWillTake();
    }
    
    public double getTimeToPosition(Point toPosition) {
        double distance = Math.sqrt(Math.pow(toPosition.getY() - y, 2) 
                + Math.pow(toPosition.getX() - x, 2));
        return distance / speed; 
    }
    
    public Point getCurrentPositionAtTime(long atTime, Logger logger) {
        int currentX, currentY;
        long targetTimeLong = Math.round(targetTime);
//        if (logger != null) {
//            logger.debug("getCurrentPositionAtTime for heading object: " + toEsObject().toString());
//            logger.debug("atTime, targetTime, elapsed: " + String.valueOf( atTime) + ", "
//                    + String.valueOf(targetTimeLong)
//                    + ", " + String.valueOf(atTime - timestamp));
//        }
        if (atTime < targetTimeLong) {
            long elapsedTime = atTime - timestamp;
            currentX = (int) Math.round(x + vx * elapsedTime);
            currentY = (int) Math.round(y + vy * elapsedTime);
//            if (logger != null) {
//                logger.debug("elapsedTime, currentX, currentY: " + 
//                        String.valueOf(elapsedTime) +
//                        ", " + currentX + ", " + currentY);
//            }
        } else {
            currentX = targetX;
            currentY = targetY;
//            if (logger != null) {
//                logger.debug("currentX, currentY: " + 
//                        currentX + ", " + currentY);
//            }
        }
        return new Point(currentX, currentY);
    }
    
    public boolean isValidPositionAtTime(long atTime, int newX, int newY) {
        Point calculatedPosition = getCurrentPositionAtTime(atTime, null);
        double distance = calculatedPosition.distance(newX, newY);
        return distance <= PluginConstants.POSITION_UPDATE_FUZZINESS;
    }
    
    public boolean isValidPositionAtTime(EsObject obj) {
        long atTime = getLongFromNumber(PluginConstants.TIME_STAMP, obj);
        int newX = obj.getInteger(PluginConstants.X, x);
        int newY = obj.getInteger(PluginConstants.Y, y);
        return isValidPositionAtTime(atTime, newX, newY);
    }
    
    protected double getDoubleFromNumber(String name, EsObject obj) {
        return Utility.getDoubleFromNumber(name, obj);
    }
    
    protected long getLongFromNumber(String name, EsObject  obj) {
        return Utility.getLongFromNumber(name, obj);
    }
    
    public EsObject toEsObject() {
        EsObject obj = new EsObject();
        obj.setNumber(PluginConstants.TIME_STAMP, new Number( timestamp ));
        obj.setInteger(PluginConstants.X, x);
        obj.setInteger(PluginConstants.Y, y);
        obj.setNumber(PluginConstants.SPEED, new Number (speed));
        obj.setInteger(PluginConstants.TARGET_X, targetX);
        obj.setInteger(PluginConstants.TARGET_Y, targetY);
        obj.setNumber(PluginConstants.ANGLE, new Number(angle));
        return obj;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
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

    public double getSpeed() {
        return speed;
    }

    public void setSpeed(double speed) {
        this.speed = speed;
    }

    public int getTargetX() {
        return targetX;
    }

    public void setTargetX(int targetX) {
        this.targetX = targetX;
    }

    public int getTargetY() {
        return targetY;
    }

    public void setTargetY(int targetY) {
        this.targetY = targetY;
    }

    public boolean isTank() {
        return tank;
    }

    public void setTank(boolean tank) {
        this.tank = tank;
    }

    public LineSegment getPath() {
        return path;
    }
    

}
