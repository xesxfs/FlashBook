package com.gamebook.oldworld;

public enum Command {

    // Requests/Responses
    Walk("w"),
    LoadAreaDetails("l"),
    EquipClothing("e"),
    BuyItem("b"),
    RegisterAvatar("r"),
    AddBuddy("ab"),
    RemoveBuddy("rb"),
    MoveFurniture("mf"),
    LoadBuddies("lb"),

    // Events
    PathUpdate("p"),
    AvatarJoined("aj"),
    AvatarLeft("al"),
    FurnitureUpdate("fu");

    private final String code;

    private Command(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }
}
