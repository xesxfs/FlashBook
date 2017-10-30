package com.gamebook.tank;

public class PluginConstants {

    // actions 
    public static final String ACTION          = "a";
    public static final String ADD_PLAYER      = "au";
    public static final String COLLECT_POWERUP = "cp";
    public static final String ERROR           = "err";
    public static final String HEALTH_UPDATE   = "hu";
    public static final String SHOT_HIT        = "ht";
    public static final String GAME_OVER       = "go";
    public static final String INIT_ME         = "i";
    public static final String HEADING_UPDATE  = "pu";
    public static final String REMOVE_POWERUP  = "rp";
    public static final String REMOVE_PLAYER   = "ru";
    public static final String START_COUNTDOWN = "s";
    public static final String STOP_COUNTDOWN  = "sc";
    public static final String START_GAME      = "sg";
    public static final String SHOOT           = "sh";
    public static final String SPAWN_POWERUP   = "sp";
    public static final String SPAWN_TANK      = "st";
    public static final String TANK_KILLED     = "tk";
    public static final String PLAYER_LIST     = "ul";
    public static final String UPDATE_TURRET_ROTATION = "ut";
    
    // parameters
    public static final String ANGLE           = "an";
    public static final String BULLET          = "bu";
    public static final String COLLISION_STRUCTURE  = "cb";
    public static final String COLLISION_OUT_OF_BOUNDS  = "co";
    public static final String COLLISION_TANK  = "ct";
    public static final String COUNTDOWN_LEFT  = "cs";
    public static final String NUM_DEATHS      = "d";
    public static final String GAME_STATE      = "gs";
    public static final String GAME_STATE_OBJ  = "gso";
    public static final String HEADING         = "hd";
    public static final String HEALTH          = "hl";
    public static final String ITEM_ID         = "id";
    public static final String NAME            = "n";
    public static final String NUM_KILLS       = "k";
    public static final String POWERUP_AMMO    = "pa";
    public static final String POWERUP_HEALTH  = "ph";
    public static final String POWERUP_LIST    = "pl";
    public static final String POWERUP_TYPE    = "pt";
    public static final String SCORE           = "s";
    public static final String SPEED           = "sp";
    public static final String SUCCESS         = "suc";
    public static final String TIME_STAMP      = "tm";
    public static final String TANK_NAME       = "tn";
    public static final String TARGET_X        = "tx";
    public static final String TARGET_Y        = "ty";   
    
    // map reader parameters
    public static final String DECAL           = "d";
    public static final String HEIGHT          = "h";
    public static final String HITTABLE        = "ht";
    public static final String ITEM_LIST       = "il";
    public static final String MAP             = "map";
    public static final String MAP_NAME        = "n";
    public static final String OBSTACLE        = "ob";
    public static final String POWERUP_SPAWN_LIST = "ps";
    public static final String TANK_SPAWN_LIST = "ts";
    public static final String WIDTH           = "w";
    public static final String X               = "x";
    public static final String Y               = "y";   
    
    // error messages
    
    // game flow constants
    public static final int MAXIMUM_PLAYERS     = 10;
    public static final int MINIMUM_PLAYERS     = 1;    
    public static final int COUNTDOWN_SECONDS   = 1;
    
    // other constants
    public static final int TURRET_ROTATION_UPDATE_PERIOD = 500;
    public static final int POSITION_UPDATE_FUZZINESS = 100;
    public static final int TURRET_LENGTH       = 30;
    public static final int BULLET_LIFE_MS      = 3000;
    public static final int DEFAULT_MAP_WIDTH   = 1600;
    public static final int DEFAULT_MAP_HEIGHT  = 1200;
    public static final int BULLET_HIT_POINTS   = 25;
    public static final int TANK_RADIUS         = 20;
    public static final int BULLET_RADIUS       = 5;
    public static final double BULLET_SPEED     = 0.24;
    public static final double TANK_SPEED       = 0.06;
    public static final int FULL_HEALTH         = 100;
    public static final int COLLISION_CHECK_PERIOD_MS = 100;
    public static final int POWERUP_RESPAWN_MS  = 10 * 1000;

    public static final double DANGER_RADIUS =
            BULLET_LIFE_MS * (BULLET_SPEED +  TANK_SPEED) 
            + 2 * (TANK_RADIUS + BULLET_RADIUS);
    
}
