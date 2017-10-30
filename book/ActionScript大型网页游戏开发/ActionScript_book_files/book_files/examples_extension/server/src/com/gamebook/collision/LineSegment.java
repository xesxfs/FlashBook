package com.gamebook.collision;

import java.awt.Point;
import java.awt.geom.Line2D;

public class LineSegment extends Line2D.Double {

    private double slope;
    private double yIntercept;

    /**
     * The two points that make up the ends of this line segment
     */
    public LineSegment(Point p1, Point p2) {
        super(p1, p2);

        if (p2.getX() == p1.getX()) {
            slope = java.lang.Double.POSITIVE_INFINITY;
            yIntercept = java.lang.Double.NEGATIVE_INFINITY;
        } else {
            slope = (p2.getY() - p1.getY()) / (1.0 * (p2.getX() - p1.getX()));
            yIntercept = p1.getY() - slope * p1.getX();
        }
    }

    public double getSlope() {
        return slope;
    }

    public double getYIntercept() {
        return yIntercept;
    }
}
