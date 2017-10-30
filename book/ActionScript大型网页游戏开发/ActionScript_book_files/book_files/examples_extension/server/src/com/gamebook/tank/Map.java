package com.gamebook.tank;

import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.gamebook.collision.IntersectionDetector;
import com.gamebook.collision.IntersectionTestResult;
import com.gamebook.collision.LineSegment;
import com.gamebook.collision.LineSegmentCollection;
import java.awt.Point;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

public class Map {

    private int width = 1600;
    private int height = 1200;
    private String name = "";
    private List<Point> tankSpawnPoints;
    private List<Point> powerupSpawnPoints;
    private List<Item> items;
    private LineSegmentCollection hittableItemLineSegments;
    private LineSegmentCollection obstacleItemLineSegments;
    private EsObject initialMapObject;
    private AbstractMap<String, PlayerInfo> playerInfoMap;
    private AbstractMap<Integer, Powerup> powerupMap;
    private AbstractMap<Integer, Projectile> bulletMap;
    private Random rnd = new Random();

    public Map(EsObject obj, AbstractMap<String, PlayerInfo> playerInfoMap) {
        this.playerInfoMap = playerInfoMap;
        powerupMap = new ConcurrentHashMap<Integer, Powerup>();
        initialMapObject = obj;
        width = obj.getInteger(PluginConstants.WIDTH, width);
        height = obj.getInteger(PluginConstants.HEIGHT, height);
        name = obj.getString(PluginConstants.MAP_NAME, name);

        EsObject[] tankSpawns = obj.getEsObjectArray(PluginConstants.TANK_SPAWN_LIST, null);
        tankSpawnPoints = fillList(tankSpawns);

        EsObject[] powerupSpawns = obj.getEsObjectArray(PluginConstants.POWERUP_SPAWN_LIST, null);
        powerupSpawnPoints = fillList(powerupSpawns);

        EsObject[] itemArray = obj.getEsObjectArray(PluginConstants.ITEM_LIST, null);
        initItems(itemArray);
        initItemLineSegments();
        fillAllPowerupSpawnPoints();
    }

    public Map(AbstractMap<String, PlayerInfo> playerInfoMap) {
        this.playerInfoMap = playerInfoMap;
        powerupMap = new ConcurrentHashMap<Integer, Powerup>();
        width = PluginConstants.DEFAULT_MAP_WIDTH;
        height = PluginConstants.DEFAULT_MAP_HEIGHT;
        name = "Plugin Default Map";
        tankSpawnPoints = getDefaultTankSpawns();
        powerupSpawnPoints = getDefaultPowerupSpawns();
        initItemsUsingDefaults();
        initItemLineSegments();
        initialMapObject = toEsObject();
        fillAllPowerupSpawnPoints();
    }

    private List<Point> fillList(EsObject[] esobList) {
        List<Point> list = new ArrayList<Point>();
        if (esobList != null) {
            for (EsObject thisObj : esobList) {
                int x = thisObj.getInteger(PluginConstants.X);
                int y = thisObj.getInteger(PluginConstants.Y);
                Point newPoint = new Point(x, y);
                list.add(newPoint);
            }
        }
        return list;
    }

    private EsObject[] getEsObjectList(List<Point> list) {
        if (list == null || list.isEmpty()) {
            return null;
        }
        EsObject[] array = new EsObject[list.size()];
        int ptr = 0;
        for (Point point : list) {
            EsObject obj = new EsObject();
            obj.setInteger(PluginConstants.X, (int) Math.round(point.getX()));
            obj.setInteger(PluginConstants.Y, (int) Math.round(point.getY()));
            array[ptr] = obj;
            ptr++;
        }
        return array;
    }

    private EsObject[] getEsObjectItemList() {
        List<Item> list = getItems();
        if (list == null || list.isEmpty()) {
            return null;
        }
        EsObject[] array = new EsObject[list.size()];
        int ptr = 0;
        for (Item item : list) {
            array[ptr] = item.toEsObject();
            ptr++;
        }
        return array;
    }

    private List<Point> getDefaultTankSpawns() {
        List<Point> list = new ArrayList<Point>();
        list.add(new Point(1249, 146));
        list.add(new Point(946, 903));
        list.add(new Point(476, 1493));
        list.add(new Point(153, 343));
        list.add(new Point(1386, 1036));
        return list;
    }

    private List<Point> getDefaultPowerupSpawns() {
        List<Point> list = new ArrayList<Point>();
        list.add(new Point(1252, 257));
        list.add(new Point(871, 33));
        list.add(new Point(497, 43));
        list.add(new Point(76, 1510));
        list.add(new Point(896, 1533));
        list.add(new Point(1560, 773));
        return list;
    }

    public List<PlayerInfo> getEnemyTanks( String playerWhoShot) {
        List<PlayerInfo> list = new ArrayList<PlayerInfo>();
        for (PlayerInfo pInfo : playerInfoMap.values()) {
            Heading tankHeading = pInfo.getHeading();
            if (tankHeading != null && !playerWhoShot.equals(pInfo.getPlayerName())) {
                    list.add(pInfo);
            }
        }
        return list;
    }

