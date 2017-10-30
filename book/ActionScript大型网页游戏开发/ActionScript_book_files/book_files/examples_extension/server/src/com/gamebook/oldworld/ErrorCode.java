package com.gamebook.oldworld;

public enum ErrorCode {

    GeneralError("1"),
    AvatarNameAlreadyExists("2"),
    ClothingIdDoesntExist("3"),
    FurnitureIdDoesntExist("4"),
    AvatarDoesntOwnSpecifiedClothing("5"),
    InvalidUsernameOrPassword("6"),
    AvatarCantAffordItem("7"),
    BuddyIdIsInvalid("8"),
    FurnitureEntryDoesntExist("9"),
    CanOnlyMoveYourOwnFurniture("10"),
    CanOnlyMoveFurnitureInARoom("11");

    private String errorCode;

    private ErrorCode(String code) {
        errorCode = code;
    }

    public String getErrorCode() {
        return errorCode;
    }

}
