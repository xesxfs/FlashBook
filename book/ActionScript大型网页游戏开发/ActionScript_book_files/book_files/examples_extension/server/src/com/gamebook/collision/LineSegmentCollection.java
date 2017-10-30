package com.gamebook.collision;

import com.gamebook.tank.Item;
import java.awt.Point;
import java.util.ArrayList;
import java.util.List;

public class LineSegmentCollection {

    private List<LineSegment> lineSegments;

    public LineSegmentCollection() {
        lineSegments = new ArrayList<LineSegment>();
    }

    public boolean isEmpty() {
        return  lineSegments.isEmpty();
    }
    
    /**
     * Adds a new line segment
     */
    public void addLineSegment(LineSegment ls) {
        getLineSegments().add(ls);
    }

    public List<LineSegment> getLineSegments() {
        return lineSegments;
    }
    
    public void addItem(Item item, int padding) {
        int x1 = item.getX() - padding;
        int y1 = item.getY() - padding;
        int x2 = x1 + item.getWidth() + 2 * padding;
        int y2 = y1 + item.getHeight() + 2 * padding;
        Point p1 = new Point(x1, y1);
        Point p2 = new Point(x1, y2);
        Point p3 = new Point(x2, y1);
        Point p4 = new Point(x2, y2);
        addLineSegment(new LineSegment(p1, p2));
        addLineSegment(new LineSegment(p1, p3));
        addLineSegment(new LineSegment(p2, p4));
        addLineSegment(new LineSegment(p3, p4));
    }
    
    public void addTank(Point currentTankPosition, int radius) {
        int currentX = (int) Math.round(currentTankPosition.getX());
        int currentY = (int) Math.round(currentTankPosition.getY());
        
        // add a square
        int x1 = currentX - radius;
        int y1 = currentY - radius;
        int x2 = currentX + radius;
        int y2 = currentY + radius;
        Point p1 = new Point(x1, y1);
        Point p2 = new Point(x1, y2);
        Point p3 = new Point(x2, y1);
        Point p4 = new Point(x2, y2);
        addLineSegment(new LineSegment(p1, p2));
        addLineSegment(new LineSegment(p1, p3));
        addLineSegment(new LineSegment(p2, p4));
        addLineSegment(new LineSegment(p3, p4));
        
        // now add a diamond
        Point p5 = new Point(currentX, y1 - radius);
        Point p6 = new Point (currentX + radius, currentY);
        Point p7 = new Point (currentX, y1 + radius);
        Point p8 = new Point (currentX - radius, currentY);
        addLineSegment(new LineSegment(p5, p6));
        addLineSegment(new LineSegment(p6, p7));
        addLineSegment(new LineSegment(p7, p8));
        addLineSegment(new LineSegment(p8, p5));
    }
}