    public boolean isTankPathValid(  LineSegment path) {
        if (obstacleItemLineSegments.isEmpty()) {
            return true;
        }
        
        IntersectionTestResult itr = IntersectionDetector.segmentCollectionTest(path, obstacleItemLineSegments, null);

        if (itr == null || !itr.isIntersecting()) {
            return true;
        } else {
            return false;
        }
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setTankSpawnPoints(List<Point> tankSpawnPoints) {
        this.tankSpawnPoints = tankSpawnPoints;
    }

    public Point getRandomTankSpawnPoint() {
        int size = tankSpawnPoints.size();
        int ptr = rnd.nextInt(size);
        return tankSpawnPoints.get(ptr);
    }

    public void setPowerupSpawnPoints(List<Point> powerupSpawnPoints) {
        this.powerupSpawnPoints = powerupSpawnPoints;
    }

    public void setItems(List<Item> items) {
        this.items = items;
    }

    private void initItemLineSegments() {
        hittableItemLineSegments = new LineSegmentCollection();
        obstacleItemLineSegments = new LineSegmentCollection();
        for (Item item : items) {
            if (item.isHittable()) {
                    hittableItemLineSegments.addItem(item, PluginConstants.BULLET_RADIUS);
            }
            if (item.isObstacle()) {
                    obstacleItemLineSegments.addItem(item, PluginConstants.BULLET_RADIUS);
            }
        }
    }

    private void initItems(EsObject[] itemArray) {
        items = new ArrayList<Item>();
        if (itemArray != null) {
            for (EsObject thisObj : itemArray) {
                getItems().add(new Item(thisObj));
            }
        }
    }

    public EsObject getInitialMapObject() {
        return initialMapObject;
    }

    public List<Point> getTankSpawnPoints() {
        return tankSpawnPoints;
    }

    public List<Point> getPowerupSpawnPoints() {
        return powerupSpawnPoints;
    }

    public List<Item> getItems() {
        return items;
    }

    public void setPlayerInfoMap(AbstractMap<String, PlayerInfo> playerInfoMap) {
        this.playerInfoMap = playerInfoMap;
    }

    public AbstractMap<Integer, Powerup> getPowerupMap() {
        return powerupMap;
    }

    public void addPowerup(Powerup p) {
        powerupMap.put(p.getId(), p);
    }

    public void removePowerup(int id) {
        powerupMap.remove(id);
    }

    private void initItemsUsingDefaults() {
        items = new ArrayList<Item>();
        items.add(new Item("wr", 693, -3, 150, 200, true, false));
        items.add(new Item("wl", 549, -3, 150, 200, true, false));
        items.add(new Item("wl", 549, 196, 150, 200, true, false));
        items.add(new Item("wr", 693, 193, 150, 200, true, false));
    }

    private EsObject toEsObject() {
        EsObject obj = new EsObject();
        obj.setInteger(PluginConstants.WIDTH, width);
        obj.setInteger(PluginConstants.HEIGHT, height);
        obj.setString(PluginConstants.MAP_NAME, name);
        EsObject[] tankSpawnArray = getEsObjectList(tankSpawnPoints);
        if (tankSpawnArray != null && tankSpawnArray.length > 0) {
            obj.setEsObjectArray(PluginConstants.TANK_SPAWN_LIST, tankSpawnArray);
        }
        EsObject[] powerupSpawnArray = getEsObjectList(powerupSpawnPoints);
        if (powerupSpawnArray != null && powerupSpawnArray.length > 0) {
            obj.setEsObjectArray(PluginConstants.POWERUP_SPAWN_LIST, powerupSpawnArray);
        }
        EsObject[] itemArray = getEsObjectItemList();
        if (itemArray != null && itemArray.length > 0) {
            obj.setEsObjectArray(PluginConstants.ITEM_LIST, itemArray);
        }
        return obj;
    }

    public synchronized EsObject[] getPowerupEsObjects() {
        if (powerupMap.isEmpty()) {
            return null;
        }
        EsObject[] list = new EsObject[powerupMap.size()];
        int ptr = 0;
        for (Powerup powerup : powerupMap.values()) {
            list[ptr] = powerup.toEsObject();
            ptr++;
        }
        return list;
    }
    
    public synchronized EsObject[] getBulletEsObjects() {
        if (bulletMap.isEmpty()) {
            return null;
        }
        EsObject[] list = new EsObject[bulletMap.size()];
        int ptr = 0;
        for (Projectile bullet : bulletMap.values()) {
            list[ptr] = bullet.getBulletEsObject();
            ptr++;
        }
        return list;
    }
    
    public AbstractMap<Integer, Projectile> getBulletMap() {
        return bulletMap;
    }

    public void setBulletMap(AbstractMap<Integer, Projectile> bulletMap) {
        this.bulletMap = bulletMap;
    }

    private void fillAllPowerupSpawnPoints() {
        for (Point point : powerupSpawnPoints) {
            fillOnePowerupSpawnPoint(point);
        }
    }
    
    public Powerup fillOnePowerupSpawnPoint(Point point) {
        Powerup powerup = new Powerup(point);
        powerupMap.put(powerup.getId(), powerup);
        return powerup;
    }

    public Powerup playerGrabsPowerup(int id, PlayerInfo pInfo, long atTime) {
        if (!powerupMap.containsKey(id)) {
            return null;
        } else {
            Powerup powerup = powerupMap.get(id);
            if (powerup == null) {
                return null;
            }
            Heading heading = pInfo.getHeading();
            if (heading ==  null) {
                return null;
            }
            boolean success = heading.isValidPositionAtTime(atTime, 
                    powerup.getX(), powerup.getY());
            if (!success) {
                return null;
            }
            success = powerup.playerGrabsPowerup();
            powerupMap.remove(id);
            return powerup;
        }
    }
    
    public Powerup respawnPowerup(Point point) {
        // we will assume that this is a valid powerup spawn point
        // we will assume that this spawn point has no powerup at the moment
        Powerup powerup = new Powerup(point);
        powerupMap.put(powerup.getId(), powerup);
        return powerup;
    }

    public LineSegmentCollection getHittableItemLineSegments() {
        return hittableItemLineSegments;
    }

    public LineSegmentCollection getObstacleItemLineSegments() {
        return obstacleItemLineSegments;
    }
}
