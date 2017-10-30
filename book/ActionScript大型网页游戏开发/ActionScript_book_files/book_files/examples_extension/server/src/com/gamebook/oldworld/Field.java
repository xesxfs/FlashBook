package com.gamebook.oldworld;

public enum Field {

    Type("ty"),
    Response("re"),
    Event("ev"),
    Command("c"),
    Status("s"),
    Success("su"),
    Failure("f"),
    ErrorCode("e"),
    Avatar("a"),
    ClothingArray("w"),
    FurnitureArray("f"),
    ClothingTypeArray("t"),
    ItemType("i"),
    ItemId("d"),
    
    // Used for loading and creating avatars
    AvatarId("a1"), // used only during load
    AvatarName("a2"),
    AvatarGender("a3"),
    AvatarHair("a4"),
    AvatarTop("a5"),
    AvatarBottom("a6"),
    AvatarShoes("a7"),
    AvatarMoney("a8"),
    AvatarClothing("a9"),
    AvatarPassword("a0"), // used only during create

    // Used for loading clothing
    ClothingId("c1"),
    ClothingType("c2"),
    ClothingName("c3"),
    ClothingFileName("c4"),
    ClothingCost("c5"),

    // Used for loading furniture
    FurnitureId("f1"),
    FurnitureName("f2"),
    FurnitureFileName("f3"),
    FurnitureCost("f4"),
    FurnitureEntryId("f5"), // also used for moving
    Row("f6"), // also used for moving
    Column("f7"), // also used for moving
    InWorld("f8"), // also used for moving
    FurnitureItem("f9"),

    // Used for loading clothing types
    ClothingTypeId("t1"),
    ClothingTypeName("t2"),
    
    // Used for loading an area
    Avatars("as"),
    RoomOwner("ro"),
    FurnitureList("fl"),

    // Used for pathing
    PathPoints("pp"),
    TimeStarted("ts"),
    Path("p"),

    // Used for buddies
    BuddyId("bi"),
    BuddyName("bn"),
    BuddyList("bl"),
    BuddyLoggedIn("li");

    private final String code;
    
    private Field(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

}
