package com.gamebook.collision;

import java.awt.Point;
import java.util.ArrayList;
import java.util.List;

public class IntersectionDetector {

    /**
     * Checks to see if a line sgement is intersecting with any of a collection of line segments. If a point is passed in (3rd param)
     * then it is used to decide which of the potentially N number of intersection points is returned. This allows you to know which 
     * segement was hit first.
     */
    public static IntersectionTestResult segmentCollectionTest(LineSegment seg, LineSegmentCollection col, Point point) {
        IntersectionTestResult res = new IntersectionTestResult();
        List<IntersectionTestResult> collisions = new ArrayList<IntersectionTestResult>();

        //find all intersections
        for (LineSegment ls : col.getLineSegments()) {
            IntersectionTestResult result = segmentSegmentTest(seg, ls);
            if (result.isIntersecting()) {
                res.setIntersecting(true);
                if (point != null) {
                    //in thise case, store the result because we need to find the closest intersection
                    collisions.add(result);
                } else {
                    //in this case just break the loop, we found a collision
                    res = result;
                    break;
                }
            }
        }

        if (point != null) {
            //find closest intersection to point
            Point closest = null;
            double shortest = Double.MAX_VALUE;
            for (IntersectionTestResult res1 : collisions) {
                double dis = point.distance(res1.getPoint());
                if (dis < shortest) {
                    closest = res1.getPoint();
                    shortest = dis;
                }
            }
            res.setPoint(closest);
        }

        return res;
    }

    /**
     * Checks two line segments to see if they are intersecting. If they are then the intersection point is also returned.
     */
    public static IntersectionTestResult segmentSegmentTest(LineSegment segment1, LineSegment segment2) {
        IntersectionTestResult res = new IntersectionTestResult();
        if (segment1.intersectsLine(segment2)) {
            res.setIntersecting(true);
            res.setPoint(getPointOfIntersection(segment1, segment2));
        } else {
            res.setIntersecting(false);
            res.setPoint(null);
        }

        return res;
    }

    private static Point getPointOfIntersection(LineSegment segment1, LineSegment segment2) {

        double x;
        double y;

        if (Math.abs(segment1.getSlope()) == Double.POSITIVE_INFINITY) {
            x = segment1.getX1();
            y = segment2.getSlope() * x + segment2.getYIntercept();
        } else if (Math.abs(segment2.getSlope()) == Double.POSITIVE_INFINITY) {
            x = segment2.getX1();
            y = segment1.getSlope() * x + segment1.getYIntercept();
        } else if (segment1.getSlope() == segment2.getSlope()) {
            x = segment1.getX1();
            y = segment2.getSlope() * x + segment2.getYIntercept();
        } else {
            x = (segment2.getYIntercept() - segment1.getYIntercept()) / (segment1.getSlope() - segment2.getSlope());
            y = segment1.getSlope() * x + segment1.getYIntercept();
        }

        return new Point(getNearestInt(x), getNearestInt(y));
    }
    
    private static int getNearestInt(double d) {
        return (int) Math.round(d);
    }
}


