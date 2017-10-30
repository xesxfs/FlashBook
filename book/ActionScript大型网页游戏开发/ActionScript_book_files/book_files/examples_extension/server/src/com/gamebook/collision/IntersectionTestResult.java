package com.gamebook.collision;

import java.awt.Point;

public class IntersectionTestResult {

    /**
     * True if an instersection was found. The point property will be non-null as well.
     */
    private boolean intersecting = false;
    
    /**
     * If intersecting, this is the point of that intersection
     */
    private Point point;

    public boolean isIntersecting() {
        return intersecting;
    }

    public void setIntersecting(boolean intersecting) {
        this.intersecting = intersecting;
    }

    public Point getPoint() {
        return point;
    }

    public void setPoint(Point point) {
        this.point = point;
    }
}
